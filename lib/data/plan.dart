import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule {
  final String id;
  final String fromId;
  final String toId;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final String status; //  Deny - Pending - Accept

  Schedule({required this.id, required this.fromId, required this.toId, required this.title, required this.startTime, required this.endTime, required this.status});

  factory Schedule.fromFirestore(Map<String, dynamic> data) {
    return Schedule(
      id: data['id'],
      fromId: data['fromId'],
      toId: data['toId'],
      title: data['title'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      status: data['status'],
    );
  }


  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'fromId': fromId,
      'toId':toId,
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'status':status
    };
  }
}