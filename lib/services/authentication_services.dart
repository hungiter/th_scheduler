import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:th_scheduler/services/preferences_manager.dart';
import 'package:th_scheduler/utilities/firestore_handler.dart';
import '../data/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to sign in with phone number
  Future<void> signInWithPhoneNumber(
    String phoneNumber,
    Function(String) codeSentCallback,
    Function(FirebaseAuthException) verificationFailedCallback,
  ) async {
    // Android (or other platforms) configuration
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
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

// Sign in with password
  Future<void> signInWithPassword(String phoneNumber, String password,
      Function(String) errorListener, Function(Users) successListener) async {
    await FirestoreHandler().getUserForLogin(phoneToId(phoneNumber), password,
        (String e) {
      errorListener(e);
    }, (Users user) {
      PreferencesManager.setUserDataToSP(user);
      successListener(user);
    });
  }

  String phoneToId(String phoneNumber) {
    List<String> partSplitter = phoneNumber.split(' ');
    return partSplitter[0] + partSplitter[1].substring(1);
  }

// Function to create or update user in Firestore
  Future<void> _createOrUpdateUser(User firebaseUser) async {
    final userRef =
        _firestore.collection('users').doc(firebaseUser.phoneNumber);
    var doc = await userRef.get();

    if (!doc.exists) {
      // Create a new user if it doesn't exist
      Users newUser = Users(
        id: firebaseUser.uid,
        email: '',
        password: '111111',
        displayName:
            'User+${(await _firestore.collection('users').get()).docs.length + 1}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      await userRef.set(newUser.toJson());
      PreferencesManager.setUserDataToSP(newUser);
    } else {
      // Update user if they already exist
      await userRef.update({'lastLogin': FieldValue.serverTimestamp()});
      doc = await userRef.get();
      PreferencesManager.setUserDataToSP(Users.fromFirestore(doc));
    }
  }

  void signOut() async {
    PreferencesManager.removePreferences("user_model");
    await _auth.signOut();
  }
}
