import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:th_scheduler/data/history.dart';
import 'package:th_scheduler/pages/responsive/homepage_constant.dart';
import 'package:th_scheduler/services/notify_services.dart';
import 'package:th_scheduler/utilities/datetime_helper.dart';
import 'package:th_scheduler/utilities/firestore_handler.dart';

import 'customDatePicker.dart';
import 'custom_buttons.dart';
import 'custom_rows.dart';

class HistoryBox extends StatefulWidget {
  final Histories history;
  final Function(Histories) onTap; // Accepts a callback function

  HistoryBox({super.key, required this.history, required this.onTap});

  @override
  _HistoryBoxState createState() => _HistoryBoxState();
}

class _HistoryBoxState extends State<HistoryBox> {
  late Histories history;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    history = widget.history;
  }

  void _onContainerTap() {
    widget.onTap(history); // Invokes the callback with History details
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
              child: buildHistoryBox(),
            ),
          )
        : GestureDetector(
            onTap: _onContainerTap,
            onTapDown: (_) => _onEnter(true),
            onTapUp: (_) => _onEnter(false),
            onTapCancel: () => _onEnter(false),
            child: buildHistoryBox(),
          );
  }

  Widget buildHistoryBox() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: _onContainerTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTitleAndValueTextRow(history.id, history.statusToString())
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryDetailBox extends StatefulWidget {
  final Histories? history;
  final Function() pageRefresh; // Accepts a callback function

  HistoryDetailBox(
      {super.key, required this.history, required this.pageRefresh});

  @override
  _HistoryDetailBoxState createState() => _HistoryDetailBoxState();
}

class _HistoryDetailBoxState extends State<HistoryDetailBox> {
  late Histories? history;

  final List<DateTime> _availableDates = [];
  DateTime? _selectedDate;
  DatetimeHelper datetimeHelper = DatetimeHelper();
  NotifyServices notifyServices = NotifyServices();
  final FirestoreHandler _firestoreHandler = FirestoreHandler();
  int status = -2;

  @override
  void initState() {
    super.initState();
    history = widget.history;
    _generateDateList();
  }

  @override
  void didUpdateWidget(HistoryDetailBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.history != widget.history) {
      setState(() {
        history = widget.history;
        status = history!.status;
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
                            "Phòng ${history!.roomId}",
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
                  (history == null)
                      ? const SizedBox.shrink()
                      : Container(
                          decoration: dialogContainersDecoration[2],
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  buildTitleAndValueTextRow(
                                      "Phòng:", history!.roomId),
                                  buildTitleAndValueTextRow(
                                      "Từ:",
                                      datetimeHelper
                                          .dtString(history!.fromDate)),
                                  (history!.toDate != null)
                                      ? buildTitleAndValueTextRow(
                                          "Đến: ",
                                          datetimeHelper
                                              .dtString(history!.toDate!))
                                      : const SizedBox(),
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
                              setAsDefault: true,
                              dates: _availableDates,
                              onDateSelected: _datetimeStateChange,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                              alignment: Alignment.bottomRight,
                              child: Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    (status == 0 || history!.toDate == null)
                                        ? RoomActionButton(
                                            actionId: 0,
                                            onPressed: () async {},
                                          )
                                        : const SizedBox(),
                                    (status == 0 || history!.toDate == null)
                                        ? const SizedBox(width: 8)
                                        : const SizedBox(),
                                    (status == 0 || history!.toDate == null)
                                        ? RoomActionButton(
                                            actionId: 1,
                                            onPressed: () async {},
                                          )
                                        : const SizedBox(),
                                    // Status == 1 => On use
                                    (status == 2)
                                        ? RoomActionButton(
                                            actionId: 2,
                                            onPressed: () async {},
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              )),
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
