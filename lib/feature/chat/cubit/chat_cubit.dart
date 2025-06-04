// lib/feature/chat/cubit/chat_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:chatwave/core/models/message_model.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  DatabaseReference? _messagesRef;
  StreamSubscription<DatabaseEvent>? _messagesSub;

  /// Call this when entering a specific chat
  void loadMessages(String chatId) {
    emit(ChatLoading());

    // messages are under Realtime DB “messages/<chatId>”
    _messagesRef = FirebaseDatabase.instance.ref('messages/$chatId');

    // Listen for new children (messages)
    _messagesSub = _messagesRef!.onValue.listen((event) {
      final snapshot = event.snapshot;
      final Map<dynamic, dynamic>? map = snapshot.value as Map<dynamic, dynamic>?;

      if (map == null) {
        emit(ChatLoaded([]));
        return;
      }

      // Convert map to a sorted list of MessageModel by timestamp
      final msgs = map.entries
          .map((entry) => MessageModel.fromMap(entry.key as String, entry.value as Map<dynamic, dynamic>))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      emit(ChatLoaded(msgs));
    }, onError: (e) {
      emit(ChatError(e.toString()));
    });
  }

  /// Send a new message to Realtime DB
  Future<void> sendMessage(String chatId, MessageModel msg) async {
    final newRef = FirebaseDatabase.instance.ref('messages/$chatId').push();
    await newRef.set(msg.toMap());
  }

  /// Update “typing” indicator node
  Future<void> setTyping(String chatId, String userId, bool isTyping) async {
    final typingRef = FirebaseDatabase.instance.ref('typing/$chatId/$userId');
    if (isTyping) {
      await typingRef.set({'typing': true});
    } else {
      await typingRef.remove();
    }
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    return super.close();
  }
}

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  ChatLoaded(this.messages);
}

class ChatError extends ChatState {
  final String error;
  ChatError(this.error);
}