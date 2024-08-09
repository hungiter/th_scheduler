class ChatMessage {
  final String senderId;
  final String message;
  final int timestamp;
  final Map<String, bool> clearedBy; // New field

  ChatMessage({
    required this.senderId,
    required this.message,
    required this.timestamp,
    this.clearedBy = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'message': message,
      'timestamp': timestamp,
      'clearedBy': clearedBy,
    };
  }

  static ChatMessage fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      senderId: json['senderId'],
      message: json['message'],
      timestamp: json['timestamp'],
      clearedBy: Map<String, bool>.from(json['clearedBy'] ?? {}),
    );
  }
}
