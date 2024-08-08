import "dart:math";

import "package:flutter/material.dart";
import "package:th_scheduler/data/room.dart";
import "package:th_scheduler/pages/responsive/main_drawer.dart";
import "package:th_scheduler/pages_components/history_boxes.dart";
import "package:th_scheduler/pages_components/room_boxes.dart";

import "package:th_scheduler/pages/responsive/homepage_constant.dart";
import "package:th_scheduler/services/notify_services.dart";
import "package:th_scheduler/utilities/firestore_handler.dart";
import "package:th_scheduler/utilities/testing_datas.dart";

import "package:th_scheduler/data/history.dart";

class DesktopHome extends StatefulWidget {
  @override
  _DesktopHomeState createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
  late int currentPage;

  Rooms? selectionRoom;
  List<Rooms> rooms = [];

  late Histories selectionHistory;
  late List<Histories> histories;

  final FirestoreHandler _firestoreHandler = FirestoreHandler();

  NotifyServices notifyServices = NotifyServices();

  @override
  void initState() {
    super.initState();
    refreshRoomsAndHistory();

    setState(() {
      currentPage = 0;
    });
  }

  void _currentPage(int pageId) {
    setState(() {
      currentPage = pageId;
    });
  }

  Future<void> refreshRoomsAndHistory() async {
    await fetchAllRooms();
    await fetchAllHistories();
  }

  Future<void> fetchAllRooms() async {
    await _firestoreHandler.getAvailableRooms(errorCallBack: (e) {
      notifyServices.showErrorToast(e);
    }, successCallback: (fsRooms) {
      setState(() {
        rooms = fsRooms;
        selectionRoom = rooms[0];
      });
    });
  }

  Future<void> fetchAllHistories() async {
    await _firestoreHandler.getUserHistories((e) {
      notifyServices.showErrorToast(e);
    }, (fsHistories) {
      if (fsHistories.isNotEmpty) {
        setState(() {
          histories = fsHistories;
          selectionHistory = histories[0];
        });
      }
    });
  }

  void displayRooms(Rooms room) {
    setState(() {
      selectionRoom = room;
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
            0 => (rooms.isEmpty)
                ? emptyExpand
                : Expanded(
                    child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            final room = rooms[index];
                            return RoomBox(
                              room: room,
                              onTap: displayRooms,
                            );
                          },
                        ),
                      ),
                      Expanded(
                          child: RoomDetailBox(
                        room: selectionRoom,
                        pageRefresh: refreshRoomsAndHistory,
                      ))
                    ],
                  )),
            1 => (histories.isEmpty)
                ? emptyExpand
                : Expanded(
                    child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: histories.length,
                          itemBuilder: (context, index) {
                            final history = histories[index];
                            return HistoryBox(
                              history: history,
                              onTap: displayHistory,
                            );
                          },
                        ),
                      ),
                      Expanded(
                          child: HistoryDetailBox(
                        history: selectionHistory,
                        pageRefresh: refreshRoomsAndHistory,
                      ))
                    ],
                  )),
            2 => const Spacer(),
            3 => const Spacer(),
            int() => const Spacer()
          },
        ],
      ),
    );
  }
}
