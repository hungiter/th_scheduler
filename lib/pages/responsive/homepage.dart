import 'package:intl/intl.dart';
import 'package:th_scheduler/main.dart';
import 'package:th_scheduler/pages/pages_handle.dart';
import 'package:th_scheduler/pages/responsive/responsive_layout.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:th_scheduler/utilities/firestore_handler.dart';
import 'package:th_scheduler/services/preferences_manager.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreHandler _firestoreHandler = FirestoreHandler();
  bool onLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _firestoreHandler.getAvailableRooms(
        errorCallBack: (error) {
          debugPrint(error);
        },
        successCallback: (rooms) {});

    setState(() {
      onLoading = false;
    });
  }

  // Not neccessary
  Future<void> _checkLoginStatus() async {
    Map<String, dynamic> prefUser =
        await PreferencesManager.getUserDataFromSP();

    // Re-check Preferences
    if (prefUser.isEmpty) {
      _navigationToLogin();
    }
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
    return ResponsiveHomePage(
        mobileHomePage: MobileHome(),
        tabletHomePage: TabletHome(),
        desktopHomePage: DesktopHome());
  }
}
