import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:th_scheduler/utilities/datetime_helper.dart';

class Histories {
  final int id;
  final String docId;
  final String roomId;
  final String userId;
  final DateTime fromDate;
  final DateTime? toDate; // Made nullable
  final int status;
  final bool visible;

  // -1: Huỷ
  //  0: Đã đặt
  //  1: Đang sử dụng
  //  2: Đã trả phòng

  Histories(
      {required this.id,
      required this.docId,
      required this.roomId,
      required this.userId,
      required this.fromDate,
      this.toDate, // Nullable
      required this.status,
      required this.visible});

  // Initialization method with default values
  static Histories init(int roomNumber) {
    return Histories(
        id: 0,
        docId: "0-0900000000",
        roomId: "000",
        userId: "0900000000",
        fromDate: DateTime.now(),
        toDate: null,
        status: 0,
        visible: true);
  }

  // Factory constructor to create a Histories instance from Firestore data
  factory Histories.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final DatetimeHelper datetimeHelper = DatetimeHelper();
    return Histories(
        id: int.parse(data["id"].toString()),
        docId: doc.id,
        roomId: data['roomId'],
        userId: data['userId'],
        fromDate: datetimeHelper.stringDt(data['fromDate'].toString()),
        toDate: data['toDate'] != null
            ? datetimeHelper.stringDt(data['toDate'].toString())
            : null,
        status: int.parse(data['status'].toString()),
        visible: bool.parse(data['visible'].toString()));
  }

  // Factory constructor to create a Histories instance from JSON data
  factory Histories.fromJson(Map<String, dynamic> json) {
    final DatetimeHelper datetimeHelper = DatetimeHelper();
    return Histories(
        id: int.parse(json['id'].toString()),
        docId: json['docId'],
        roomId: json['roomId'],
        userId: json['userId'],
        fromDate: datetimeHelper.stringDt(json['fromDate'].toString()),
        toDate: json['toDate'] != null
            ? datetimeHelper.stringDt(json['toDate'].toString())
            : null,
        status: int.parse(json['status'].toString()),
        visible: bool.parse(json['visible'].toString()));
  }

  // Method to convert a Histories instance to a JSON-compatible map
  Map<String, dynamic> toJson() {
    final DatetimeHelper datetimeHelper = DatetimeHelper();
    return {
      'id': id,
      'docId': roomId,
      'roomId': roomId,
      'userId': userId,
      'fromDate': datetimeHelper.dtString(fromDate),
      'toDate': datetimeHelper.dtString(toDate!), // Handle null values
      'status': status,
      'visible': status,
    };
  }

  String statusToString() {
    return switch (status) {
      -1 => "Huỷ phòng",
      0 => "Đã đặt",
      1 => "Đang sử dụng",
      2 => "Đã trả phòng",
      int() => throw UnimplementedError(),
    };
  }
}
