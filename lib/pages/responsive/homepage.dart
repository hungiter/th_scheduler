import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:th_scheduler/pages/responsive/responsive_layout.dart';
import 'package:th_scheduler/services/preferences_manager.dart';

import 'package:th_scheduler/data/user.dart';
import 'package:th_scheduler/pages/pages_handle.dart';
import 'package:th_scheduler/services/authentication_services.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  HomePage({required this.currentUser});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Map<String, dynamic> currentUser;
  final AuthService _authService = AuthService();
  late Users user;
  bool onLoading = true;

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
    if (currentUser["id"] == "") {
      _checkLoginStatus();
    }

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

    setState(() {
      currentUser = prefUser;
      user = Users.fromJson(currentUser);
    });
  }

  void _navigationToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              (kIsWeb) ? LoginWithPasswordScreen() : LoginWithOTPScreen()),
    );
  }

  String formatDateTime(String iso8601String) {
    return DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(DateTime.parse(iso8601String));
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Home Page'),
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.logout),
  //           onPressed: () async {
  //             _authService.signOut();
  //             _navigationToLogin();
  //           },
  //         ),
  //       ],
  //     ),
  //     body: (onLoading)
  //         ? const CircularProgressIndicator()
  //         : Padding(
  //             padding: const EdgeInsets.all(16.0),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Text('Welcome, ${currentUser["displayName"]}',
  //                     style: const TextStyle(fontSize: 24)),
  //                 const SizedBox(height: 16),
  //                 Text(
  //                   'User ID: ${currentUser["id"]}',
  //                   style: const TextStyle(fontSize: 16),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 if (currentUser["email"].isNotEmpty)
  //                   Text(
  //                     'Email: ${currentUser["email"]}',
  //                     style: const TextStyle(fontSize: 16),
  //                   ),
  //                 const SizedBox(height: 16),
  //                 Text(
  //                   'Last Login: ${formatDateTime(currentUser["lastLogin"])}',
  //                   style: const TextStyle(fontSize: 16),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 Text(
  //                   'Created At: ${formatDateTime(currentUser["createdAt"])}',
  //                   style: const TextStyle(fontSize: 16),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 Text(
  //                   'Updated At: ${formatDateTime(currentUser["updatedAt"])}',
  //                   style: const TextStyle(fontSize: 16),
  //                 ),
  //               ],
  //             ),
  //           ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return ResponsiveHomePage(
        mobileHomePage: MobileHome(),
        tabletHomePage: TabletHome(),
        desktopHomePage: DesktopHome());
  }
}
