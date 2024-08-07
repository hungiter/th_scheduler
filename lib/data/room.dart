import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class Rooms {
  final String id;
  final int roomType;
  final double pricePerDay;
  final bool opened;

  Rooms({
    required this.id,
    required this.roomType,
    required this.pricePerDay,
    required this.opened,
  });

  // Initialization method with default values
  static Rooms init(int roomNumber) {
    Random random = Random();
    return Rooms(
        id: "$roomNumber",
        roomType: random.nextInt(2),
        pricePerDay: 0.0,
        opened: true);
  }

  // Factory constructor to create a Room instance from Firestore data
  factory Rooms.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Rooms(
        id: doc.id,
        roomType: data['roomType'] ?? 0, // Updated field name
        pricePerDay: data['pricePerDay']?.toDouble() ?? 0.0,
        opened: data['opened'] ?? true); // Handle null value
  }

  // Factory constructor to create a Room instance from JSON data
  factory Rooms.fromJson(Map<String, dynamic> json) {
    return Rooms(
        id: json['id'],
        roomType: json['roomType'] ?? 0, // Updated field name
        pricePerDay: json['pricePerDay']?.toDouble() ?? 0.0,
        opened: json['opened'] ?? true); // Handle null value
  }

  // Method to convert a Room instance to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomType': roomType,
      'pricePerDay': pricePerDay,
      'opened': opened
    };
  }

  String roomTypeToString() {
    return switch (roomType) {
      0 => "Giường đơn",
      1 => "Giường đơn x2",
      2 => "Giường đôi",
      int() => throw UnimplementedError(),
    };
  }
}
