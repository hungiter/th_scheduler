import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> getUserForLogin(String phone, String password,
      Function(String) errorCallBack, Function(Users) successCallback) async {
    usersManagement.getUserForLogin(phone, password, (error) {
      errorCallBack(error);
    }, (users) {
      successCallback(users);
    });
  }

  Future<String> getStaffId() async {
    String staffId = await staffManagement.getStaffId();
    return staffId;
  }

  Future<void> getAvailableRooms({
    int filterType = -1,
    required Function(String) errorCallBack,
    required Function(List<Rooms>) successCallback,
  }) async {
    await roomsManagement.getAvailableRooms(
        filterType: filterType,
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

  // History
  Future<void> roomOrderAndCreateHistory(String roomId, DateTime dateTime,
      Function(int) bugReached, Function() finishCallback) async {
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
      await historiesManagement.createHistory(roomId, dateTime, (eCode) {
        bugReached(eCode);
        bug = eCode;
      }, () {});

      if (bug != 0) {
        return;
      }

      // Đổi số liệu phòng
      await setRoomOpened(roomId, false, () {
        finishCallback();
      });
    } catch (e) {
      bugReached(-203);
      return;
    }
  }

  Future<void> getUserHistories(Function(int) bugReached,
      Function(List<Histories>) resultCallback) async {
    await historiesManagement.getUserHistories((eCode) {
      bugReached(eCode);
      return;
    }, (histories) {
      resultCallback(histories);
    });
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
}
