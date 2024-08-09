import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:th_scheduler/main.dart';
import 'package:th_scheduler/pages/pages_handle.dart';
import 'package:th_scheduler/services/authentication_services.dart';
import 'package:th_scheduler/services/preferences_manager.dart';

import '../auth_otp_screen.dart';

class MyDrawer extends StatefulWidget {
  final int selected;
  final Function(int) onSelect;

  const MyDrawer(
      {super.key,
      required this.selected,
      required this.onSelect}); // Accepts a callback function

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  int _selectedIndex = 0;
  late int selected;

  @override
  void initState() {
    super.initState();
  }

  void _onSelected(int tagId) {
    widget.onSelect(tagId);
    selected = widget.selected;
    setState(() {
      _selectedIndex = tagId;
    });
  }

  @override
  void didUpdateWidget(MyDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      setState(() {
        selected = widget.selected;
        _selectedIndex = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white70,
      shape: const RoundedRectangleBorder(),
      shadowColor: Colors.black,
      child: Column(
        children: [
          const DrawerHeader(child: Icon(Icons.hotel)),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text(" ĐẶT PHÒNG"),
            selected: _selectedIndex == 0,
            selectedTileColor: Colors.blueAccent.withOpacity(0.3),
            onTap: () {
              _onSelected(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text(" LỊCH SỬ"),
            selected: _selectedIndex == 1,
            selectedTileColor: Colors.blueAccent.withOpacity(0.3),
            onTap: () {
              _onSelected(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.comment),
            title: const Text(" TƯ VẤN & HỖ TRỢ"),
            selected: _selectedIndex == 2,
            selectedTileColor: Colors.blueAccent.withOpacity(0.3),
            onTap: () {
              _onSelected(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text(" THÔNG TIN NGƯỜI DÙNG"),
            selected: _selectedIndex == 3,
            selectedTileColor: Colors.blueAccent.withOpacity(0.3),
            onTap: () {
              _onSelected(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text(" ĐĂNG XUẤT"),
            selected: _selectedIndex == 4,
            selectedTileColor: Colors.blueAccent.withOpacity(0.3),
            onTap: () {
              PreferencesManager.removePreferences("user_model");
              navigatorKey.currentState?.pushReplacement(
                  MaterialPageRoute(builder: (context) => WelcomeScreen()));
            },
          ),
        ],
      ),
    );
  }
}
