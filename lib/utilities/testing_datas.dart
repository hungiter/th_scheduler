import 'dart:math';

import 'package:th_scheduler/services/preferences_manager.dart';

import '../data/history.dart';
import '../data/room.dart';

class TestData {
  TestData();

  List<Rooms> initTestRooms(int numberOfRooms) {
    Random random = Random();
    List<Rooms> roomsList = [];

    for (int i = 0; i < numberOfRooms; i++) {
      String id =
          (i + 1).toString().padLeft(3, '0'); // Format ID as '001', '002', etc.
      int roomType = random.nextInt(3); // Random roomType between 0 and 2
      double pricePerDay = (random.nextDouble() * 1000000 + 500000)
          .toDouble(); // Random price between 500,000 and 1,500,000
      bool opened =
          (id == "001") ? true : random.nextBool(); // Randomly true or false

      roomsList.add(Rooms(
        id: id,
        roomType: roomType,
        pricePerDay: pricePerDay,
        opened: opened,
      ));
    }

    return roomsList;
  }

  List<Histories> initTestHistories() {
    return [
      Histories(
          id: '001-0908670268',
          roomId: '001',
          customerId: '0908670268',
          fromDate: DateTime.now(),
          toDate: null,
          status: 0),
      Histories(
          id: '002-0908670268',
          roomId: '002',
          customerId: '0908670268',
          fromDate: DateTime.now().subtract(const Duration(days: 1)),
          toDate: null,
          status: 1),
      Histories(
          id: '003-0908670268',
          roomId: '003',
          customerId: '0908670268',
          fromDate: DateTime.now().subtract(const Duration(days: 2)),
          toDate: DateTime.now().subtract(const Duration(days: 1)),
          status: 2),
    ];
  }
}
