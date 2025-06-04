// lib/feature/chat/models/message_model.dart

class MessageModel {
  final String messageId;
  final String senderId;
  final String text;
  final bool isImage; // if you want image messages later
  final int timestamp; // unix milliseconds
  final bool isTypingIndicator;
  // special “typing” node if you choose to implement typing

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.isImage,
    required this.timestamp,
    this.isTypingIndicator = false,
  });

  factory MessageModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return MessageModel(
      messageId: id,
      senderId: map['senderId'] as String,
      text: map['text'] as String? ?? "",
      isImage: map['isImage'] as bool? ?? false,
      timestamp: map['timestamp'] as int,
      isTypingIndicator: map['isTypingIndicator'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'isImage': isImage,
      'timestamp': timestamp,
      'isTypingIndicator': isTypingIndicator,
    };
  }
}
