import 'package:cloud_firestore/cloud_firestore.dart';

class Rooms {
  final String id;
  final int roomType;
  final double pricePerDay;
  final List<DateTime> fromDates;
  final List<DateTime> toDates;

  Rooms({
    required this.id,
    required this.roomType,
    required this.pricePerDay,
    required this.fromDates,
    required this.toDates,
  });

  // Initialization method with default values
  static Rooms init(int roomNumber) {
    return Rooms(
      id: "$roomNumber",
      roomType: 1,
      pricePerDay: 0.0,
      fromDates: [DateTime.now()],
      toDates: [DateTime.now()],
    );
  }

  // Factory constructor to create a Room instance from Firestore data
  factory Rooms.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Rooms(
      id: doc.id,
      roomType: data['noOfBed'] ?? 0,
      pricePerDay: data['pricePerDay']?.toDouble() ?? 0.0,
      fromDates: (data['fromDates'] as List<dynamic>?)
              ?.map((date) => (date as Timestamp).toDate())
              .toList() ??
          [],
      toDates: (data['toDates'] as List<dynamic>?)
              ?.map((date) => (date as Timestamp).toDate())
              .toList() ??
          [],
    );
  }

  // Factory constructor to create a Room instance from JSON data
  factory Rooms.fromJson(Map<String, dynamic> json) {
    return Rooms(
      id: json['id'],
      roomType: json['noOfBed'] ?? 0,
      pricePerDay: json['pricePerDay']?.toDouble() ?? 0.0,
      fromDates: (json['fromDates'] as List<dynamic>)
          .map((date) => DateTime.parse(date))
          .toList(),
      toDates: (json['toDates'] as List<dynamic>)
          .map((date) => DateTime.parse(date))
          .toList(),
    );
  }

  // Method to convert a Room instance to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomType': roomType,
      'pricePerDay': pricePerDay,
      'fromDates': fromDates.map((date) => date.toIso8601String()).toList(),
      'toDates': toDates.map((date) => date.toIso8601String()).toList(),
    };
  }
}
