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

var emptyExpand = Expanded(
    child: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: InkWell(
            onTap: null,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 187, 215, 230),
                  border: Border.all(color: Colors.white, width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                )))));

var dialogContainersDecoration = [
  // Main Container
  BoxDecoration(
    color: const Color.fromARGB(255, 190, 220, 230),
    borderRadius: const BorderRadius.all(Radius.circular(0)),
    border: Border.all(color: Colors.white, width: 2.0),
    boxShadow: const [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 10.0,
        offset: Offset(0, 8),
      ),
    ],
  ),
  // Image Container
  const BoxDecoration(
    color: Color.fromARGB(255, 50, 100, 150),
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 10.0,
        offset: Offset(0, 4),
      ),
    ],
  ),
  // Value Container
  const BoxDecoration(
    color: Color.fromARGB(255, 50, 200, 200),
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 5.0,
        offset: Offset(0, 4),
      ),
    ],
  ),
];
