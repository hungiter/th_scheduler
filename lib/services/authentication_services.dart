import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to sign in with phone number
  Future<void> signInWithPhoneNumber(
      String phoneNumber,
      Function(String) codeSentCallback,
      Function(FirebaseAuthException) verificationFailedCallback) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-sign in the user if verification is successful
        await _auth.signInWithCredential(credential);
        User? user = _auth.currentUser;
        if (user != null) {
          await _createOrUpdateUser(user);
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        verificationFailedCallback(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        codeSentCallback(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Function to sign in with OTP code
  Future<User?> signInWithOTP(String verificationId, String otp,
      Function(FirebaseAuthException) verificationFailedCallback) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;
      if (user != null) {
        await _createOrUpdateUser(user);
      }
    } on FirebaseAuthException catch (e) {
      verificationFailedCallback(e);
    }
  }

// Function to create or update user in Firestore
  Future<void> _createOrUpdateUser(User firebaseUser) async {
    final userRef =
        _firestore.collection('users').doc(firebaseUser.phoneNumber);
    final doc = await userRef.get();

    if (!doc.exists) {
      // Create a new user if it doesn't exist
      Users newUser = Users(
        id: firebaseUser.uid,
        phoneNumber: firebaseUser.phoneNumber!,
        email: firebaseUser.email ?? '',
        displayName:
            'User+${(await _firestore.collection('users').get()).docs.length + 1}',
        photoUrl: firebaseUser.photoURL ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      await userRef.set(newUser.toFirestore());
    } else {
      // Update user if they already exist
      await userRef.update({
        'lastLogin': FieldValue.serverTimestamp(),
        'photoUrl': firebaseUser.photoURL,
        'displayName': firebaseUser.displayName,
      });
    }
  }

  void signOut() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    s.clear();
    await _auth.signOut();
  }

// STORING DATA LOCALLY
  Future<void> saveUserDataToSP(Users user) async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("user_model", jsonEncode(user.toFirestore()));
  }

  Future<String> getUserIdFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("user_model") ?? '';
    Users _user = Users.fromFirestore(jsonDecode(data));
    return _user.id;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
