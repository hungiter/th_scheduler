import 'package:flutter/material.dart';
import 'package:th_scheduler/data/room.dart';

class RoomBox extends StatefulWidget {
  final Rooms roomDetails;

  RoomBox({super.key, required this.roomDetails});

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

  void _onContainerTap() {}

  void _onEnter(bool hovering) {
    setState(() {
      _isHovered = hovering;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (_) => _onEnter(true),
        onExit: (_) => _onEnter(false),
        child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: InkWell(
                onTap: _onContainerTap,
                borderRadius: BorderRadius.circular(15.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
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
                                fontWeight: FontWeight.bold, fontSize: 24),
                          )),
                      Icon((roomDetails.roomType == 0)
                          ? Icons.hotel
                          : (roomDetails.roomType == 1)
                              ? Icons.single_bed
                              : Icons.bed),
                    ],
                  ),
                ))));
  }
}
