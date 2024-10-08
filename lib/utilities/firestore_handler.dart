import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:th_scheduler/data/models.dart';
import 'package:th_scheduler/utilities/firestore/histories_management.dart';
import 'package:th_scheduler/utilities/firestore/staff_management.dart';
import 'package:th_scheduler/utilities/firestore/users_management.dart';
import 'package:th_scheduler/utilities/firestore/rooms_management.dart';

class FirestoreHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StaffManagement staffManagement = StaffManagement();
  final UsersManagement usersManagement = UsersManagement();
  final RoomsManagement roomsManagement = RoomsManagement();
  final HistoriesManagement historiesManagement = HistoriesManagement();

  Future<void> initializeFirestoreDB() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection("users").limit(1).get();
    } catch (e) {
      await _firestore.collection("users").doc("init").set({'id': "init"});
    }

    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection("rooms").limit(1).get();
    } catch (e) {
      await _firestore.collection("rooms").doc("init").set({'id': "init"});
    }

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("histories")
          .limit(1) // Limit to 1 document to minimize read operations
          .get();
    } catch (e) {
      await _firestore.collection("histories").doc("init").set({'id': "init"});
    }

    await _firestore.collection("users").doc("init").delete();
    await _firestore.collection("rooms").doc("init").delete();
    await _firestore.collection("histories").doc("init").delete();
  }

  Future<void> getUserById(String id, Function(int) bugReached,
      Function(Users) successCallback) async {
    Users? users = await usersManagement.getUserByDocId(id);
    if (users == null) {
      bugReached(1);
    } else {
      successCallback(users);
    }
  }

  Future<void> getUserForLogin(String phone, String password,
      Function(int) bugReached, Function(Users) successCallback) async {
    await usersManagement.getUserForLogin(phone, password, (eCode) {
      bugReached(eCode);
    }, (users) {
      successCallback(users);
    });
  }

  Future<String> getStaffId() async {
    String staffId = await staffManagement.getStaffId();
    return staffId;
  }

  Future<void> initializeRoomsIfEmpty(
      Function(String) errorCallBack, Function() finishCallBack) async {
    try {
      await roomsManagement.initializeRoomsIfEmpty(100);
      finishCallBack();
    } catch (e) {
      errorCallBack("Lỗi tạo dữ liệu $e");
    }
  }

  Future<void> fetchRoomsByLimit({
    int filterType = -1,
    Rooms? lastRooms,
    int limit = 10,
    required Function(String) errorCallBack,
    required Function(List<Rooms>) successCallback,
  }) async {
    DocumentSnapshot? document;

    if (lastRooms != null) {
      document = await roomsManagement.getDocumentById(lastRooms);
    }

    await roomsManagement.fetchRoomsByLimit(
        filterType: filterType,
        lastDocument: document,
        limit: limit,
        errorCallBack: errorCallBack,
        successCallback: successCallback);
  }

  Future<void> setRoomOpened(
      String roomId, bool opened, Function() finishCallback) async {
    await roomsManagement.setRoomOpened(roomId, opened, () {
      finishCallback();
    });
  }

  Future<void> getRoomById(String roomId, Function(int) bugReached,
      Function(Rooms) successCallback) async {
    await roomsManagement.getRoomById(roomId, (eCode) => bugReached(eCode),
        (rooms) => successCallback(rooms));
  }

  // History ===================================================================

  Future<void> getUserHistories(Function(int) bugReached,
      Function(List<Histories>) resultCallback) async {
    await historiesManagement.getUserHistories((eCode) {
      bugReached(eCode);
      return;
    }, (histories) {
      resultCallback(histories);
    });
  }

  Future<void> fetchHistoriesByLimit({
    int filterStatus = -1,
    Histories? lastHistory,
    int limit = 5,
    required Function(String) errorCallBack,
    required Function(List<Histories>) successCallback,
  }) async {
    DocumentSnapshot? document;

    if (lastHistory != null) {
      document =
          await historiesManagement.getDocumentByDocId(lastHistory.docId);
    }

    await historiesManagement.fetchHistoriesByLimit(
        filterStatus: filterStatus,
        lastDocument: document,
        limit: limit,
        errorCallBack: errorCallBack,
        successCallback: successCallback);
  }

  Future<void> getHistoriesByDocId(String historyId, Function(int) bugReached,
      Function(Histories) resultCallback) async {
    try {
      DocumentSnapshot? doc =
          await historiesManagement.getDocumentByDocId(historyId);

      if (doc != null) {
        resultCallback(Histories.fromFirestore(doc));
      } else {
        bugReached(202);
      }
    } catch (e) {
      bugReached(-207);
    }
  }

  Future<void> roomOrderAndCreateHistory(String roomId, DateTime dateTime,
      Function(int) bugReached, Function(String) finishCallback) async {
    // Kiểm tra phòng
    try {
      await getRoomById(roomId, (eCode) {
        bugReached(eCode);
        return;
      }, (room) {
        if (!room.opened) {
          bugReached(102);
          return;
        }
      });
    } catch (e) {
      bugReached(-101);
      return;
    }

    // Thêm Lịch sử
    try {
      int bug = 0;
      String newHistoryDocID = "";
      await historiesManagement.createHistory(roomId, dateTime, (eCode) {
        bugReached(eCode);
        bug = eCode;
      }, (docId) {
        newHistoryDocID = docId;
      });

      if (bug != 0) {
        return;
      }

      // Đổi số liệu phòng
      await setRoomOpened(roomId, false, () {
        finishCallback(newHistoryDocID);
      });
    } catch (e) {
      bugReached(-203);
      return;
    }
  }

  Future<void> clearHistories({
    int filterStatus = -1, // or 2
    required Function(String) errorCallBack,
    required Function() successCallback,
  }) async {
    await historiesManagement.clearHistories(
        filterStatus: filterStatus,
        errorCallBack: errorCallBack,
        successCallback: successCallback);
  }

  Future<void> userChangeDate(String docId, DateTime dateTime,
      Function(int) bugReached, Function() finishCallback) async {
    await historiesManagement.userChangedComingDate(
        docId, dateTime, (p0) => bugReached, () => finishCallback);
  }

  Future<void> userDeleteHistory(
      String docId, Function(int) bugReached, Function() finishCallback) async {
    await historiesManagement.userDeleteHistory(docId, (eCode) {
      bugReached(eCode);
    }, () {
      finishCallback();
    });
  }

  Future<void> userCancelHistory(String docId, String roomId,
      Function(int) bugReached, Function() finishCallback) async {
    await roomsManagement.setRoomOpened(roomId, true, () => null);

    await historiesManagement.userCancelHistory(docId, (eCode) {
      bugReached(eCode);
    }, () {
      finishCallback();
    });
  }

  Future<void> roomCheckIn(
      String docId, Function(int) bugReached, Function() finishCallback) async {
    await historiesManagement.checkIn(docId, (eCode) {
      bugReached(eCode);
    }, () {
      finishCallback();
    });
  }

  Future<void> roomCheckOut(String docId, String roomId,
      Function(int) bugReached, Function() finishCallback) async {
    await historiesManagement.checkOut(docId, (eCode) {
      bugReached(eCode);
    }, () async {
      await roomsManagement.setRoomOpened(roomId, true, () => null);
      finishCallback();
    });
  }
}
