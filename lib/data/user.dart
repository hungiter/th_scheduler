import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String id;
  final String otp;
  final String role;
  final String password;
  final String displayName;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLogin;

  Users({
    required this.id,
    required this.otp,
    required this.role,
    required this.password,
    required this.displayName,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLogin,
  });

  static Users init() {
    return Users(
      id: '',
      otp: '',
      role: '',
      password: '',
      displayName: '',
      isVerified: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
  }

  // Factory constructor to create a User instance from Firestore data
  factory Users.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Users(
      id: doc.id,
      otp: data['otp'] ?? '',
      role: data['role'] ?? '',
      password: data['password'] ?? '',
      displayName: data['displayName'] ?? '',
      isVerified: data['isVerified'] ?? false,
      // Add this line
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'] ?? '',
      otp: json['otp'] ?? '',
      role: json['role'] ?? '',
      password: json['password'] ?? '',
      displayName: json['displayName'] ?? '',
      isVerified: json['isVerified'] ?? false,
      // Add this line
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (json['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Method to convert a User instance to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'otp': otp,
      'role': role,
      'password': password,
      'displayName': displayName,
      'isVerified': isVerified, // Add this line
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }
}
