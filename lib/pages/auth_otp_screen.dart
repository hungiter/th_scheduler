import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:th_scheduler/pages_components/custom_inputs.dart';
import 'package:th_scheduler/services/preferences_manager.dart';
import '../main.dart';
import '../pages_components/custom_buttons.dart';
import '../services/authentication_services.dart';
import 'responsive/homepage.dart';

class LoginWithOTPScreen extends StatefulWidget {
  @override
  _LoginWithOTPScreenState createState() => _LoginWithOTPScreenState();
}

class _LoginWithOTPScreenState extends State<LoginWithOTPScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();

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

  String? _verificationId;
  String _error = "";
  String otp = "";
  String phoneNumber = "";
  bool onVerifyPhone = false;
  bool onVerifyOTP = false;

  @override
  void initState() {
    super.initState();
  }

  void phoneNumberParser() {
    setState(() {
      phoneNumber = "+${selectedCountry.phoneCode} ${_phoneController.text}";
    });
  }

  void _verifyPhoneNumberAndSendOTP() async {
    if (_phoneController.text.isNotEmpty) {
      phoneNumberParser();
      setState(() async {
        onVerifyPhone = true;
        await _authService.signInWithPhoneNumber(
          phoneNumber,
          (String verificationId) {
            _verificationId = verificationId;
            otp = "";
          },
          (FirebaseAuthException e) {
            _error = e.message!;
          },
        );
        onVerifyPhone = false;
      });
    } else {
      setState(() {
        _error = "Phone number cannot be empty.";
      });
    }
  }

  void _verifyOTPAndLogin() async {
    if (otp.isNotEmpty && _verificationId != null) {
      setState(() async {
        onVerifyOTP = true;
        await _authService.signInWithOTP(
          _verificationId!,
          otp,
          (FirebaseAuthException e) {
            _error = e.message!;
          },
        );
        onVerifyOTP = false;

        Map<String, dynamic> userData =
            await PreferencesManager.getUserDataFromSP();
        if (userData.isNotEmpty) _navigateToHomePage(userData);
      });
    } else {
      setState(() {
        _error = "OTP cannot be empty.";
      });
    }
  }

  void _navigateToHomePage(Map<String, dynamic> user) {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            HomePage(currentUser: user), // Replace with your home screen
      ),
    );
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
                                    onPhoneChanged: (value) {
                                      setState(() {
                                        _error = "";
                                      });
                                    },
                                    onCountryChanged: (country) {
                                      setState(() {
                                        _error = "";
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
                                        _error = "";
                                        otp = value;
                                      });
                                    })
                                : const SizedBox(),
                            (_error.isNotEmpty)
                                ? Text(
                                    _error,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  )
                                : const SizedBox(),
                            Text(
                              (onVerifyPhone)
                                  ? "Đang kiểm tra SĐT"
                                  : (onVerifyOTP)
                                      ? "Đang xác nhận OTP"
                                      : "",
                              style: const TextStyle(color: Colors.yellow),
                            ),
                            SizedBox(
                              height: 50,
                              width: double.maxFinite,
                              child: Container(
                                  padding: const EdgeInsets.only(top: 5),
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
                                          setState(() {
                                            _error = "$e";
                                          });
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
