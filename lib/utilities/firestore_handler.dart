// firestore_handler.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models.dart';

class FirestoreHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Users?> getUserByEmail(String email) async {
    try {
      final userQuerySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        final doc = userQuerySnapshot.docs.first;
        return Users.fromFirestore(doc);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user by email: $e');
      return null;
    }
  }
}