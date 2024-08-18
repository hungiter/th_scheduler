import 'dart:async';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:th_scheduler/data/history.dart';
import 'package:th_scheduler/data/models.dart';
import 'package:th_scheduler/data/user.dart';

import 'package:flutter/material.dart';
import 'package:th_scheduler/pages/responsive/main_drawer.dart';
import 'package:th_scheduler/pages_components/custom_buttons.dart';
import 'package:th_scheduler/pages_components/custom_rows.dart';
import 'package:th_scheduler/services/authentication_services.dart';
import 'package:th_scheduler/services/notify_services.dart';
import 'package:th_scheduler/utilities/bug_handler.dart';

import 'package:th_scheduler/utilities/firestore_handler.dart';
import 'package:th_scheduler/services/preferences_manager.dart';
import 'package:th_scheduler/utilities/realtime_handler.dart';

import 'homepage_constant.dart';

class StaffHomePage extends StatefulWidget {
  StaffHomePage();

  @override
  _StaffHomePageState createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  bool onLoading = true;
  final FirestoreHandler _firestoreHandler = FirestoreHandler();
  final RealtimeDatabaseHandler _databaseHandler = RealtimeDatabaseHandler();
  final NotifyServices _notifyServices = NotifyServices();

  Users? user;

  final MobileScannerController _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 100,
      useNewCameraSelector: true,
      returnImage: true);

  int currentPage = 0;
  bool isScanCompleted = false;
  bool qrOnProcess = false;
  bool onShowDialog = false;

  Histories defaultHistory = Histories.init();
  Histories qrHistory = Histories.init();
  String userPhone = "";
  String userName = "";
  String userRoom = "";

  @override
  void initState() {
    super.initState();
    _getUser();
    _checkAllDataNeed();

    reassemble();
    restartCamera();
  }

  Future<void> _getUser() async {
    Map<String, dynamic> prefUser =
        await PreferencesManager.getUserDataFromSP();

    user = Users.fromJson(prefUser);
  }

  Future<void> _checkAllDataNeed() async {
    await _firestoreHandler.initializeRoomsIfEmpty((error) {
      debugPrint(error);
    }, () async {
      String staffId = await _firestoreHandler.getStaffId();
      await PreferencesManager.saveStaffId(staffId);
      setState(() {
        onLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    stopCamera();
    _controller.dispose();
  }

  void stopCamera() {
    _controller.stop();
  }

  void startCamera() {
    _controller.start();
  }

  void restartCamera() {
    stopCamera();
    startCamera();
  }

  Future<void> _currentPage(int pageId) async {
    setState(() {
      currentPage = pageId;
    });

    await switch (currentPage) {
      0 => {},
      1 => {},
      int() => throw UnimplementedError(),
    };
  }

  void stopQRScan() {
    isScanCompleted = true;
  }

  Future<void> qrCodeProcess(String docId) async {
    setState(() {
      qrOnProcess = true;
    });

    await checkHistory(docId);
  }

  void resetHistoryData() {
    setState(() {
      qrHistory = defaultHistory;
      userRoom = "";
      userName = "";
      userPhone = "";
    });
  }

  Future<void> getHistoryData() async {
    Users tmp = Users.init();
    await _firestoreHandler.getUserById(qrHistory.userId, (eCode) {
      _notifyServices.showErrorToast(BugHandler.bugString(eCode));
    }, (foundUser) {
      tmp = foundUser;
    });

    setState(() {
      userRoom = qrHistory.roomId;
      userName = tmp.displayName;
      userPhone = tmp.id;
      qrOnProcess = false;
    });
  }

  Future<void> checkHistory(String historyId) async {
    String error = "";
    await _firestoreHandler.getHistoriesByDocId(historyId, (eCode) {
      error = BugHandler.bugString(eCode);
      _notifyServices.showErrorToast(error);
    }, (history) {
      qrHistory = history;
    });

    if (error.isNotEmpty) {
      setState(() {
        qrOnProcess = false;
        onShowDialog = false;
      });
      isScanCompleted = false;
      return;
    }

    await getHistoryData();
  }

  void showScanDialog(BuildContext context) {
    setState(() {
      onShowDialog = true;
    });
    showDialog(
        context: context,
        builder: (BuildContext context) {
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
                          isScanCompleted = false;
                          setState(() {
                            onShowDialog = false;
                          });
                          startCamera();
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    SizedBox(
                        height: (qrHistory.status == 0 || qrHistory.status == 1)
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
                            buildTitleAndValueTextRow("Phòng:", userRoom),
                            buildTitleAndValueTextRow("Người dùng:", userName),
                            buildTitleAndValueTextRow(
                                "Số điện thoại:", userPhone),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(),
                                    if (qrHistory.status == 0)
                                      UIActionButton(
                                        enable: !qrOnProcess,
                                        actionId: 6,
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          await checkInProcess(context);
                                        },
                                      ),
                                    if (qrHistory.status == 1)
                                      UIActionButton(
                                        enable: !qrOnProcess,
                                        actionId: 7,
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          await checkOutProcess(context);
                                        },
                                      ),
                                  ],
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
        });
  }

  Future<void> checkInProcess(BuildContext context) async {
    setState(() {
      qrOnProcess = true;
    });
    String error = "";

    await _firestoreHandler.roomCheckIn(qrHistory.docId, (eCode) {
      error = BugHandler.bugString(eCode);
      _notifyServices.showErrorToast(error);
    }, () {});

    if (error.isNotEmpty) {
      setState(() {
        qrOnProcess = false;
        onShowDialog = false;
      });
      isScanCompleted = false;
      startCamera();
      return;
    }

    await _databaseHandler.updateHistoryQR(qrHistory.docId, 1);
    _notifyServices.showMessage("Nhận phòng thành công");
    setState(() {
      qrOnProcess = false;
      onShowDialog = false;
    });
    isScanCompleted = false;
    startCamera();
  }

  Future<void> checkOutProcess(BuildContext context) async {
    setState(() {
      qrOnProcess = true;
    });
    String error = "";
    await _firestoreHandler.roomCheckOut(qrHistory.docId, userRoom, (eCode) {
      error = BugHandler.bugString(eCode);
      _notifyServices.showErrorToast(error);
    }, () async {});

    if (error.isNotEmpty) {
      setState(() {
        qrOnProcess = false;
        onShowDialog = false;
      });
      isScanCompleted = false;
      startCamera();
      return;
    }

    await _databaseHandler.updateHistoryQR(qrHistory.docId, 2);
    _notifyServices.showMessage("Trả phòng thành công");

    setState(() {
      qrOnProcess = false;
      onShowDialog = false;
    });
    isScanCompleted = false;
    startCamera();
  }

  @override
  Widget build(BuildContext context) {
    return (onLoading)
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: staffAppBar,
            backgroundColor: mobileBackground,
            drawer: StaffDrawer(selected: currentPage, onSelect: _currentPage),
            body: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  decoration: containerDecorations[0],
                  child: Column(
                    children: [
                      switch (currentPage) {
                        0 => Expanded(
                            child: Column(
                              children: [
                                // Note Area
                                const Expanded(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Để QR code vào khu vực này",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                        "Quá trình quét sẽ được diễn ra một cách tự động",
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 15,
                                            letterSpacing: 1),
                                        textAlign: TextAlign.center)
                                  ],
                                )),

                                // QR AREA
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    width: double.maxFinite,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black54, width: 2.0)),
                                    child: (qrOnProcess)
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : (onShowDialog)
                                            ? const Center(child: SizedBox())
                                            : MobileScanner(
                                                controller: _controller,
                                                errorBuilder:
                                                    (BuildContext context,
                                                        MobileScannerException
                                                            error,
                                                        Widget? child) {
                                                  return Center(
                                                    child: Text(error
                                                        .errorDetails!.message
                                                        .toString()),
                                                  );
                                                },
                                                onDetect:
                                                    (barcodeCapture) async {
                                                  final List<Barcode> barcodes =
                                                      barcodeCapture.barcodes;
                                                  for (final barcode
                                                      in barcodes) {
                                                    if (!isScanCompleted) {
                                                      String docId =
                                                          barcode.rawValue ??
                                                              '---';
                                                      stopQRScan();

                                                      stopCamera();
                                                      await qrCodeProcess(
                                                          docId);

                                                      if (qrHistory.id >= 0) {
                                                        showScanDialog(context);
                                                      }
                                                    }
                                                  }
                                                },
                                              ),
                                  ),
                                ),

                                // USED STAFF
                                Expanded(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Đang hoạt động bởi",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1)),
                                    const SizedBox(height: 10),
                                    (user == null)
                                        ? const SizedBox()
                                        : Text(
                                            user!.displayName,
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 15,
                                                letterSpacing: 1),
                                          ),
                                  ],
                                )),
                              ],
                            ),
                          ),
                        int() => const SizedBox(),
                      },
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
