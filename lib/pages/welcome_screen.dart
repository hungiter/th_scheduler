import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:th_scheduler/pages/auth_otp_screen.dart';
import 'package:th_scheduler/pages_components/custom_buttons.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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
                                fontSize: 22, fontWeight: FontWeight.bold),
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
                                  onPressed: () => {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginWithOTPScreen()),
                                        )
                                      }))
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
