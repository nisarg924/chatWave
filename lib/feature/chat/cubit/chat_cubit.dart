// lib/feature/chat/cubit/chat_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:chatwave/core/models/message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

// lib/feature/chat/cubit/chat_cubit.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  DatabaseReference? _messagesRef;
  StreamSubscription<DatabaseEvent>? _messagesSub;

  DatabaseReference? _typingRef;
  StreamSubscription<DatabaseEvent>? _typingSub;

  /// Call this when entering a specific chat
  void loadMessages(String chatId) {
    emit(ChatLoading());

    // 1) Subscribe to RTDB “messages/<chatId>”
    _messagesRef = FirebaseDatabase.instance.ref('messages/$chatId');

    _messagesSub = _messagesRef!.onValue.listen((event) {
      final snapshot = event.snapshot;
      final Map<dynamic, dynamic>? map =
      snapshot.value as Map<dynamic, dynamic>?;

      if (map == null) {
        emit(ChatLoaded([], isOtherTyping: false));
        return;
      }

      // Convert map to a sorted list of MessageModel by timestamp
      final msgs = map.entries
          .map((entry) => MessageModel.fromMap(
        entry.key as String,
        entry.value as Map<dynamic, dynamic>,
      ))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      emit(ChatLoaded(msgs, isOtherTyping: false));
    }, onError: (e) {
      emit(ChatError(e.toString()));
    });
  }

  /// Call this to start listening for “other user typing” under RTDB
  void listenTyping(String chatId, String otherUid) {
    _typingRef = FirebaseDatabase.instance.ref('typing/$chatId/$otherUid');
    _typingSub = _typingRef!.onValue.listen((event) {
      final typingSnap = event.snapshot.value as Map<dynamic, dynamic>?;
      final isTyping = (typingSnap != null && typingSnap['typing'] == true);
      if (state is ChatLoaded) {
        final loadedState = state as ChatLoaded;
        emit(ChatLoaded(loadedState.messages, isOtherTyping: isTyping));
      }
    }, onError: (e) {
      // ignore typing errors
    });
  }

  /// Send a text message (RTDB + Firestore only)
  Future<void> sendMessage(String chatId, MessageModel msg) async {
    // 1) Push the message to RTDB under “messages/<chatId>”
    final newRef = FirebaseDatabase.instance.ref('messages/$chatId').push();
    await newRef.set(msg.toMap());

    // 2) Update Firestore “chats/<chatId>”:
    final chatDocRef =
    FirebaseFirestore.instance.collection('chats').doc(chatId);
    final chatSnap = await chatDocRef.get();
    if (!chatSnap.exists) return;
    final data = chatSnap.data()!;
    final participants = List<String>.from(data['participants'] as List);
    final otherUid =
    (msg.senderId == participants[0]) ? participants[1] : participants[0];

    final lastText = msg.isImage ? '[📷 Image]' : msg.text;
    await chatDocRef.update({
      'lastMessage': lastText,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'unreadCount.$otherUid': FieldValue.increment(1),
    });
  }

  /// Upload the image to Firebase Storage, then send it
  Future<void> sendImageMessage(String chatId, File file) async {
    emit(ChatUploadingImage());

    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance
          .ref()
          .child('chat_images')
          .child(chatId)
          .child('$fileName.jpg');

      final snapshot = await ref.putFile(file);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      final msg = MessageModel(
        messageId: '',
        senderId: FirebaseAuth.instance.currentUser!.uid,
        text: '',
        isImage: true,
        imageUrl: downloadUrl,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await sendMessage(chatId, msg);
      emit(ChatImageUploaded());
    } catch (e) {
      emit(ChatError('Image upload failed: $e'));
    }
  }

  /// Update “typing” indicator node
  Future<void> setTyping(
      String chatId, String userId, bool isTyping) async {
    final ref = FirebaseDatabase.instance.ref('typing/$chatId/$userId');
    if (isTyping) {
      await ref.set({'typing': true});
    } else {
      await ref.remove();
    }
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'unreadCount.$userId': 0,
    });
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    _typingSub?.cancel();
    return super.close();
  }
}

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

/// When messages are loaded, `isOtherTyping` indicates
/// whether the other user is currently typing.
class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  final bool isOtherTyping;

  ChatLoaded(this.messages, {this.isOtherTyping = false});
}

class ChatUploadingImage extends ChatState {}

class ChatImageUploaded extends ChatState {}

class ChatError extends ChatState {
  final String error;
  ChatError(this.error);
}