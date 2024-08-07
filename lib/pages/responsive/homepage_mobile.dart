import "package:flutter/material.dart";
import "package:th_scheduler/pages/responsive/homepage_constant.dart";
import "package:th_scheduler/data/models.dart";
import "package:th_scheduler/utilities/firestore_handler.dart";
import "../../pages_components/room_boxes.dart";

class MobileHome extends StatefulWidget {
  @override
  _MobileHomeState createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  late List<Rooms> roomList = [];
  final _fireStoreHandler = FirestoreHandler();

  @override
  void initState() {
    super.initState();
    initVariables();
  }

  Future<void> initVariables() async {
    List<Rooms> tmpList = await _fireStoreHandler.getTop10Rooms() ?? roomList;
    if (tmpList.isNotEmpty) {
      setState(() {
        roomList = tmpList;
      });
    }
  }

  void displayDialog(Rooms rooms) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: myAppBar,
        backgroundColor: mobileBackground,
        drawer: myDrawer,
        body: Container(
          padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
          child: Column(
            children: [
              // 4 ô trên đầu
              // SliverGridDelegateWithFixedCrossAxisCount row x col

              AspectRatio(
                  aspectRatio: 1,
                  child: SizedBox(
                      width: double.maxFinite,
                      child: GridView.builder(
                          itemCount: 4,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2),
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
