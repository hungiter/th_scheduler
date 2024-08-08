import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:th_scheduler/utilities/datetime_helper.dart';

class Histories {
  final String id;
  final String roomId;
  final String userId;
  final DateTime fromDate;
  final DateTime? toDate; // Made nullable
  final int status; // 0-1-2

  Histories({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.fromDate,
    this.toDate, // Nullable
    required this.status,
  });

  // Initialization method with default values
  static Histories init(int roomNumber) {
    return Histories(
        id: "0-0900000000",
        roomId: "0",
        userId: "0900000000",
        fromDate: DateTime.now(),
        toDate: null,
        // Default to null
        status: 0);
  }

  // Factory constructor to create a Histories instance from Firestore data
  factory Histories.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final DatetimeHelper datetimeHelper = DatetimeHelper();
    return Histories(
        id: doc.id,
        roomId: data['roomId'],
        userId: data['userId'],
        fromDate: datetimeHelper.stringDt(data['fromDate'].toString()),
        toDate: data['toDate'] != null
            ? datetimeHelper.stringDt(data['toDate'].toString())
            : null,
        status: int.parse(data['status'].toString()));
  }

  // Factory constructor to create a Histories instance from JSON data
  factory Histories.fromJson(Map<String, dynamic> json) {
    final DatetimeHelper datetimeHelper = DatetimeHelper();
    return Histories(
        id: json['id'],
        roomId: json['roomId'],
        userId: json['userId'],
        fromDate: datetimeHelper.stringDt(json['fromDate'].toString()),
        toDate: json['toDate'] != null
            ? datetimeHelper.stringDt(json['toDate'].toString())
            : null,
        status: int.parse(json['status'].toString()));
  }

  // Method to convert a Histories instance to a JSON-compatible map
  Map<String, dynamic> toJson() {
    final DatetimeHelper datetimeHelper = DatetimeHelper();
    return {
      'id': id,
      'roomId': roomId,
      'userId': userId,
      'fromDate': datetimeHelper.dtString(fromDate),
      'toDate': datetimeHelper.dtString(toDate!), // Handle null values
      'status': status
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
