class Message {
  final String senderId;
  final String receiverId;
  final String text;
  final int timestamp;

  Message(
      {required this.senderId,
      required this.receiverId,
      required this.text,
      required this.timestamp});

  factory Message.fromRealtimeDatabase(Map<dynamic, dynamic> data) {
    return Message(
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? 0,
    );
  }
}
