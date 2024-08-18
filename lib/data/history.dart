import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:th_scheduler/utilities/datetime_helper.dart';

class Histories {
  final int id;
  final String docId;
  final String roomId;
  final String userId;
  final DateTime fromDate;
  final DateTime? toDate; // Made nullable
  final bool haveChanged;
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
      required this.haveChanged,
      required this.status,
      required this.visible});

  // Initialization method with default values
  static Histories init() {
    return Histories(
        id: -1,
        docId: "0-0900000000",
        roomId: "000",
        userId: "0900000000",
        fromDate: DateTime.now(),
        toDate: null,
        haveChanged: false,
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
        fromDate: (data['fromDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        toDate: data['toDate'] != null
            ? (data['toDate'] as Timestamp?)?.toDate() ?? DateTime.now()
            : null,
        haveChanged: bool.parse(data['haveChanged'].toString()),
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
        fromDate: DateTime.tryParse(json['fromDate']) ?? DateTime.now(),
        toDate: json['toDate'] != null
            ? DateTime.tryParse(json['toDate']) ?? DateTime.now()
            : null,
        haveChanged: bool.parse(json['haveChanged'].toString()),
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
      'haveChanged': haveChanged,
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
