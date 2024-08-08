import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Rooms {
  final String id;
  final int roomType;
  final bool opened;

  Rooms({
    required this.id,
    required this.roomType,
    required this.opened,
  });

  // Initialization method with default values
  static Rooms init(int roomNumber) {
    Random random = Random();
    return Rooms(
      id: "$roomNumber",
      roomType: random.nextInt(3), // Adjusted to allow roomType 0, 1, or 2
      opened: true,
    );
  }

  // Factory constructor to create a Room instance from Firestore data
  factory Rooms.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;

    if (data == null) {
      throw ArgumentError('Snapshot data is null');
    }

    return Rooms(
      id: snapshot.id,
      roomType: int.parse(data['roomType'].toString()),
      opened: bool.parse(data['opened'].toString()),
    );
  }

  // Factory constructor to create a Room instance from JSON data
  factory Rooms.fromJson(Map<String, dynamic> json) {
    return Rooms(
      id: json['id'].toString(),
      roomType: int.parse(json['roomType'].toString()),
      opened: bool.parse(json['opened'].toString()),
    );
  }

  // Method to convert a Room instance to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomType': roomType,
      'opened': opened,
    };
  }

  String roomTypeToString() {
    return switch (roomType) {
      0 => "Giường đơn",
      1 => "Giường đơn x2",
      2 => "Giường đôi",
      _ => throw UnimplementedError(),
    };
  }

  double priceByRoomType() {
    return switch (roomType) {
      0 => 150000.0,
      1 => 200000.0,
      2 => 250000.0,
      _ => throw UnimplementedError(),
    };
  }

  String statusToString() {
    return switch (opened) { true => "Mở", false => "Đóng" };
  }
}
