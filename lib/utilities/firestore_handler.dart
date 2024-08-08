import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:th_scheduler/data/models.dart';
import 'package:th_scheduler/services/preferences_manager.dart';
import 'package:th_scheduler/utilities/datetime_helper.dart';

class FirestoreHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatetimeHelper _datetimeHelper = DatetimeHelper();

  Future<void> initializeFirestoreDB() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("users").limit(1).get();
    } catch (e) {
      await _firestore.collection("users").doc("init").set({'id': "init"});
    }

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("rooms").limit(1).get();
    } catch (e) {
      await _firestore.collection("rooms").doc("init").set({'id': "init"});
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
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

  Future<Users?> getUserByDocId(String docId) async {
    try {
      final doc = await _firestore.collection("users").doc(docId).get();
      if (doc.exists) {
        return Users.fromFirestore(doc);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> getUserForLogin(String phone, String password,
      Function(String) errorCallBack, Function(Users) successCallback) async {
    try {
      final doc = await _firestore.collection('users').doc(phone).get();
      if (doc.exists) {
        if (doc.data()?["password"] == password) {
          successCallback(Users.fromFirestore(doc));
        } else {
          errorCallBack("Sai mật khẩu");
        }
      } else {
        errorCallBack("Tài khoản không tồn tại");
      }
    } catch (e) {
      errorCallBack("Lỗi: $e");
    }
  }

  // Dummy removeAllData function to clear existing rooms
  Future<void> removeAllRooms() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference roomsCollection = firestore.collection("rooms");
    final QuerySnapshot querySnapshot = await roomsCollection.get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> initializeRooms(int numberOfRooms) async {
    final Random random = Random();

    try {
      await removeAllRooms();

      for (int i = 1; i <= numberOfRooms; i++) {
        String roomId = i.toString().padLeft(3, '0');
        await _firestore.collection("rooms").doc(roomId).set({
          'id': roomId,
          'roomType': random.nextInt(3),
          'opened': true,
        });
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> getAvailableRooms({
    int filterType = -1,
    required Function(String) errorCallBack,
    required Function(List<Rooms>) successCallback,
  }) async {
    try {
      CollectionReference roomsCollection = _firestore.collection("rooms");
      QuerySnapshot querySnapshot = await roomsCollection.get();
      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      if (docs.isEmpty) {
        await initializeRooms(100);

        getAvailableRooms(
            filterType: filterType,
            errorCallBack: errorCallBack,
            successCallback: successCallback);
        return;
      }

      List<Rooms> rooms = querySnapshot.docs.map((doc) {
        return Rooms.fromFirestore(doc);
      }).toList();

      List<Rooms> filteredRooms = rooms
          .where((room) =>
              ((filterType == -1) ? true : room.roomType == filterType) &&
              room.opened)
          .toList();

      successCallback(filteredRooms);
    } catch (e) {
      errorCallBack("Lỗi khác: $e");
    }
  }

  Future<void> setRoomOpened(
      String roomId, bool opened, Function(void) finishCallback) async {
    try {
      final doc = await _firestore.collection("rooms").doc(roomId).get();
      if (doc.exists) {
        await _firestore
            .collection("rooms")
            .doc(roomId)
            .update({'opened': opened});
      }
    } catch (e) {
      debugPrint("$e");
    } finally {
      finishCallback({});
    }
  }

  Future<void> getRoomById(String roomId, Function(String) errorCallBack,
      Function(Rooms) successCallback) async {
    try {
      final doc = await _firestore.collection("rooms").doc(roomId).get();
      if (doc.exists) {
        successCallback(Rooms.fromFirestore(doc));
      } else {
        errorCallBack("Phòng không tồn tại");
      }
    } catch (e) {
      errorCallBack("Lỗi khác: $e");
    }
  }

  Future<void> createHistory(String roomId, DateTime dateTime,
      Function(String) errorCallback, Function() finishCallback) async {
    String userId = await PreferencesManager.getUserId();
    String docId = "$userId-$roomId-${_datetimeHelper.dtString(dateTime)}";
    String errorMessage = "Không tạo được lịch sử đặt phòng\n";
    try {
      bool roomOpened = false; // Ktra cho chắc
      await getRoomById(roomId, (roomError) {
        errorCallback("$errorMessage Lỗi phòng không tồn tại");
        return;
      }, (room) {
        roomOpened = room.opened;
      });

      if (roomOpened) {
        try {
          await _firestore.collection("histories").doc(docId).set({
            'id': docId,
            'roomId': roomId,
            'userId': userId,
            'fromDate': _datetimeHelper.dtString(dateTime),
            'status': 0
          });
          finishCallback();
        } catch (e) {
          errorCallback("$errorMessage $e");
        }
      } else {
        errorCallback("$errorMessage Phòng đã có người khác đặt trước.");
      }
    } catch (e) {
      errorCallback("$errorMessage$e");
    }
  }

  Future<void> getUserHistories(Function(String) errorCallback,
      Function(List<Histories>) resultCallback) async {
    String userId = await PreferencesManager.getUserId();

    try {
      CollectionReference historiesCollection =
          _firestore.collection("histories");
      QuerySnapshot querySnapshot = await historiesCollection.get();
      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      if (docs.isEmpty) {
        return;
      } else {
        List<Histories> histories = [];
        for (var doc in docs) {
          debugPrint(doc.data().toString());
          histories.add(Histories.fromFirestore(doc));
        }
        resultCallback(histories);
      }

      // final querySnapshot = await _firestore
      //     .collection("histories")
      //     .where('userId', isEqualTo: userId.toString())
      //     .get();
    } catch (e) {
      errorCallback(e.toString());
    }
  }
}
