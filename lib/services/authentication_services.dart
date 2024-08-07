import 'dart:math';

import '../data/user.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:th_scheduler/services/preferences_manager.dart';
import 'package:th_scheduler/utilities/firestore_handler.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TwilioFlutter _twilioFlutter;

  AuthService() {
    // Looking on keys.txt for key
    _twilioFlutter = TwilioFlutter(
      accountSid: 'AC254515b4ab9775c420871aa3c18cb3e-f',
      authToken: 'b93d5f1d9b80dcddb0b5551430ebef8-7',
      twilioNumber: '+18079070268',
    );
  }

  String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000))
        .toString(); // Generates a 6-digit OTP
  }

  // Function to verify phone number format and send OTP
  Future<void> sendOtpAndCreateTmpUser(
      String phoneNumber,
      Function(FirebaseAuthException) verificationFailedCallback,
      Function(String otp) successCallback) async {
    // Phone format: +84908670...
    if (!isValidPhoneNumber(phoneNumber)) {
      FirebaseAuthException exception = FirebaseAuthException(
        code: 'invalid-phone-number',
        message: 'The phone number is not in the correct format.',
      );
      verificationFailedCallback(exception);
    } else {
      String otp = generateOtp();

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(phoneNumber).get();
      if (!userDoc.exists) {
        await _firestore
            .collection('users')
            .doc(phoneNumber)
            .set({'otp': otp, 'isVerified': false});
      } else {
        bool isVerified = userDoc.get('isVerified');
        if (isVerified) {
          await _firestore
              .collection('users')
              .doc(phoneNumber)
              .update({'otp': otp});
        } else {
          await _firestore
              .collection('users')
              .doc(phoneNumber)
              .set({'otp': otp, 'isVerified': false});
        }
      }

      await _twilioFlutter.sendSMS(
        toNumber: phoneNumber,
        messageBody: 'Your OTP code is $otp',
      );

      successCallback(otp);
    }
  }

  Future<void> verifyOtp(
      String phoneNumber,
      String inputOtp,
      Function(FirebaseAuthException) verificationFailedCallback,
      Function() successCallback) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(phoneNumber).get();
    if (!userDoc.exists) {
      FirebaseAuthException exception = FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found for this phone number.',
      );
      verificationFailedCallback(exception);
    } else {
      String storedOtp = userDoc.get('otp');
      bool isVerified = userDoc.get('isVerified');
      if (inputOtp == storedOtp) {
        if (isVerified) {
          await _firestore
              .collection('users')
              .doc(phoneNumber)
              .update({'otp': FieldValue.delete()});
        } else {
          // On Create
          await _firestore.collection('users').doc(phoneNumber).update({
            'id': phoneNumber,
            'otp': FieldValue.delete(),
            'email': '',
            'password': '111111',
            'displayName':
                'User+${(await _firestore.collection('users').get()).docs.length}',
            'isVerified': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp()
          });
        }

        await _updateUserPrefs(phoneNumber);

        successCallback();
      } else {
        FirebaseAuthException exception = FirebaseAuthException(
          code: 'otp-wrong',
          message: 'Wrong OTP',
        );
        verificationFailedCallback(exception);
      }
    }
  }

  bool isValidPhoneNumber(String phoneNumber) {
    final RegExp phoneRegExp = RegExp(r'^\+\d{1,14}$');
    return phoneRegExp.hasMatch(phoneNumber);
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
  Future<void> _updateUserPrefs(String phoneNumber) async {
    final userRef = _firestore.collection('users').doc(phoneNumber);
    var doc = await userRef.get();

    // At this step, doc never null
    await userRef.update({'lastLogin': FieldValue.serverTimestamp()});
    doc = await userRef.get();
    PreferencesManager.setUserDataToSP(Users.fromFirestore(doc));
  }

  void signOut() async {
    PreferencesManager.removePreferences("user_model");
    await _auth.signOut();
  }
}
