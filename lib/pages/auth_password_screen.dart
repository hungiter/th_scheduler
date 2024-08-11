import 'package:th_scheduler/main.dart';
import 'package:th_scheduler/pages/responsive/homepage_staff.dart';
import 'auth_otp_screen.dart';
import 'responsive/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:country_picker/country_picker.dart';
import 'package:th_scheduler/pages_components/custom_inputs.dart';
import 'package:th_scheduler/pages_components/custom_buttons.dart';

import 'package:th_scheduler/data/user.dart';
import 'package:th_scheduler/services/authentication_services.dart';

class LoginWithPasswordScreen extends StatefulWidget {
  @override
  _LoginWithPasswordScreenState createState() =>
      _LoginWithPasswordScreenState();
}

class _LoginWithPasswordScreenState extends State<LoginWithPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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

  String _error = "";
  String phoneNumber = "";

  bool passInvisible = true;
  bool onCheck = false;
  IconData visibleIcon = Icons.visibility;
  IconData invisibleIcon = Icons.visibility_off;

  @override
  void initState() {
    super.initState();
  }

  void phoneNumberParser() {
    setState(() {
      phoneNumber = "+${selectedCountry.phoneCode} ${_phoneController.text}";
    });
  }

  void _loginCheck() async {
    setState(() {
      onCheck = true;
    });

    phoneNumberParser();
    await _authService.signInWithPassword(phoneNumber, _passwordController.text,
        (String errorMessage) {
      _error = errorMessage;
    }, (Users user) {
      Map<String, dynamic> userData = user.toJson();
      _navigateToHomePage(userData);
    });

    setState(() {
      onCheck = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
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
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Column(
                      children: [
                        PhoneInputWidget(
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
                        ),
                        const SizedBox(height: 10),
                        InputRowWithSuffix(
                          textFieldLabel: "Password",
                          controller: _passwordController,
                          height: 50,
                          obscureText: passInvisible,
                          enableIcon: visibleIcon,
                          disableIcon: invisibleIcon,
                          inputType: TextInputType.visiblePassword,
                          onTextChanged: (value) {
                            setState(() {
                              _error = "";
                            });
                          },
                          suffixClick: () {
                            setState(() {
                              passInvisible = !passInvisible;
                            });
                          },
                        ),
                        SizedBox(
                          height: 50,
                          width: double.maxFinite,
                          child: Container(
                            padding: const EdgeInsets.only(top: 5),
                            child: LoginFormButton(
                              text: "Xác nhận",
                              enable: !onCheck,
                              btnColor: Colors.green,
                              txtColor: Colors.white,
                              onPressed: () async {
                                _loginCheck();
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          width: double.maxFinite,
                          child: Container(
                            padding: const EdgeInsets.only(top: 5),
                            child: LoginFormButton(
                              text: "Đăng ký / Đăng nhập với OTP",
                              enable: true,
                              btnColor: Colors.blue,
                              txtColor: Colors.white,
                              onPressed: () {
                                navigatorKey.currentState?.pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LoginWithOTPScreen(), // Replace with your home screen
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
