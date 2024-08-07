import "package:flutter/material.dart";

import "package:th_scheduler/pages/responsive/homepage_constant.dart";

import "package:th_scheduler/data/room.dart";
import "../../pages_components/room_boxes.dart";

class TabletHome extends StatefulWidget {
  @override
  _TabletHomeState createState() => _TabletHomeState();
}

class _TabletHomeState extends State<TabletHome> {
  void displayDialog(Rooms rooms) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: myAppBar,
        backgroundColor: tabletBackground,
        drawer: myDrawer,
        body: Container(
          padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
          child: Column(
            children: [
              AspectRatio(
                  aspectRatio: 4,
                  child: SizedBox(
                      width: double.maxFinite,
                      child: GridView.builder(
                          itemCount: 4,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4),
                          itemBuilder: (context, index) {
                            return RoomBox(
                                roomDetails: Rooms.init(index + 1),
                                onTap: displayDialog);
                          }))),
              Expanded(
                  child: ListView.builder(
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return RoomBox(
                            roomDetails: Rooms.init(index + 5),
                            onTap: displayDialog);
                      }))
            ],
          ),
        ));
  }
}
