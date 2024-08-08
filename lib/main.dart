import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:th_scheduler/services/preferences_manager.dart';
import 'services/authentication_services.dart';
import 'firebase_options.dart';
import 'pages/pages_handle.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyD4YEhscoMK4xgtcfJo2thFGnpfvNploJ4",
      authDomain: "th-scheduler-89eaa.firebaseapp.com",
      databaseURL:
          "https://th-scheduler-89eaa-default-rtdb.asia-southeast1.firebasedatabase.app/",
      projectId: "th-scheduler-89eaa",
      storageBucket: "th-scheduler-89eaa.appspot.com",
      measurementId: "G-18PVB1NE03",
      messagingSenderId: "463945083186",
      appId: kIsWeb
          ? "1:463945083186:web:34512eb8d7072853174f2b"
          : "1:463945083186:android:2ea44cb4266e8b21174f2b",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // initValueToTest();
  }

  Future<void> initValueToTest() async {
    PreferencesManager.removePreferences("user_model");
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
      ],
      child: MaterialApp(
          title: 'TH Hotel Scheduler',
          navigatorKey: navigatorKey,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          debugShowCheckedModeBanner: false,
          home: WelcomeScreen() // Ensure this is the correct starting screen
          ),
    );
  }
}

// flutter run -d chrome --web-hostname localhost --web-port 5000
// flutter build apk --release
