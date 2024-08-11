import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StaffManagement {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createStaffIfEmpty() async {
    try {
      bool existed = await isExistStaff();
      if (existed) return;

      await _firestore.collection('users').doc("+18079070268").set({
        'id': "+18079070268",
        'role': 'staff',
        'password': '111111',
        'displayName': 'Staff',
        'isVerified': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp()
      });
    } catch (e, stackTrace) {
      debugPrint('Error creating staff: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<bool> isExistStaff() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where("role", isEqualTo: "staff")
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> getFirstStaff(
      Function(String) errorCallBack, Function(String) successCallback) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where("role", isEqualTo: "staff")
          .get();
      // successCallback(Users.fromFirestore(querySnapshot.docs.first).id);
    } catch (e) {
      errorCallBack("Lỗi: $e");
    }
  }

  Future<String> getStaffId() async {
    await createStaffIfEmpty();

    String staffId = "";
    await getFirstStaff((error) {
      debugPrint(error);
    }, (id) {
      staffId = id;
    });

    return staffId;
  }
}
