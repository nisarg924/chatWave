// lib/feature/chat/cubit/chat_list_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:chatwave/core/models/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListCubit extends Cubit<ChatListState> {
  ChatListCubit() : super(ChatListInitial());

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  /// Loads all chats where currentUser is a participant, ordered by lastTimestamp desc.
  void loadChatList(String currentUserId) {
    emit(ChatListLoading());

    _subscription = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastTimestamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
        final chats = snapshot.docs
            .map((doc) => ChatModel.fromDocument(doc))
            .toList();
        emit(ChatListLoaded(chats));
      },
      onError: (e) {
        emit(ChatListError(e.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

abstract class ChatListState {}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<ChatModel> chats;
  ChatListLoaded(this.chats);
}

class ChatListError extends ChatListState {
  final String error;
  ChatListError(this.error);
}