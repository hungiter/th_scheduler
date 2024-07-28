import 'package:firebase_database/firebase_database.dart';

import '../data/message.dart';

class RealtimeDatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref("");

  Stream<List<Message>> getMessagesByContact(String userId, String contactId) {
    return _db.child('messages').orderByChild('timestamp').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final messages = data.values
          .map((item) => Message.fromRealtimeDatabase(item))
          .toList();
      return messages
          .where((message) =>
              (message.senderId == userId && message.receiverId == contactId) ||
              (message.senderId == contactId && message.receiverId == userId))
          .toList();
    });
  }
}
