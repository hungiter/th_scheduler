import 'dart:async';

import 'package:th_scheduler/main.dart';
import 'package:th_scheduler/pages/pages_handle.dart';
import 'package:th_scheduler/pages/responsive/responsive_layout.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:th_scheduler/utilities/firestore_handler.dart';
import 'package:th_scheduler/services/preferences_manager.dart';
import 'package:th_scheduler/utilities/qr_handler.dart';

import 'homepage_constant.dart';

class StaffHomePage extends StatefulWidget {
  StaffHomePage();

  @override
  _StaffHomePageState createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  final FirestoreHandler _firestoreHandler = FirestoreHandler();
  bool onLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _checkAllDataNeed();
  }

  Future<void> _checkLoginStatus() async {
    Map<String, dynamic> prefUser =
        await PreferencesManager.getUserDataFromSP();

    if (prefUser.isEmpty) {
      _navigationToLogin();
    }
  }

  Future<void> _checkAllDataNeed() async {
    await _firestoreHandler.initializeRoomsIfEmpty((error) {
      debugPrint(error);
    }, () async {
      String staffId = await _firestoreHandler.getStaffId();
      await PreferencesManager.saveStaffId(staffId);

      setState(() {
        onLoading = false;
      });
    });
  }

  void _navigationToLogin() {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
          builder: (context) =>
              (kIsWeb) ? LoginWithPasswordScreen() : LoginWithOTPScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (onLoading)
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: staffAppBar,
            backgroundColor: mobileBackground,
            body: Container(
              padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
              child: Column(
                children: [ScanQRCode()],
              ),
            ),
          );
  }
}
