import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:th_scheduler/data/room.dart';
import 'package:th_scheduler/pages/responsive/homepage_constant.dart';
import 'package:th_scheduler/pages_components/customDatePicker.dart';
import 'package:th_scheduler/pages_components/custom_buttons.dart';
import 'package:th_scheduler/services/notify_services.dart';
import 'package:th_scheduler/utilities/bug_handler.dart';
import 'package:th_scheduler/utilities/datetime_helper.dart';
import 'package:th_scheduler/utilities/firestore_handler.dart';
import 'package:th_scheduler/utilities/realtime_handler.dart';
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

  @override
  void didUpdateWidget(RoomBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.room != widget.room) {
      setState(() {
        room = widget.room;
      });
    }
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
              child: buildRoomBox(),
            ),
          )
        : GestureDetector(
            onTapDown: (_) => _onEnter(true),
            onTapUp: (_) => _onEnter(false),
            onTapCancel: () => _onEnter(false),
            child: buildRoomBox(),
          );
  }

  Widget buildRoomBox() {
    Color color =
        switch (room.opened) { true => Colors.green, false => Colors.grey };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: (room.opened) ? _onContainerTap : null,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
          decoration: BoxDecoration(
            color: (!room.opened)
                ? color
                : _isHovered
                    ? color.withAlpha(222)
                    : color,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.white, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12.0,
                offset: Offset(0, 8),
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
  final bool isDialog;
  final Rooms? room;
  final Function() pageRefresh; // Accepts a callback function

  RoomDetailBox(
      {super.key,
      required this.isDialog,
      required this.room,
      required this.pageRefresh});

  @override
  _RoomDetailBoxState createState() => _RoomDetailBoxState();
}

class _RoomDetailBoxState extends State<RoomDetailBox> {
  late Rooms? room;
  bool onProcess = false;
  String error = "";

  final List<DateTime> _availableDates = [];
  DateTime? _selectedDate;

  DatetimeHelper datetimeHelper = DatetimeHelper();
  NotifyServices notifyServices = NotifyServices();
  final FirestoreHandler _firestoreHandler = FirestoreHandler();
  final RealtimeDatabaseHandler _databaseHandler = RealtimeDatabaseHandler();

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

  void createSuccess() {
    notifyServices.showMessage("Đặt phòng thành công");
    widget.pageRefresh();
  }

  Future<void> createOrder() async {
    setState(() {
      onProcess = true;
    });

    String e = "";
    if (_selectedDate != null) {
      DateTime currDate = _selectedDate!;
      String roomId = room!.id;

      await _firestoreHandler.roomOrderAndCreateHistory(roomId, currDate,
          (error) {
        e = BugHandler.bugString(error);
      }, (docId) async {
        createSuccess();
        _databaseHandler.saveNewHistoryQR(docId, 0);
      });
    }

    if (e.isNotEmpty) {
      setState(() {
        error = e;
      });
      return;
    }

    setState(() {
      onProcess = false;
    });
  }

  Widget roomDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      insetPadding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Exit Button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ),
              const SizedBox(height: 8.0),

              // Room title and image container
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: containerDecorations[1],
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
              const SizedBox(height: 16.0),

              if (room != null)
                Container(
                  decoration: containerDecorations[2],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildTitleAndValueTextRow("Phòng:", room!.id),
                        buildTitleAndValueTextRow(
                            "Kiểu:", room!.roomTypeToString()),
                        buildTitleAndValueTextRow(
                            "Giá / Ngày:", "${room!.priceByRoomType()} VNĐ"),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Date picker and action button
              Container(
                decoration: containerDecorations[3],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyDatePicker(
                        setAsDefault: false,
                        enable: true,
                        dates: _availableDates,
                        onDateSelected: _datetimeStateChange,
                      ),
                      const SizedBox(height: 8),
                      if (error.isNotEmpty)
                        Text(error, textAlign: TextAlign.center),
                      if (!onProcess)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: UIActionButton(
                            enable: !onProcess,
                            actionId: -1,
                            onPressed: () async {
                              setState(() {
                                error = "";
                                onProcess = true;
                              });

                              await createOrder();

                              // Close the dialog after order creation is complete
                              Navigator.of(context).pop();
                            },
                          ),
                        )
                      else
                        const Text("Đang xử lí", textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget roomBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: null, // You can add functionality here if needed
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: containerDecorations[0],
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
                        decoration: containerDecorations[1],
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

                  const SizedBox(height: 20),
                  (room == null)
                      ? const SizedBox.shrink()
                      : Container(
                          decoration: containerDecorations[2],
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
                            ),
                          ),
                        ),

                  // Align content at the bottom center
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: containerDecorations[3],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              // Adjust to fit the width of the container
                              child: MyDatePicker(
                                setAsDefault: false,
                                enable: true,
                                dates: _availableDates,
                                onDateSelected: _datetimeStateChange,
                              ),
                            ),
                            const SizedBox(height: 8),
                            (error.isNotEmpty)
                                ? Text(error, textAlign: TextAlign.center)
                                : (onProcess)
                                    ? const Text("Đang xử lí",
                                        textAlign: TextAlign.center)
                                    : Align(
                                        alignment: Alignment.bottomRight,
                                        child: UIActionButton(
                                          enable: !onProcess,
                                          actionId: -1,
                                          onPressed: () async {
                                            setState(() {
                                              error = "";
                                            });
                                            await createOrder();
                                          },
                                        ),
                                      ),
                          ],
                        ),
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

  @override
  Widget build(BuildContext context) {
    return (widget.isDialog) ? roomDialog(context) : roomBox(context);
  }
}
