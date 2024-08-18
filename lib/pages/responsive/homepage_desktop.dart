import "dart:math";

import "package:flutter/material.dart";
import "package:th_scheduler/data/room.dart";
import "package:th_scheduler/pages/responsive/main_drawer.dart";
import "package:th_scheduler/pages_components/boxes_history.dart";
import "package:th_scheduler/pages_components/boxes_room.dart";

import "package:th_scheduler/pages/responsive/homepage_constant.dart";
import "package:th_scheduler/pages_components/custom_buttons.dart";
import "package:th_scheduler/pages_components/custom_dropdowns.dart";
import "package:th_scheduler/services/notify_services.dart";
import "package:th_scheduler/utilities/bug_handler.dart";
import "package:th_scheduler/utilities/firestore_handler.dart";

import "package:th_scheduler/data/history.dart";
import "package:th_scheduler/utilities/realtime_handler.dart";

class DesktopHome extends StatefulWidget {
  @override
  _DesktopHomeState createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
  int currentPage = 0;
  bool dataOnload = true;
  NotifyServices notifyServices = NotifyServices();
  final FirestoreHandler _firestoreHandler = FirestoreHandler();
  final RealtimeDatabaseHandler _databaseHandler = RealtimeDatabaseHandler();

  Rooms? selectionRoom;
  List<Rooms> rooms = [];
  int rFilter = -1;
  bool rEnd = false;
  bool rLoad = false;
  final int rLimit = 20;
  final ScrollController _roomsScrollController = ScrollController();

  Histories? selectionHistory;
  static const hLimit = 5;
  static const List<String> statusKeys = [
    "cancel",
    "in-order",
    "in-use",
    "finish"
  ];

  Map<String, List<Histories>> mapHistories = {
    for (var key in statusKeys) key: []
  };
  List<bool> hEnds = List.filled(4, false);
  List<bool> hLoads = List.filled(4, false);
  List<bool> hDeletes = List.filled(4, false);

  @override
  void initState() {
    super.initState();
    _currentPage(currentPage);

    _roomsScrollController.addListener(() async {
      if (_roomsScrollController.position.pixels >=
          _roomsScrollController.position.maxScrollExtent - 200) {
        await _fetchMoreRooms();
      }
    });
  }

  Future<void> _currentPage(int pageId) async {
    setState(() {
      currentPage = pageId;
    });

    await switch (currentPage) {
      0 => _refreshRoomInitData(),
      1 => _refreshHistoriesInitData(),
      int() => throw UnimplementedError(),
    };
  }

  // ROOMS-CONTROLLER===========================================================
  void roomTypeChanged(int type) async {
    if (type != rFilter) {
      setState(() {
        rFilter = type;
      });

      await _refreshRoomInitData();
    }
  }

  Future<void> _refreshRoomInitData() async {
    setState(() {
      rLoad = true;
      dataOnload = true;
      rEnd = false;
      rooms = [];
    });

    await _fetchMoreRooms();

    setState(() {
      rLoad = false;
      dataOnload = false;
    });
  }

  Future<void> _fetchMoreRooms() async {
    if (rEnd) {
      return;
    }

    setState(() {
      rLoad = true;
    });

    try {
      List<Rooms> currRooms = rooms;
      List<Rooms> lRooms = await fetchRoomsByLimit();
      if (lRooms.isNotEmpty) {
        List<Rooms> filterExisted = lRooms.where((element) {
          return !rooms.any((room) => room.id == element.id);
        }).toList();

        if (filterExisted.isNotEmpty) {
          currRooms.addAll(filterExisted);
          setState(() {
            rooms = currRooms;
          });
        }
      } else {
        setState(() {
          rEnd = true;
        });
      }
    } catch (e) {
      notifyServices.showErrorToast(e.toString());
    }

    setState(() {
      rLoad = false;
      selectionRoom = null;
    });
  }

  Future<List<Rooms>> fetchRoomsByLimit() async {
    List<Rooms> newRooms = [];

    try {
      await _firestoreHandler.fetchRoomsByLimit(
          filterType: rFilter,
          lastRooms: (rooms.isNotEmpty) ? rooms.last : null,
          limit: rLimit,
          errorCallBack: (e) {
            notifyServices.showErrorToast(e);
            return;
          },
          successCallback: (fsRooms) {
            newRooms = fsRooms;
          });
    } catch (e) {
      notifyServices.showErrorToast(e.toString());
    }

    return newRooms;
  }

  void displayRoom(Rooms room) {
    setState(() {
      selectionRoom = room;
    });
  }

  // HISTORIES-CONTROLLER=======================================================
  void _resetHistoriesState() {
    setState(() {
      mapHistories = {for (var key in statusKeys) key: []};
      hEnds = List.filled(4, false);
      hLoads = List.filled(4, false);
      hDeletes = List.filled(4, false);
    });
  }

  Future<void> _refreshHistoriesInitData() async {
    setState(() {
      dataOnload = true;
    });
    _resetHistoriesState();

    for (int i = -1; i <= 2; i++) {
      await _fetchMoreHistories(i);
    }

    setState(() {
      dataOnload = false;
      selectionHistory = null;
    });
  }

  void _updateHEndsIndex(int index, bool value) {
    setState(() {
      hEnds[index] = value;
    });
  }

  void _updateHLoadsIndex(int index, bool value) {
    setState(() {
      hLoads[index] = value;
    });
  }

  void _updateHDeletesIndex(int index, bool value) {
    setState(() {
      hDeletes[index] = value;
    });
  }

  Future<void> _fetchMoreHistories(int status) async {
    String keyMap = _hStatusToKeyMap(status);

    if (hEnds[status + 1]) return;

    _updateHLoadsIndex(status + 1, true);
    try {
      List<Histories> currHistories = mapHistories[keyMap] ?? [];
      Histories? last = (currHistories.isNotEmpty) ? currHistories.last : null;
      await _firestoreHandler.fetchHistoriesByLimit(
          filterStatus: status,
          lastHistory: last,
          limit: hLimit,
          errorCallBack: (error) {
            notifyServices.showAlert(error);
          },
          successCallback: (nextHistories) {
            _handleNewHistories(currHistories, nextHistories, status);
          });

      _updateHLoadsIndex(status + 1, false);
    } catch (e) {
      notifyServices.showErrorToast(e.toString());
    }
  }

  void _handleNewHistories(List<Histories> currHistories,
      List<Histories> nextHistories, int status) {
    List<Histories> filterExisted = nextHistories.where((element) {
      return !currHistories.any((history) => history.id == element.id);
    }).toList();

    if (filterExisted.isNotEmpty) {
      setState(() {
        currHistories.addAll(filterExisted);
        mapHistories[_hStatusToKeyMap(status)] = currHistories;
      });

      if (filterExisted.length < hLimit) {
        _updateHEndsIndex(status + 1, true);
      }
    } else {
      _updateHEndsIndex(status + 1, true);
    }
  }

  void _clearHistorySelection() {
    setState(() {
      selectionHistory = null;
    });
  }

  Future<void> _clearHistory(int status) async {
    String keyMap = _hStatusToKeyMap(status);
    _updateHDeletesIndex(status + 1, true);
    try {
      for (var history in mapHistories[keyMap]!) {
        await _databaseHandler.removeHistoryQR(history.docId);
      }

      await _firestoreHandler.clearHistories(
          filterStatus: status,
          errorCallBack: (error) {
            notifyServices.showAlert(error);
          },
          successCallback: () {
            setState(() {
              mapHistories[keyMap] = [];
            });
          });
    } catch (e) {
      notifyServices.showErrorToast(e.toString());
    }
    _clearHistorySelection();
    _updateHDeletesIndex(status + 1, false);
    _updateHEndsIndex(status + 1, false);
  }

  String _hStatusToKeyMap(int status) {
    return switch (status) {
      -1 => "cancel",
      0 => "in-order",
      1 => "in-use",
      2 => "finish",
      int() => "",
    };
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
                            (rLoad && dataOnload)
                                ? circularEmpty
                                : Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SingleChildScrollView(
                                        controller: _roomsScrollController,
                                        child: Column(
                                          children: [
                                            // Room type dropdown
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: RoomTypeDropdown(
                                                currentFilter: rFilter,
                                                onRoomTypeSelected:
                                                    roomTypeChanged,
                                              ),
                                            ),
                                            const SizedBox(height: 8.0),

                                            // Room list
                                            ListView.builder(
                                              shrinkWrap: true,
                                              // Use shrinkWrap to allow ListView to take up only as much space as needed
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              // Disable internal ListView scrolling
                                              itemCount: rooms.length,
                                              itemBuilder: (context, index) {
                                                final room = rooms[index];
                                                return RoomBox(
                                                  room: room,
                                                  onTap: (cRoom) {
                                                    displayRoom(cRoom);
                                                  },
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 8.0),
                                            (rLoad)
                                                ? const CircularProgressIndicator()
                                                : (rEnd)
                                                    ? Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: UIActionButton(
                                                            enable: true,
                                                            actionId: 3,
                                                            onPressed:
                                                                _refreshRoomInitData))
                                                    : const SizedBox(
                                                        height: 8.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                            (rLoad)
                                ? waitingLoad
                                : (selectionRoom == null)
                                    ? roomSelectedEmpty
                                    : Expanded(
                                        child: RoomDetailBox(
                                        isDialog: false,
                                        room: selectionRoom,
                                        pageRefresh: () async {
                                          await _currentPage(1);
                                        },
                                      ))
                          ],
                        ),
                      ),
            1 => dataOnload
                ? circularEmpty
                : (mapHistories.values.every((list) => list.isEmpty))
                    ? textEmpty
                    : Expanded(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (int i = 0;
                                          i < statusKeys.length;
                                          i++)
                                        HistoryCategoryList(
                                          statusCode: i - 1,
                                          categoryKey: _hStatusToKeyMap(i - 1),
                                          mapHistories: mapHistories,
                                          hEnds: hEnds,
                                          hLoads: hLoads,
                                          hDeletes: hDeletes,
                                          onClearHistory: _clearHistory,
                                          onLoadMore: _fetchMoreHistories,
                                          onSelectHistory: displayHistory,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            (selectionHistory == null)
                                ? historySelectedEmpty
                                : Expanded(
                                    child: HistoryDetailBox(
                                      isDialog: false,
                                      history: selectionHistory,
                                      historyRefresh: _refreshHistoriesInitData,
                                    ),
                                  ),
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
