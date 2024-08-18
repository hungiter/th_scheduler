import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:th_scheduler/pages/auth_otp_screen.dart';
import 'package:th_scheduler/pages/auth_password_screen.dart';
import 'package:th_scheduler/pages/responsive/homepage.dart';
import 'package:th_scheduler/pages/responsive/homepage_staff.dart';
import 'package:th_scheduler/pages_components/custom_buttons.dart';
import 'package:th_scheduler/services/preferences_manager.dart';
import 'package:th_scheduler/utilities/firestore_handler.dart';
import '../main.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late bool onLoading = true;
  late bool visited = false;
  FirestoreHandler firestoreHandler = FirestoreHandler();

  @override
  void initState() {
    super.initState();
    _checkDatabaseExisted();
    _checkPrefs();
  }

  Future<void> _checkDatabaseExisted() async {
    await firestoreHandler.initializeFirestoreDB();
  }

  Future<void> _checkPrefs() async {
    visited = await PreferencesManager.getVisitedStateToSP();

    if (visited == false) {
      setState(() {
        onLoading = false;
      });
    } else {
      Map<String, dynamic> user = await PreferencesManager.getUserDataFromSP();
      if (user.isNotEmpty && user["id"] != "") {
        _navigateToHomePage(user);
      } else {
        _navigateToLoginPage();
      }
    }
  }

  void _navigateToHomePage(Map<String, dynamic> userData) {
    if (userData["role"] == "user") {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(), // Replace with your home screen
        ),
      );
    }

    if (userData["role"] == "staff") {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              StaffHomePage(), // Replace with your home screen
        ),
      );
    }
  }

  void _navigateToLoginPage() async {
    await PreferencesManager.setVisitedStateToSP(true);

    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (context) => (kIsWeb)
            ? LoginWithPasswordScreen()
            : LoginWithOTPScreen(), // Replace with your home screen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: SafeArea(
          child: Center(
        child: (onLoading)
            ? const CircularProgressIndicator()
            : Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      // Set the desired border radius
                      child: Image.asset(
                        "assets/logo.png",
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover, // Adjust the fit as needed
                      ),
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      children: [
                        Container(
                            width: (kIsWeb) ? 600 : double.infinity,
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  style: BorderStyle.solid,
                                  color: Colors.blue,
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "TH Scheduler",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Ứng dụng đặt lịch hẹn dành cho khách sạn',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 10),
                                const SizedBox(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Developed by',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Nguyễn Thanh Hùng',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'Trần Lê Quang Trung',
                                        style: TextStyle(fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                                SizedBox(
                                    width: (kIsWeb) ? 300 : double.infinity,
                                    child: StartedButton(
                                        text: "Tiếp tục",
                                        onPressed: _navigateToLoginPage))
                              ],
                            )),
                      ],
                    )
                  ],
                ),
              ),
      )),
    );
  }
}
