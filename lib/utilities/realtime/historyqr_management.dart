import 'package:firebase_database/firebase_database.dart';
import 'package:th_scheduler/data/historyqr.dart';

class HistoryQRManagement {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  Future<void> saveToDatabase(String id, int status) async {
    DatabaseReference dbRef = _firebaseDatabase.ref('historyQR').child(id);
    HistoryQR historyQR = HistoryQR(status: status);
    await dbRef.set(historyQR.toMap());
  }

  Future<void> updateDatabase(String id, int status) async {
    DatabaseReference dbRef = _firebaseDatabase.ref('historyQR').child(id);
    DataSnapshot snapshot = await dbRef.get();

    HistoryQR historyQR =
        HistoryQR.fromMap(Map<String, dynamic>.from(snapshot.value as Map));

    historyQR.status = status;

    await dbRef.update(historyQR.toMap());
  }

  Future<void> removeDatabase(String id) async {
    try {
      DatabaseReference dbRef = _firebaseDatabase.ref('historyQR').child(id);
      await dbRef.remove();
    } catch (e) {
      return;
    }
  }

  Future<HistoryQR?> getFromDatabase(String id) async {
    DatabaseReference dbRef = _firebaseDatabase.ref('historyQR').child(id);
    DataSnapshot snapshot = await dbRef.get();

    if (snapshot.exists) {
      return HistoryQR.fromMap(
          Map<String, dynamic>.from(snapshot.value as Map));
    } else {
      return null;
    }
  }

  void listenToChanges(String id, void Function(HistoryQR) onDataChanged) {
    DatabaseReference dbRef = _firebaseDatabase.ref('historyQR').child(id);
    dbRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        HistoryQR updatedHistoryQR = HistoryQR.fromMap(
            Map<String, dynamic>.from(event.snapshot.value as Map));
        onDataChanged(updatedHistoryQR);
      }
    });
  }
}
