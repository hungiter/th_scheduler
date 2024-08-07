import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:th_scheduler/data/room.dart';

import 'custom_rows.dart';

class RoomBox extends StatefulWidget {
  final Rooms roomDetails;
  final Function(Rooms) onTap; // Accepts a callback function

  RoomBox({super.key, required this.roomDetails, required this.onTap});

  @override
  _RoomBoxState createState() => _RoomBoxState();
}

class _RoomBoxState extends State<RoomBox> {
  late Rooms roomDetails;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    roomDetails = widget.roomDetails;
  }

  void _onContainerTap() {
    widget.onTap(roomDetails); // Invokes the callback with room details
  }

  void _onEnter(bool hovering) {
    setState(() {
      _isHovered = hovering;
    });
  }

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? MouseRegion(
            onEnter: (_) => _onEnter(true),
            onExit: (_) => _onEnter(false),
            child: GestureDetector(
              onTap: _onContainerTap,
              child: buildRoomBox(),
            ),
          )
        : GestureDetector(
            onTap: _onContainerTap,
            onTapDown: (_) => _onEnter(true),
            onTapUp: (_) => _onEnter(false),
            onTapCancel: () => _onEnter(false),
            child: buildRoomBox(),
          );
  }

  Widget buildRoomBox() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: _onContainerTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.blue[700] : Colors.blueAccent,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(color: Colors.white, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Phòng ${roomDetails.id}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              Icon(
                (roomDetails.roomType == 0)
                    ? Icons.hotel
                    : (roomDetails.roomType == 1)
                        ? Icons.single_bed
                        : Icons.bed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoomDetailBox extends StatefulWidget {
  final Rooms roomDetails;

  RoomDetailBox({super.key, required this.roomDetails});

  @override
  _RoomDetailBoxState createState() => _RoomDetailBoxState();
}

class _RoomDetailBoxState extends State<RoomDetailBox> {
  late Rooms roomDetails;

  @override
  void initState() {
    super.initState();
    roomDetails = widget.roomDetails;
  }

  @override
  void didUpdateWidget(RoomDetailBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roomDetails != widget.roomDetails) {
      setState(() {
        roomDetails = widget.roomDetails;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: InkWell(
        onTap: null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AspectRatio(
                aspectRatio: 2,
                child: SizedBox(
                  width: double.maxFinite,
                  height: 100.0,
                  child: Container(
                      color: Colors.black,
                      // Set your desired background color here
                      padding: const EdgeInsets.all(8.0),
                      // Optional: Add padding if needed
                      child: Center(
                        child: Text(
                          "Phòng ${roomDetails.id}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      )),
                ),
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildTitleAndValueTextRow("Phòng:", roomDetails.id),
                  buildTitleAndValueTextRow(
                      "Kiểu: ", roomDetails.roomTypeToString()),
                  buildTitleAndValueTextRow(
                      "Giá / Ngày: ", "${roomDetails.pricePerDay} VNĐ"),
                  buildTitleAndValueTextRow(
                      "Trạng thái:", (roomDetails.opened) ? "Mở" : "Đóng")
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
