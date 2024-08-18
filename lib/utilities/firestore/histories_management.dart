import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:th_scheduler/data/history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:th_scheduler/services/preferences_manager.dart';
import 'package:th_scheduler/utilities/datetime_helper.dart';

class HistoriesManagement {
  final DatetimeHelper _datetimeHelper = DatetimeHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> collectionExisted() async {
    try {
      final querySnapshot =
          await _firestore.collection("histories").limit(1).get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<QueryDocumentSnapshot>> allHistories() async {
    CollectionReference historiesCollection =
        _firestore.collection("histories");
    QuerySnapshot querySnapshot = await historiesCollection.get();
    return querySnapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> userHistories() async {
    String userId = await PreferencesManager.getUserId();
    CollectionReference historiesCollection =
        _firestore.collection("histories");
    QuerySnapshot querySnapshot =
        await historiesCollection.where("userId", isEqualTo: userId).get();
    return querySnapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> userVisibleHistories() async {
    String userId = await PreferencesManager.getUserId();
    CollectionReference historiesCollection =
        _firestore.collection("histories");
    QuerySnapshot querySnapshot = await historiesCollection
        .where("userId", isEqualTo: userId)
        .where("visible", isEqualTo: true)
        .get();
    return querySnapshot.docs;
  }

  Future<bool> haveHistory(bool isUser) async {
    bool existed = await collectionExisted();
    if (!existed) return false;

    List<QueryDocumentSnapshot> docs =
        (isUser) ? await userHistories() : await allHistories();

    return docs.isNotEmpty;
  }

  Future<int> lengthHistory(bool isUser) async {
    bool existed = await collectionExisted();
    if (!existed) return 0;

    List<QueryDocumentSnapshot> docs =
        (isUser) ? await userHistories() : await allHistories();

    return docs.length;
  }

  Future<bool> docExist(String docId) async {
    try {
      final querySnapshot = await _firestore
          .collection('histories')
          .where("docId", isEqualTo: docId)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // -2: Xoá dòng
  // -1: Huỷ
  //  0: Đã đặt
  //  1: Đang sử dụng
  //  2: Đã trả phòng
  Future<int> userTotalRoomPending() async {
    try {
      String userId = await PreferencesManager.getUserId();
      CollectionReference historiesCollection =
          _firestore.collection("histories");

      QuerySnapshot querySnapshot = await historiesCollection
          .where("userId", isEqualTo: userId)
          .where("status", whereIn: [0, 1]).get();

      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> getUserHistories(Function(int) bugReached,
      Function(List<Histories>) resultCallback) async {
    bool have = await haveHistory(true);
    if (!have) {
      return;
    }

    try {
      List<Histories> histories = [];
      List<QueryDocumentSnapshot> docs = await userVisibleHistories();
      for (var doc in docs) {
        histories.add(Histories.fromFirestore(doc));
      }
      resultCallback(histories);
    } catch (e) {
      bugReached(-201);
    }
  }

  Future<DocumentSnapshot?> getDocumentByDocId(String docId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("histories")
        .where("docId", isEqualTo: docId)
        .get();
    return querySnapshot.docs.first;
  }

  Future<void> fetchHistoriesByLimit({
    required int filterStatus,
    required DocumentSnapshot? lastDocument,
    required int limit,
    required Function(String) errorCallBack,
    required Function(List<Histories>) successCallback,
  }) async {
    try {
      String userId = await PreferencesManager.getUserId();
      CollectionReference roomsCollection = _firestore.collection("histories");

      Query query = roomsCollection
          .where("userId", isEqualTo: userId)
          .where("visible", isEqualTo: true)
          .where("status", isEqualTo: filterStatus)
          .orderBy('id')
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot querySnapshot = await query.get();

      List<QueryDocumentSnapshot> docs = querySnapshot.docs;

      List<Histories> histories = docs.map((doc) {
        return Histories.fromFirestore(doc);
      }).toList();

      successCallback(histories);
    } catch (e, stacktrace) {
      errorCallBack("Lỗi khi lấy dữ liệu $e\n$stacktrace");
    }
  }

  Future<void> clearHistories({
    required int filterStatus,
    required Function(String) errorCallBack,
    required Function() successCallback,
  }) async {
    try {
      String userId = await PreferencesManager.getUserId();
      CollectionReference roomsCollection = _firestore.collection("histories");

      Query query = roomsCollection
          .where("userId", isEqualTo: userId)
          .where("visible", isEqualTo: true)
          .where("status", isEqualTo: filterStatus);
      ;

      QuerySnapshot querySnapshot = await query.get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.update({"visible": false});
      }

      successCallback();
    } catch (e, stacktrace) {
      errorCallBack("Lỗi khi lấy dữ liệu $e\n$stacktrace");
    }
  }

  Future<void> createHistory(String roomId, DateTime dateTime,
      Function(int) bugReached, Function(String) finishCallback) async {
    String userId = await PreferencesManager.getUserId();
    int docNo = await lengthHistory(false); // Total: both visible and not

    int totalOrder = await userTotalRoomPending();
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);

    if (totalOrder >= 3) {
      bugReached(201);
      return;
    }

    try {
      DocumentReference newDocRef =
          await _firestore.collection("histories").add({});
      String docId = newDocRef.id;

      await _firestore.collection("histories").doc(docId).set({
        'id': docNo,
        'docId': docId,
        'roomId': roomId,
        'userId': userId,
        'fromDate': Timestamp.fromDate(date),
        'haveChanged': false,
        'status': 0,
        'visible': true
      });

      finishCallback(docId);
    } catch (e) {
      bugReached(-202);
    }
  }

  Future<void> userChangedComingDate(String docId, DateTime dateTime,
      Function(int) bugReached, Function() finishCallback) async {
    try {
      DocumentSnapshot? doc = await getDocumentByDocId(docId);
      if (doc == null) {
        bugReached(202);
        return;
      }
      ;

      Histories history = Histories.fromFirestore(doc);
      if (history.haveChanged) {
        bugReached(203);
        return;
      }

      await _firestore.collection("histories").doc(docId).set({
        'fromDate': _datetimeHelper.dtString(dateTime),
        'haveChanged': true
      });

      finishCallback();
    } catch (e) {
      bugReached(-206);
    }
  }

  Future<void> userDeleteHistory(
      String docId, Function(int) bugReached, Function() finishCallback) async {
    try {
      bool exist = await docExist(docId);
      if (exist) {
        await _firestore
            .collection("histories")
            .doc(docId)
            .update({"visible": false});
        finishCallback();
      } else {
        bugReached(202);
        return;
      }
    } catch (e) {
      bugReached(-204);
    }
  }

  Future<void> userCancelHistory(
      String docId, Function(int) bugReached, Function() finishCallback) async {
    try {
      bool exist = await docExist(docId);
      if (exist) {
        await _firestore
            .collection("histories")
            .doc(docId)
            .update({"status": -1});

        finishCallback();
      } else {
        bugReached(202);
        return;
      }
    } catch (e) {
      bugReached(-205);
    }
  }

  Future<void> checkIn(
      String docId, Function(int) bugReached, Function() finishCallback) async {
    try {
      bool exist = await docExist(docId);
      if (exist) {
        await _firestore.collection("histories").doc(docId).update(
            {"status": 1, "fromDate": Timestamp.fromDate(DateTime.now())});

        finishCallback();
      } else {
        bugReached(202);
        return;
      }
    } catch (e) {
      bugReached(-205);
    }
  }

  Future<void> checkOut(
      String docId, Function(int) bugReached, Function() finishCallback) async {
    try {
      bool exist = await docExist(docId);
      if (exist) {
        await _firestore.collection("histories").doc(docId).update(
            {"status": 2, "toDate": Timestamp.fromDate(DateTime.now())});

        finishCallback();
      } else {
        bugReached(202);
        return;
      }
    } catch (e) {
      bugReached(-205);
    }
  }
}
