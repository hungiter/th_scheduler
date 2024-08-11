import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:th_scheduler/data/history.dart';
import 'package:th_scheduler/pages/responsive/homepage_constant.dart';
import 'package:th_scheduler/services/notify_services.dart';
import 'package:th_scheduler/utilities/bug_handler.dart';
import 'package:th_scheduler/utilities/datetime_helper.dart';
import 'package:th_scheduler/utilities/firestore_handler.dart';
import 'package:th_scheduler/utilities/qr_handler.dart';

import 'customDatePicker.dart';
import 'custom_buttons.dart';
import 'custom_rows.dart';

class HistoryCategoryList extends StatelessWidget {
  final int statusCode;
  final String categoryKey;
  final Map<String, List<Histories>> mapHistories;
  final List<bool> hEnds;
  final List<bool> hLoads;
  final List<bool> hDeletes;
  final Future<void> Function(int) onClearHistory;
  final Future<void> Function(int) onLoadMore;
  final void Function(Histories) onSelectHistory;

  const HistoryCategoryList({
    required this.statusCode,
    required this.categoryKey,
    required this.mapHistories,
    required this.hEnds,
    required this.hLoads,
    required this.hDeletes,
    required this.onClearHistory,
    required this.onLoadMore,
    required this.onSelectHistory,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String categoryName = _getCategoryName(statusCode);
    List<Histories> histories = mapHistories[categoryKey] ?? [];

    int index = statusCode + 1;

    bool endState = hEnds[index];
    bool loadingState = hLoads[index];
    bool deleteState = hDeletes[index];

    return histories.isEmpty
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: null, // Add functionality if needed
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: containerDecorations[4],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            categoryName,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        if (statusCode == -1)
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (deleteState)
                                  const Row(
                                    children: [
                                      Text("Đang xoá"),
                                      SizedBox(width: 8),
                                      SizedBox(
                                        width: 30.0,
                                        height: 30.0,
                                        child: CircularProgressIndicator(),
                                      ),
                                    ],
                                  )
                                else
                                  UIActionButton(
                                    enable: !loadingState,
                                    actionId: 5,
                                    onPressed: () async {
                                      await onClearHistory(statusCode);
                                    },
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: histories.length,
                      itemBuilder: (context, index) {
                        final history = histories[index];
                        return HistoryBox(
                          history: history,
                          onTap: onSelectHistory,
                        );
                      },
                    ),
                    const SizedBox(height: 8.0),
                    if (loadingState)
                      const Center(child: CircularProgressIndicator())
                    else if (!endState)
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: UIActionButton(
                            enable: !loadingState,
                            actionId: 4,
                            onPressed: () async {
                              await onLoadMore(statusCode);
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
  }

  String _getCategoryName(int statusCode) {
    switch (statusCode) {
      case -1:
        return "Phòng đã huỷ";
      case 0:
        return "Phòng đã đặt";
      case 1:
        return "Phòng đang dùng";
      case 2:
        return "Phòng đã trả";
      default:
        throw UnimplementedError();
    }
  }
}

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
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: InkWell(
        onTap: _onContainerTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered ? color.withAlpha(141) : color,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.white, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 16.0,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [buildTitleAndValueTextRow(history.docId, "")],
          ),
        ),
      ),
    );
  }
}

class HistoryDetailBox extends StatefulWidget {
  final bool isDialog;
  final Histories? history;
  final Function() historyRefresh;

  HistoryDetailBox(
      {super.key,
      required this.isDialog,
      required this.history,
      required this.historyRefresh});

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

  void scheduleSuccess() {
    notifyServices.showMessage("Đã dời lịch thành công");
    widget.historyRefresh();
  }

  Future<void> onScheduleAction() async {
    widget.historyRefresh();
  }

  void cancelSuccess() {
    notifyServices.showMessage("Huỷ lịch thành công");
    widget.historyRefresh();
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

  Widget qrCodeDisplay() {
    return (history!.status == 0 || history!.status == 1)
        ? Container(
            padding: const EdgeInsets.all(8.0),
            decoration: containerDecorations[1],
            child: Center(
              child: QrCodeWidget(data: history!.docId),
            ))
        : const SizedBox();
  }

  Widget historyDialog(BuildContext context) {
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

              // Room Information
              qrCodeDisplay(),

              SizedBox(
                  height: (history!.status == 0 || history!.status == 1)
                      ? 20.0
                      : 0.0),
              // History Details
              Container(
                decoration: containerDecorations[2],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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

              const SizedBox(height: 20.0),

              // Action Buttons
              Container(
                decoration: containerDecorations[3],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (status != 0)
                        const SizedBox.shrink()
                      else
                        SizedBox(
                          width: double.infinity,
                          child: MyDatePicker(
                            setAsDefault: true,
                            enable: false,
                            dates: _availableDates,
                            onDateSelected: _datetimeStateChange,
                          ),
                        ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (status == 0)
                            Row(
                              children: [
                                UIActionButton(
                                  enable: !onProcess,
                                  actionId: 0,
                                  onPressed: () async {
                                    await onCancelAction();
                                    Navigator.of(context)
                                        .pop(); // Close dialog after action
                                  },
                                ),
                                UIActionButton(
                                  enable: !onProcess,
                                  actionId: 1,
                                  onPressed: () async {
                                    await onScheduleAction();
                                    Navigator.of(context)
                                        .pop(); // Close dialog after action
                                  },
                                ),
                              ],
                            ),
                          if (status == 2 || status == -1)
                            UIActionButton(
                              enable: !onProcess,
                              actionId: 2,
                              onPressed: () async {
                                await deleteAction();
                                Navigator.of(context)
                                    .pop(); // Close dialog after action
                              },
                            ),
                        ],
                      ),
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

  Widget historyBox(BuildContext context) {
    return InkWell(
      onTap: null, // You can add functionality here if needed
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: containerDecorations[0],
        child: Column(
          children: [
            qrCodeDisplay(),
            SizedBox(
                height: (history!.status == 0 || history!.status == 1)
                    ? 20.0
                    : 0.0),
            Container(
              decoration: containerDecorations[2],
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
                decoration: containerDecorations[3],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      (status != 0)
                          ? const SizedBox()
                          : SizedBox(
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
                                UIActionButton(
                                  enable: !onProcess,
                                  actionId: 0,
                                  onPressed: () async {
                                    await onCancelAction();
                                  },
                                ),
                                UIActionButton(
                                  enable: !onProcess,
                                  actionId: 1,
                                  onPressed: () async {
                                    await onScheduleAction();
                                  },
                                ),
                              ],
                            ),
                          if (status == 2 || status == -1)
                            UIActionButton(
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

  @override
  Widget build(BuildContext context) {
    return widget.isDialog ? historyDialog(context) : historyBox(context);
  }
}
