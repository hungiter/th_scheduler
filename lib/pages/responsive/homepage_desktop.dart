import "dart:math";

import "package:flutter/material.dart";
import "package:th_scheduler/data/room.dart";
import "package:th_scheduler/pages/responsive/main_drawer.dart";
import "package:th_scheduler/pages_components/boxes_history.dart";
import "package:th_scheduler/pages_components/boxes_room.dart";

import "package:th_scheduler/pages/responsive/homepage_constant.dart";
import "package:th_scheduler/services/notify_services.dart";
import "package:th_scheduler/utilities/bug_handler.dart";
import "package:th_scheduler/utilities/firestore_handler.dart";

import "package:th_scheduler/data/history.dart";

class DesktopHome extends StatefulWidget {
  @override
  _DesktopHomeState createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
  int currentPage = 0;

  Rooms? selectionRoom;
  List<Rooms> rooms = [];

  Histories? selectionHistory;
  List<Histories> histories = [];

  bool dataOnload = true;
  final FirestoreHandler _firestoreHandler = FirestoreHandler();

  NotifyServices notifyServices = NotifyServices();

  @override
  void initState() {
    super.initState();
    _currentPage(currentPage);
  }

  Future<void> _currentPage(int pageId) async {
    await switch (pageId) {
      0 => refreshRoom(),
      1 => refreshHistory(),
      int() => throw UnimplementedError(),
    };

    setState(() {
      currentPage = pageId;
    });
  }

  Future<void> refreshRoom() async {
    setState(() {
      dataOnload = true;
    });
    try {
      List<Rooms> allrooms = await fetchAllRooms();
      setState(() {
        rooms = allrooms;
        selectionRoom = rooms.isNotEmpty ? rooms[0] : null;
      });
    } catch (e) {
      // Handle any exceptions that might occur during the refresh process
      notifyServices.showErrorToast(e.toString());
    }
    setState(() {
      dataOnload = false;
    });
  }

  Future<void> refreshHistory() async {
    setState(() {
      dataOnload = true;
    });
    try {
      List<Histories> myHistories = await fetchAllHistories();
      setState(() {
        histories = myHistories;
        selectionHistory = histories.isNotEmpty ? histories[0] : null;
      });
    } catch (e) {
      // Handle any exceptions that might occur during the refresh process
      notifyServices.showErrorToast(e.toString());
    }
    setState(() {
      dataOnload = false;
    });
  }

  Future<void> refreshAll() async {
    await refreshRoom();
    await refreshHistory();
  }

  Future<List<Rooms>> fetchAllRooms() async {
    List<Rooms> allrooms = [];
    try {
      await _firestoreHandler.getAvailableRooms(errorCallBack: (e) {
        notifyServices.showErrorToast(e);
      }, successCallback: (fsRooms) {
        allrooms = fsRooms;
      });
    } catch (e) {
      notifyServices.showErrorToast(e.toString());
    }
    return allrooms;
  }

  Future<List<Histories>> fetchAllHistories() async {
    List<Histories> myHistories = [];
    try {
      await _firestoreHandler.getUserHistories((e) {
        notifyServices.showErrorToast(BugHandler.bugString(e));
      }, (fsHistories) {
        myHistories = fsHistories;
      });
    } catch (e) {
      notifyServices.showErrorToast(e.toString());
    }

    return myHistories;
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
          MyDrawer(selected: currentPage, onSelect: _currentPage),

          switch (currentPage) {
            0 => (dataOnload)
                ? circularEmpty
                : (rooms.isEmpty)
                    ? textEmpty
                    : Expanded(
                        child: Row(
                        children: <Widget>[
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
                            pageRefresh: () async {
                              await _currentPage(1);
                            },
                          ))
                        ],
                      )),
            1 => (dataOnload)
                ? circularEmpty
                : (histories.isEmpty)
                    ? textEmpty
                    : Expanded(
                        child: Row(
                        children: <Widget>[
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
                            pageRefresh: () async {
                              await refreshAll();
                            },
                            historyRefresh: () async {
                              await refreshHistory();
                            },
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
