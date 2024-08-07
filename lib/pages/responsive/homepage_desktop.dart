import "dart:math";

import "package:flutter/material.dart";
import "package:th_scheduler/data/room.dart";
import "package:th_scheduler/pages/responsive/main_drawer.dart";
import "package:th_scheduler/pages_components/room_boxes.dart";

import "package:th_scheduler/pages/responsive/homepage_constant.dart";
import "package:th_scheduler/utilities/testing_datas.dart";

import "../../data/history.dart";
import "../../pages_components/history_boxes.dart";

class DesktopHome extends StatefulWidget {
  @override
  _DesktopHomeState createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
  late int currentPage;

  late Rooms selectionRoom;
  late List<Rooms> rooms;

  late Histories selectionHistory;
  late List<Histories> histories;

  TestData testData = TestData();

  @override
  void initState() {
    super.initState();
    setState(() {
      rooms = testData.initTestRooms(20);
      histories = testData.initTestHistories();
      currentPage = 0;
      selectionRoom = Rooms.init(0);
    });
  }

  void _currentPage(int pageId) {
    setState(() {
      currentPage = pageId;
    });
  }

  void displayRooms(Rooms rooms) {
    setState(() {
      selectionRoom = rooms;
    });
  }

  void displayHistory(Histories history) {
    setState(() {
      selectionHistory = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: desktopBackground,
      body: Row(
        children: [
          // Visible drawer
          MyDrawer(onSelect: _currentPage),

          switch (currentPage) {
            0 => Expanded(
                child: Row(
                  children: [
                    Expanded(
                        child: Column(
                      children: [
                        AspectRatio(
                            aspectRatio: 4,
                            child: SizedBox(
                                width: double.infinity,
                                child: GridView.builder(
                                    itemCount: 4,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4),
                                    itemBuilder: (context, index) {
                                      return RoomBox(
                                          roomDetails: rooms[index],
                                          onTap: displayRooms);
                                    }))),
                        Expanded(
                            child: ListView.builder(
                                itemCount: rooms.length - 4,
                                itemBuilder: (context, index) {
                                  return RoomBox(
                                      roomDetails: rooms[index + 4],
                                      onTap: displayRooms);
                                }))
                      ],
                    )),
                    Expanded(child: RoomDetailBox(roomDetails: selectionRoom))
                  ],
                ),
              ),
            1 => Expanded(
                child: Row(
                  children: [
                    Expanded(
                        child: Column(
                      children: [
                        Expanded(
                            child: ListView.builder(
                                itemCount: histories.length,
                                itemBuilder: (context, index) {
                                  return HistoryBox(
                                      history: histories[index],
                                      onTap: displayHistory);
                                }))
                      ],
                    )),
                    Expanded(child: RoomDetailBox(roomDetails: selectionRoom))
                  ],
                ),
              ),
            2 => const Spacer(),
            3 => const Spacer(),
            int() => const Spacer()
          },
        ],
      ),
    );
  }
}
