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

  Future<void> createHistory(String roomId, DateTime dateTime,
      Function(int) bugReached, Function() finishCallback) async {
    String userId = await PreferencesManager.getUserId();
    int docNo = await lengthHistory(true); // Total: both visible and not
    String docId = "$docNo$userId ";

    int totalOrder = await userTotalRoomPending();

    if (totalOrder >= 3) {
      bugReached(201);
      return;
    }

    try {
      await _firestore.collection("histories").doc(docId).set({
        'id': docNo,
        'docId': docId,
        'roomId': roomId,
        'userId': userId,
        'fromDate': _datetimeHelper.dtString(dateTime),
        'status': 0,
        'visible': true
      });

      finishCallback();
    } catch (e) {
      bugReached(-202);
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
}
