import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:th_scheduler/data/history.dart';
import 'package:th_scheduler/pages/responsive/homepage_constant.dart';
import 'package:th_scheduler/services/notify_services.dart';
import 'package:th_scheduler/utilities/bug_handler.dart';
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

  @override
  void didUpdateWidget(HistoryBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.history != widget.history) {
      setState(() {
        history = widget.history;
      });
    }
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
    Color color = switch (history.status) {
      -1 => Colors.red,
      0 => Colors.yellow,
      2 => Colors.green,
      1 => Colors.blue,
      int() => Colors.white
    };

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        onTap: _onContainerTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: _isHovered ? color.withAlpha(141) : color,
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
              buildTitleAndValueTextRow(history.docId, history.statusToString())
            ],
          ),
        ),
      ),
    );
  }
}

class HistoryDetailBox extends StatefulWidget {
  final Histories? history;
  final Function() historyRefresh;
  final Function() pageRefresh;

  HistoryDetailBox(
      {super.key,
      required this.history,
      required this.historyRefresh,
      required this.pageRefresh});

  @override
  _HistoryDetailBoxState createState() => _HistoryDetailBoxState();
}

class _HistoryDetailBoxState extends State<HistoryDetailBox> {
  late Histories? history;
  late int status;
  bool onProcess = false;

  final List<DateTime> _availableDates = [];
  DateTime? _selectedDate;
  DatetimeHelper datetimeHelper = DatetimeHelper();
  NotifyServices notifyServices = NotifyServices();
  final FirestoreHandler _firestoreHandler = FirestoreHandler();

  @override
  void initState() {
    super.initState();
    history = widget.history;
    status = history!.status;
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

  void deleteSuccess() {
    notifyServices.showMessage("Xoá lịch sử thành công");
    widget.historyRefresh();
  }

  Future<void> deleteAction() async {
    setState(() {
      onProcess = true;
    });

    String error = "";
    await _firestoreHandler.userDeleteHistory(history!.docId, (eCode) {
      error = BugHandler.bugString(eCode);
    }, () => deleteSuccess());

    if (error.isNotEmpty) {
      notifyServices.showErrorToast(error);
      return;
    }

    setState(() {
      onProcess = false;
    });
  }

  Future<void> onScheduleAction() async {
    widget.historyRefresh();
  }

  void cancelSuccess() {
    notifyServices.showMessage("Huỷ lịch thành công");
    widget.pageRefresh();
  }

  Future<void> onCancelAction() async {
    setState(() {
      onProcess = true;
    });

    String error = "";
    await _firestoreHandler.userCancelHistory(history!.docId, history!.roomId,
        (eCode) {
      error = BugHandler.bugString(eCode);
    }, () => cancelSuccess());
    if (error.isNotEmpty) {
      notifyServices.showErrorToast(error);
      return;
    }

    setState(() {
      onProcess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: null, // You can add functionality here if needed
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: dialogContainersDecoration[0],
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 2,
              child: SizedBox(
                width: double.infinity,
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

            const SizedBox(height: 20),
            (history == null)
                ? const SizedBox.shrink()
                : Container(
                    decoration: dialogContainersDecoration[2],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          buildTitleAndValueTextRow("Phòng:", history!.roomId),
                          buildTitleAndValueTextRow("Ngày bắt đầu:",
                              datetimeHelper.dtString(history!.fromDate)),
                          if (history!.toDate != null)
                            buildTitleAndValueTextRow("Ngày kết thúc:",
                                datetimeHelper.dtString(history!.toDate!)),
                          if (status == 1)
                            buildTitleAndValueTextRow(
                                "Trạng thái:", history!.statusToString()),
                        ],
                      ),
                    ),
                  ),

            // Align content at the bottom center
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: dialogContainersDecoration[3],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: MyDatePicker(
                          setAsDefault: true,
                          enable: false,
                          dates: _availableDates,
                          onDateSelected: _datetimeStateChange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (status == 0)
                            Row(
                              children: [
                                RoomActionButton(
                                  enable: !onProcess,
                                  actionId: 0,
                                  onPressed: () async {
                                    await onCancelAction();
                                  },
                                ),
                                RoomActionButton(
                                  enable: !onProcess,
                                  actionId: 1,
                                  onPressed: () async {
                                    await onScheduleAction();
                                  },
                                ),
                              ],
                            ),
                          if (status == 2 || status == -1)
                            RoomActionButton(
                              enable: !onProcess,
                              actionId: 2,
                              onPressed: () async {
                                await deleteAction();
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
