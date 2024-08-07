import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class Histories {
  final String id;
  final String roomId;
  final String customerId;
  final DateTime fromDate;
  final DateTime? toDate; // Made nullable
  final int status; // 0-1-2

  Histories({
    required this.id,
    required this.roomId,
    required this.customerId,
    required this.fromDate,
    this.toDate, // Nullable
    required this.status,
  });

  // Initialization method with default values
  static Histories init(int roomNumber) {
    Random random = Random();
    return Histories(
        id: "0-0900000000",
        roomId: "0",
        customerId: "0900000000",
        fromDate: DateTime.now(),
        toDate: null,
        // Default to null
        status: 0);
  }

  // Factory constructor to create a Histories instance from Firestore data
  factory Histories.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Histories(
        id: doc.id,
        roomId: data['roomId'],
        customerId: data['customerId'],
        fromDate: (data['fromDate'] as Timestamp).toDate(),
        toDate: data['toDate'] != null
            ? (data['toDate'] as Timestamp).toDate()
            : null,
        status: int.parse(data['status'].toString()));
  }

  // Factory constructor to create a Histories instance from JSON data
  factory Histories.fromJson(Map<String, dynamic> json) {
    return Histories(
        id: json['id'],
        roomId: json['roomId'],
        customerId: json['customerId'],
        fromDate: (json['fromDate'] as Timestamp).toDate(),
        toDate: json['toDate'] != null
            ? (json['toDate'] as Timestamp).toDate()
            : null,
        status: int.parse(json['status'].toString()));
  }

  // Method to convert a Histories instance to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'customerId': customerId,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate?.toIso8601String(), // Handle null values
      'status': status
    };
  }

  String statusToString() {
    return switch (status) {
      0 => "Đã đặt",
      1 => "Đang sử dụng",
      2 => "Đã trả phòng",
      int() => throw UnimplementedError(),
    };
  }
}
