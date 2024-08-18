import 'package:th_scheduler/data/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersManagement {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Users?> getUserByDocId(String docId) async {
    try {
      final doc = await _firestore.collection("users").doc(docId).get();
      if (doc.exists) {
        return Users.fromFirestore(doc);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> getUserForLogin(String phone, String password,
      Function(int) bugReached, Function(Users) successCallback) async {
    try {
      final doc = await _firestore.collection('users').doc(phone).get();
      if (doc.exists) {
        if (doc.data()?["password"] == password) {
          successCallback(Users.fromFirestore(doc));
        } else {
          bugReached(2);
        }
      } else {
        bugReached(1);
      }
    } catch (e) {
      bugReached(-1);
    }
  }
}
