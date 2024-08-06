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
    options: DefaultFirebaseOptions.currentPlatform,
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
    initValueToTest();
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
