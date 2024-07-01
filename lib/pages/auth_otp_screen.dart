import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:th_scheduler/pages/auth_password_screen.dart';
import 'package:th_scheduler/pages_components/custom_dropdowns.dart';
import 'package:th_scheduler/pages_components/custom_inputs.dart';
import '../pages_components/custom_buttons.dart';
import '../services/authentication_services.dart';
import 'home_screen.dart';

class LoginWithOTPScreen extends StatefulWidget {
  @override
  _LoginWithOTPScreenState createState() => _LoginWithOTPScreenState();
}

class _LoginWithOTPScreenState extends State<LoginWithOTPScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _verificationId;

  Country selectedCountry = Country(
    phoneCode: "84",
    countryCode: "VN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "Vietnam",
    example: "Vietnam",
    displayName: "Vietnam",
    displayNameNoCountryCode: "VN",
    e164Key: "",
  );

  String otp = "";
  String phoneNumber = "";

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

  void _navigateToHomePage(User user) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.phoneNumber)
          .get();
      final userData = userDoc.data();
      if (userData != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userData: userData)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }

  void _navigationToLoginWithPassword() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginWithPasswordScreen()),
    );
  }

  void phoneNumberParser() {
    setState(() {
      phoneNumber = "+${selectedCountry.phoneCode} ${_phoneController.text}";
    });
  }

  void _verifyPhoneNumberAndSendOTP() async {
    phoneNumberParser();
    await _authService.signInWithPhoneNumber(
      phoneNumber,
      (String verificationId) {
        setState(() {
          otp = "";
          _verificationId = verificationId;
        });
      },
      (FirebaseAuthException e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message!)));
      },
    );
  }

  void _verifyOTPAndLogin() async {
    await _authService.signInWithOTP(_verificationId!, otp,
        (FirebaseAuthException e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message!)));
    });
  }

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
                            (_verificationId == null)
                                ? PhoneInputWidget(
                                    height: 50,
                                    phoneController: _phoneController,
                                    selectedCountry: selectedCountry,
                                    onPhoneChanged: (value) {},
                                    onCountryChanged: (country) {
                                      setState(() {
                                        selectedCountry = country;
                                      });
                                    },
                                  )
                                : const SizedBox(),
                            (_verificationId != null)
                                ? OTPInputWidget(
                                    height: 100,
                                    onOTPCompleted: (value) {
                                      setState(() {
                                        otp = value;
                                      });
                                    })
                                : const SizedBox(),
                            SizedBox(
                              height: 50,
                              width: double.maxFinite,
                              child: Container(
                                  padding: EdgeInsets.only(top: 5),
                                  child: LoginFormButton(
                                      text: (_verificationId == null)
                                          ? "Gửi OTP"
                                          : "Xác nhận",
                                      btnColor: Colors.green,
                                      txtColor: Colors.white,
                                      onPressed: () async {
                                        try {
                                          if (_verificationId == null) {
                                            _verifyPhoneNumberAndSendOTP();
                                          } else {
                                            _verifyOTPAndLogin();
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text('Error: $e')));
                                        }
                                      })),
                            ),
                            (_verificationId != null)
                                ? SizedBox(
                                    height: 50,
                                    width: double.maxFinite,
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: MiniLoginFormButton(
                                                text: "Resend OTP",
                                                btnColor: Colors.lightGreen,
                                                txtColor: Colors.white,
                                                onPressed: () {
                                                  setState(() {
                                                    _verificationId = null;
                                                  });
                                                })),
                                        const SizedBox(width: 5),
                                        Expanded(
                                            child: MiniLoginFormButton(
                                                text: "Go Back",
                                                btnColor: Colors.blueGrey,
                                                txtColor: Colors.white,
                                                onPressed: () {
                                                  setState(() {
                                                    otp = "";
                                                    _verificationId = null;
                                                  });
                                                }))
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                            (_verificationId == null)
                                ? Container(
                                    padding: const EdgeInsets.only(top: 5),
                                    width: double.maxFinite,
                                    height: 50,
                                    child: LoginFormButton(
                                        text: "Login with password",
                                        onPressed:
                                            _navigationToLoginWithPassword,
                                        btnColor: Colors.white24,
                                        txtColor: Colors.black))
                                : const SizedBox()
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
