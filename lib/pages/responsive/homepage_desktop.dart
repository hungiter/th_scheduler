import "package:flutter/material.dart";
import "package:th_scheduler/data/room.dart";
import "package:th_scheduler/pages/responsive/homepage_components.dart";

import "package:th_scheduler/pages/responsive/homepage_constant.dart";

class DesktopHome extends StatefulWidget {
  @override
  _DesktopHomeState createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: desktopBackground,
      body: Row(
        children: [
          // Visible drawer
          myDrawer,
          Expanded(
              child: Container(
                  padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
                  child: Column(
                    children: [
                      Expanded(
                          child: ListView.builder(
                              itemCount: 25,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Expanded(
                                        child: RoomBox(
                                            roomDetails:
                                                Rooms.init(index * 4 + 1))),
                                    Expanded(
                                        child: RoomBox(
                                            roomDetails:
                                                Rooms.init(index * 4 + 2))),
                                    Expanded(
                                        child: RoomBox(
                                            roomDetails:
                                                Rooms.init(index * 4 + 3))),
                                    Expanded(
                                        child: RoomBox(
                                            roomDetails:
                                                Rooms.init(index * 4 + 4)))
                                  ],
                                );
                              }))
                    ],
                  )))
        ],
      ),
    );
  }
}
