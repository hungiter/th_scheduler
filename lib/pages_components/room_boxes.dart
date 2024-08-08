import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:th_scheduler/data/room.dart';
import 'package:th_scheduler/pages/responsive/homepage_constant.dart';
import 'package:th_scheduler/pages_components/customDatePicker.dart';
import 'package:th_scheduler/pages_components/custom_buttons.dart';
import 'package:th_scheduler/services/notify_services.dart';
import 'package:th_scheduler/utilities/datetime_helper.dart';
import 'package:th_scheduler/utilities/firestore_handler.dart';
import 'custom_rows.dart';

class RoomBox extends StatefulWidget {
  final Rooms room;
  final Function(Rooms) onTap; // Accepts a callback function

  RoomBox({super.key, required this.room, required this.onTap});

  @override
  _RoomBoxState createState() => _RoomBoxState();
}

class _RoomBoxState extends State<RoomBox> {
  late Rooms room;
  bool _isHovered = false;
  final FirestoreHandler _firestoreHandler = FirestoreHandler();

  @override
  void initState() {
    super.initState();
    room = widget.room;
  }

  void _onContainerTap() {
    widget.onTap(room); // Invokes the callback with room details
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
                  "Phòng ${room.id}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              Icon(
                (room.roomType == 0)
                    ? Icons.hotel
                    : (room.roomType == 1)
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
  final Rooms? room;
  final Function() pageRefresh; // Accepts a callback function

  RoomDetailBox({super.key, required this.room, required this.pageRefresh});

  @override
  _RoomDetailBoxState createState() => _RoomDetailBoxState();
}

class _RoomDetailBoxState extends State<RoomDetailBox> {
  late Rooms? room;

  final List<DateTime> _availableDates = [];
  DateTime? _selectedDate;
  DatetimeHelper datetimeHelper = DatetimeHelper();
  NotifyServices notifyServices = NotifyServices();
  final FirestoreHandler _firestoreHandler = FirestoreHandler();

  @override
  void initState() {
    super.initState();
    room = widget.room;
    _generateDateList();
  }

  @override
  void didUpdateWidget(RoomDetailBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.room != widget.room) {
      setState(() {
        room = widget.room;
      });
    }
  }

  void _generateDateList() {
    DateTime tomorrow = DateTime.now().add(Duration(days: 1));
    for (int i = 0; i < 7; i++) {
      _availableDates.add(tomorrow.add(Duration(days: i)));
    }
    _selectedDate = _availableDates.first;
  }

  void _datetimeStateChange(String dateString) {
    datetimeHelper.stringToDatetime(dateString, (String error) {
      debugPrint('Error parsing date string: $error');
    }, (DateTime date) {
      setState(() {
        _selectedDate = date;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: null, // You can add functionality here if needed
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: dialogContainersDecoration[0],
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 2,
                    child: SizedBox(
                      width: double.maxFinite,
                      height: 100.0,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: dialogContainersDecoration[1],
                        child: Center(
                          child: Text(
                            "Phòng ${room!.id}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Expanded(
                  //     child:
                  (room == null)
                      ? const SizedBox.shrink()
                      : Container(
                          decoration: dialogContainersDecoration[2],
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  buildTitleAndValueTextRow("Phòng:", room!.id),
                                  buildTitleAndValueTextRow(
                                      "Kiểu:", room!.roomTypeToString()),
                                  buildTitleAndValueTextRow("Giá / Ngày:",
                                      "${room!.priceByRoomType()} VNĐ"),
                                ],
                              )),
                        ),
                  // ),
                  const SizedBox(height: 12),
                  // Align content at the bottom center
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            // Adjust to fit the width of the container
                            child: MyDatePicker(
                              setAsDefault: false,
                              dates: _availableDates,
                              onDateSelected: _datetimeStateChange,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: RoomActionButton(
                              actionId: -1,
                              onPressed: () async {
                                if (_selectedDate != null) {
                                  DateTime currDate = _selectedDate!;
                                  String roomId = room!.id;
                                  notifyServices
                                      .showMessage("$roomId-$currDate");
                                  await _firestoreHandler
                                      .createHistory(roomId, currDate, (error) {
                                    notifyServices.showErrorToast(error);
                                  }, widget.pageRefresh);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
