import 'package:flutter/material.dart';

// FF40C4FF
const desktopBackground = Color.fromARGB(255, 64, 200, 255);
const tabletBackground = Color.fromARGB(255, 44, 224, 230);
const mobileBackground = Color.fromARGB(255, 44, 200, 171);
const appName = "TH Scheduler";
// https://www.youtube.com/watch?v=9bo1V9STW2c
var myAppBar = AppBar(
    backgroundColor: Colors.white60,
    title: const Text(
      appName,
      style: TextStyle(
          fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 5),
    ));

var myDrawer = const Drawer(
  backgroundColor: Colors.white70,
  shape: RoundedRectangleBorder(),
  shadowColor: Colors.black,
  child: Column(
    children: [
      DrawerHeader(child: Icon(Icons.hotel)),
      ListTile(
        leading: Icon(Icons.calendar_month),
        title: Text(" ĐẶT PHÒNG"),
      ),
      ListTile(
        leading: Icon(Icons.history),
        title: Text(" LỊCH SỬ"),
      ),
      ListTile(
        leading: Icon(Icons.comment),
        title: Text(" TƯ VẤN & HỖ TRỢ"),
      ),
      ListTile(
        leading: Icon(Icons.info),
        title: Text(" THÔNG TIN NGƯỜI DÙNG"),
      ),
      ListTile(leading: Icon(Icons.logout), title: Text(" ĐĂNG XUẤT"))
    ],
  ),
);
