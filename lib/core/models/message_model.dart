class MessageModel {
  final String messageId;
  final String senderId;
  final String text;        // if isImage==false, the textual content
  final bool isImage;
  final String? imageUrl;   // if isImage==true, the download URL
  final int timestamp;      // millisecondsSinceEpoch

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.isImage,
    this.imageUrl,
    required this.timestamp,
  });

  // Convert from RTDB map to MessageModel
  factory MessageModel.fromMap(String key, Map<dynamic, dynamic> value) {
    return MessageModel(
      messageId: key,
      senderId: value['senderId'] as String,
      text: value['text'] as String? ?? '',
      isImage: value['isImage'] as bool? ?? false,
      imageUrl: value['imageUrl'] as String?,
      timestamp: value['timestamp'] as int? ?? 0,
    );
  }

  // Convert this MessageModel to a Map to push into RTDB
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'isImage': isImage,
      'imageUrl': imageUrl ?? '',
      'timestamp': timestamp,
    };
  }
}

