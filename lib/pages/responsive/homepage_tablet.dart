import "package:flutter/material.dart";

import "package:th_scheduler/pages/responsive/homepage_constant.dart";

import "package:th_scheduler/data/room.dart";
import "homepage_components.dart";

class TabletHome extends StatefulWidget {
  @override
  _TabletHomeState createState() => _TabletHomeState();
}

class _TabletHomeState extends State<TabletHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: myAppBar,
        backgroundColor: tabletBackground,
        drawer: myDrawer,
        body: Container(
          padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
          child: Column(
            children: [
              Expanded(
                  child: ListView.builder(
                      itemCount: 50,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Expanded(
                                child: RoomBox(
                                    roomDetails: Rooms.init(index * 2 + 1))),
                            Expanded(
                                child: RoomBox(
                                    roomDetails: Rooms.init(index * 2 + 2)))
                          ],
                        );
                      }))
            ],
          ),
        ));
  }
}
