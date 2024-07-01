import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:th_scheduler/pages_components/custom_inputs.dart';
import '../pages_components/custom_buttons.dart';
import '../services/authentication_services.dart';
import 'home_screen.dart';

class LoginWithPasswordScreen extends StatefulWidget {
  @override
  _LoginWithPasswordScreenState createState() =>
      _LoginWithPasswordScreenState();
}

class _LoginWithPasswordScreenState extends State<LoginWithPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool passInvisible = true;
  IconData visibleIcon = Icons.visibility;
  IconData invisibleIcon = Icons.visibility_off;

  final AuthService _authService = AuthService();
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    _authService.authStateChanges.listen((User? user) {
      if (user != null) {
        _navigateToHomePage(user);
      }
    });
  }

  void _navigateToHomePage(User user) async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 35),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              style: BorderStyle.solid,
                              color: Colors.blue,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8))),
                        child: Column(
                          children: [
                            InputRow(
                                textFieldLabel: "Phone Number",
                                controller: _phoneController,
                                height: 50,
                                inputType: TextInputType.phone),
                            const SizedBox(height: 10),
                            InputRowWithSuffix(
                              textFieldLabel: "Password",
                              controller: _passwordController,
                              height: 50,
                              obscureText: passInvisible,
                              enableIcon: visibleIcon,
                              disableIcon: invisibleIcon,
                              inputType: TextInputType.visiblePassword,
                              suffixClick: () {
                                setState(() {
                                  passInvisible = !passInvisible;
                                });
                              },
                            )
                          ],
                        )),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
