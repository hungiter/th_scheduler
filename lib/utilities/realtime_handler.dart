import 'package:th_scheduler/data/historyqr.dart';
import 'package:th_scheduler/data/models.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:th_scheduler/utilities/datetime_helper.dart';
import 'package:th_scheduler/utilities/realtime/historyqr_management.dart';

class RealtimeDatabaseHandler {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final DatetimeHelper _datetimeHelper = DatetimeHelper();

  // Clear chat for a specific user
  Future<void> clearChatForUser(String chatId, String userId) async {
    final DatabaseReference chatRef = _dbRef.child('chats/$chatId');

    // Get all messages in the chat
    final DataSnapshot snapshot = (await chatRef.once()) as DataSnapshot;
    if (snapshot.exists) {
      final Map<dynamic, dynamic> messages =
          snapshot.value as Map<dynamic, dynamic>;

      // Update each message to mark it as cleared by the user
      for (final messageId in messages.keys) {
        final DatabaseReference messageRef =
            chatRef.child(messageId.toString());
        await messageRef.child('clearedBy/$userId').set(true);
      }
    }
  }

  // Function to send a message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String messageText,
  }) async {
    final ChatMessage message = ChatMessage(
      senderId: senderId,
      message: messageText,
      timestamp: _datetimeHelper.currentTimestamp(), // Time stamp
    );

    final DatabaseReference chatRef = _dbRef.child('chats/$chatId');
    final newMessageRef = chatRef.push();
    await newMessageRef.set(message.toJson());
  }

  // Function to fetch chat messages as a stream
  Stream<List<ChatMessage>> getChatMessages(String chatId, String userId) {
    final DatabaseReference chatRef = _dbRef.child('chats/$chatId');

    return chatRef.onValue.map((event) {
      final List<ChatMessage> messages = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.forEach((key, value) {
          final chatMessage =
              ChatMessage.fromJson(Map<String, dynamic>.from(value));

          // Only include messages not cleared by this user
          if (!(chatMessage.clearedBy[userId] ?? false)) {
            messages.add(chatMessage);
          }
        });
      }
      return messages;
    });
  }

  final HistoryQRManagement historyQRManagement = HistoryQRManagement();

  Future<void> saveNewHistoryQR(String docId, int status) async {
    historyQRManagement.saveToDatabase(docId, status);
  }

  Future<void> updateHistoryQR(String id, int status) async {
    historyQRManagement.updateDatabase(id, status);
  }
  Future<void> removeHistoryQR(String id) async{
    historyQRManagement.removeDatabase(id);
  }

  Future<HistoryQR?> getHistoryQR(String id) async {
    return await historyQRManagement.getFromDatabase(id);
  }

  void listenToHistoryQRChanges(
      String id, void Function(HistoryQR) onDataChanged) {
    historyQRManagement.listenToChanges(id, onDataChanged);
  }
}
