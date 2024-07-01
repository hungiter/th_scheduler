import '../data/user.dart';
import 'pages_handle.dart';
import '../services/authentication_services.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  HomePage({required this.userData});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  late final Map<String, dynamic> currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.userData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              AuthService().signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => LoginWithOTPScreen(),
              ));
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, ${currentUser["displayName"]}',
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 20),
                  if (currentUser["email"].isNotEmpty)
                    Text(
                      'Email: ${currentUser["email"]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Last Login: ${currentUser["lastLogin"]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
