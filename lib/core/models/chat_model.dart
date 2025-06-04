// lib/feature/chat/models/chat_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final List<String> participants; // [uid1, uid2]
  final Map<String, dynamic> participantData;
  // keys: uid, values: { "name": String, "avatar": String }
  final String lastMessage;
  final Timestamp lastTimestamp;
  final Map<String, int> unreadCount;
  // e.g. { "uid1": 0, "uid2": 3 }

  ChatModel({
    required this.chatId,
    required this.participants,
    required this.participantData,
    required this.lastMessage,
    required this.lastTimestamp,
    required this.unreadCount,
  });

  factory ChatModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ChatModel(
      chatId: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantData: Map<String, dynamic>.from(data['participantData'] ?? {}),
      lastMessage: data['lastMessage'] as String? ?? "",
      lastTimestamp: data['lastTimestamp'] as Timestamp,
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
    );
  }
}
