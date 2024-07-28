// firestore_handler.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:th_scheduler/data/models.dart';

class FirestoreHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Users?> getUserByDocId(String docId) async {
    try {
      final doc = await _firestore.collection('users').doc(docId).get();
      if (doc.exists) {
        return Users.fromFirestore(doc);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> getUserForLogin(String phone, String password,
      Function(String) errorCallBack, Function(Users) successCallback) async {
    try {
      final doc = await _firestore.collection('users').doc(phone).get();
      if (doc.exists) {
        if (doc.data()?["password"] == password) {
          successCallback(Users.fromFirestore(doc));
        } else {
          errorCallBack("Sai mật khẩu");
        }
      } else {
        errorCallBack("Tài khoản không tồn tại");
      }
    } catch (e) {
      errorCallBack("Lỗi: $e");
    }
  }

  Future<List<Rooms>?> getTop10Rooms() async {
    try {
      final querySnapshot = await _firestore
          .collection('rooms')
          .orderBy('pricePerDay',
              descending: true) // Adjust the ordering field as needed
          .limit(10)
          .get();

      List<Rooms> rooms =
          querySnapshot.docs.map((doc) => Rooms.fromFirestore(doc)).toList();

      return rooms;
    } catch (e) {
      return null;
    }
  }
}
