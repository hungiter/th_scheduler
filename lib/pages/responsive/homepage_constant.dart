import 'package:flutter/material.dart';

// FF40C4FF
const desktopBackground = Color.fromARGB(255, 64, 200, 255);
const tabletBackground = Color.fromARGB(255, 44, 224, 230);
const mobileBackground = Color.fromARGB(255, 44, 200, 171);
const appName = "TH Scheduler";
const appStaffName = "Staff Mobile";
// https://www.youtube.com/watch?v=9bo1V9STW2c
var myAppBar = AppBar(
    backgroundColor: Colors.white60,
    title: const Text(
      appName,
      style: TextStyle(
          fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 5),
    ));

var staffAppBar = AppBar(
    backgroundColor: Colors.white60,
    title: const Text(
      appStaffName,
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

var imageRadius = const Radius.circular(12);
var dialogRadius = const BorderRadius.all(Radius.circular(8));

var circularEmpty = Expanded(
    child: InkWell(
        onTap: null,
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            decoration: containerDecorations[0],
            child: const Center(
              child: CircularProgressIndicator(),
            ))));

var textEmpty = Expanded(
    child: InkWell(
        onTap: null,
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            decoration: containerDecorations[0],
            child: const Center(
              child: Text("Chưa có dữ liệu để hiển thị"),
            ))));

var roomSelectedEmpty = Expanded(
  child: InkWell(
    onTap: null,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        decoration: containerDecorations[0],
        child: const Center(
          child: Text("Chọn phòng bất kì để xem thông tin chi tiết."),
        ),
      ),
    ),
  ),
);

var historySelectedEmpty = Expanded(
  child: InkWell(
    onTap: null,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        decoration: containerDecorations[0],
        child: const Center(
          child: Text("Chọn lịch sử bất kì để xem thông tin chi tiết."),
        ),
      ),
    ),
  ),
);

var waitingLoad = Expanded(
  child: InkWell(
    onTap: null,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        decoration: containerDecorations[0],
        child: const Center(
          child: Text("Đợi xíu nghen!!!"),
        ),
      ),
    ),
  ),
);

var containerDecorations = [
  // Main Container - Dialog
  BoxDecoration(
    color: const Color.fromARGB(255, 190, 220, 230),
    borderRadius: dialogRadius,
    border: Border.all(color: Colors.white, width: 2.0),
    boxShadow: const [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 16.0,
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

  // DatePicker Container
  const BoxDecoration(
    color: Color.fromARGB(170, 255, 255, 70),
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 5.0,
        offset: Offset(0, 4),
      ),
    ],
  ),

  // Rounded container
  BoxDecoration(
    color: const Color.fromARGB(255, 190, 220, 230),
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    border: Border.all(color: Colors.white, width: 2.0),
    boxShadow: const [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 5.0,
        offset: Offset(0, 4),
      ),
    ],
  ),
];
