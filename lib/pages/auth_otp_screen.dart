import 'package:th_scheduler/services/notify_services.dart';

import '../main.dart';
import 'responsive/homepage.dart';
import '../pages_components/custom_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:th_scheduler/pages_components/custom_inputs.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../services/authentication_services.dart';
import 'package:country_picker/country_picker.dart';
import 'package:th_scheduler/services/preferences_manager.dart';

class LoginWithOTPScreen extends StatefulWidget {
  @override
  _LoginWithOTPScreenState createState() => _LoginWithOTPScreenState();
}

class _LoginWithOTPScreenState extends State<LoginWithOTPScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  final NotifyServices _notifyServices = NotifyServices();

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

  String _verificationId = "";
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

  String twilioPhoneNumber() {
    return "+${selectedCountry.phoneCode}${int.parse(_phoneController.text)}";
  }

  void _verifyPhoneNumberAndSendOTP() async {
    if (_phoneController.text.isNotEmpty) {
      phoneNumberParser();
      setState(() {
        onVerifyPhone = true;
      });

      await _authService.sendOtpAndCreateTmpUser(twilioPhoneNumber(),
          (FirebaseAuthException e) {
        setState(() {
          _error = e.message!;
        });
      }, (String verificationId) {
        // User otp as verificationID
        setState(() {
          _verificationId = verificationId;
        });
      });

      _notifyServices.showMessage(_verificationId);
      setState(() {
        onVerifyPhone = false;
      });
    } else {
      setState(() {
        _error = "Phone number cannot be empty.";
      });
    }
  }

  void _verifyOTPAndLogin() async {
    if (otp.isNotEmpty && _verificationId.isNotEmpty) {
      setState(() {
        onVerifyOTP = true;
      });

      await _authService.verifyOtp(twilioPhoneNumber(), otp,
          (FirebaseAuthException e) {
        setState(() {
          _error = e.message!;
        });
      }, () async {
        _notifyServices.showMessage("Authentication success");
        Map<String, dynamic> userData =
            await PreferencesManager.getUserDataFromSP();

        if (userData.isNotEmpty) _navigateToHomePage(userData);
      });

      setState(() {
        onVerifyOTP = false;
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
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 35),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      // Adjust column height to fit content
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: Image.asset(
                            "assets/logo.png",
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 40),
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
                                const BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Column(
                            children: [
                              (_verificationId.isEmpty)
                                  ? PhoneInputWidget(
                                      height: 50,
                                      phoneController: _phoneController,
                                      selectedCountry: selectedCountry,
                                      onPhoneChanged: (value) {
                                        if (_error.isNotEmpty) {
                                          setState(() {
                                            _error = "";
                                          });
                                        }
                                      },
                                      onCountryChanged: (country) {
                                        setState(() {
                                          if (_error.isNotEmpty) {
                                            _error = "";
                                          }
                                          selectedCountry = country;
                                        });
                                      },
                                    )
                                  : const SizedBox(),
                              (_verificationId.isNotEmpty)
                                  ? OTPInputWidget(
                                      height: 100,
                                      onOTPCompleted: (value) {
                                        setState(() {
                                          if (_error.isNotEmpty) {
                                            _error = "";
                                          }
                                          otp = value;
                                        });
                                      },
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
                                    text: (_verificationId.isEmpty)
                                        ? "Gửi OTP"
                                        : "Xác nhận",
                                    enable: !onVerifyOTP && !onVerifyPhone,
                                    btnColor: Colors.green,
                                    txtColor: Colors.white,
                                    onPressed: () async {
                                      try {
                                        if (_verificationId.isEmpty) {
                                          _verifyPhoneNumberAndSendOTP();
                                        } else {
                                          _verifyOTPAndLogin();
                                        }
                                      } catch (e) {
                                        setState(() {
                                          _error = "$e";
                                        });
                                      } finally {
                                        if (_error.isNotEmpty) {
                                          _notifyServices
                                              .showErrorToast(_error);
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                              (_verificationId.isNotEmpty)
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
                                                  _verificationId = "";
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: MiniLoginFormButton(
                                              text: "Go Back",
                                              btnColor: Colors.blueGrey,
                                              txtColor: Colors.white,
                                              onPressed: () {
                                                setState(() {
                                                  otp = "";
                                                  _verificationId = "";
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
