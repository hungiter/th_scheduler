import 'dart:math';

import 'package:flutter/material.dart';
import 'package:th_scheduler/data/room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomsManagement {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> getRooms() async {
    CollectionReference roomsCollection = _firestore.collection("rooms");
    QuerySnapshot querySnapshot = await roomsCollection.get();
    return querySnapshot.docs;
  }

  Future<bool> haveRoom() async {
    List<QueryDocumentSnapshot> docs = await getRooms();
    return docs.isNotEmpty;
  }

  Future<void> removeAllRooms() async {
    final CollectionReference roomsCollection = _firestore.collection("rooms");
    final QuerySnapshot querySnapshot = await roomsCollection.get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> initializeRoomsIfEmpty(int numberOfRooms) async {
    bool have = await haveRoom();
    if (!have) {
      final Random random = Random();
      await removeAllRooms();

      for (int i = 1; i <= numberOfRooms; i++) {
        String roomId = i.toString().padLeft(3, '0');
        await _firestore.collection("rooms").doc(roomId).set({
          'id': roomId,
          'roomType': random.nextInt(3),
          'opened': true,
        });
      }
    }
  }

  Future<void> getAvailableRooms({
    int filterType = -1,
    required Function(String) errorCallBack,
    required Function(List<Rooms>) successCallback,
  }) async {
    try {
      await initializeRoomsIfEmpty(100);

      List<QueryDocumentSnapshot> docs = await getRooms();

      List<Rooms> rooms = docs.map((doc) {
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
      String roomId, bool opened, Function() finishCallback) async {
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
      finishCallback();
    }
  }

  Future<void> getRoomById(String roomId, Function(int) bugReached,
      Function(Rooms) successCallback) async {
    try {
      final doc = await _firestore.collection("rooms").doc(roomId).get();
      if (doc.exists) {
        successCallback(Rooms.fromFirestore(doc));
      } else {
        bugReached(101);
        return;
      }
    } catch (e) {
      bugReached(-1);
    }
  }
}
