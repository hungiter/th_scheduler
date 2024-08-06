import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String id;
  final String otp;
  final String email;
  final String password;
  final String displayName;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLogin;

  Users({
    required this.id,
    required this.otp,
    required this.email,
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
      email: '',
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
      email: data['email'] ?? '',
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
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      displayName: json['displayName'] ?? '',
      isVerified: json['isVerified'] ?? false,
      // Add this line
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastLogin: DateTime.parse(json['lastLogin']),
    );
  }

  // Method to convert a User instance to a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'otp': otp,
      'email': email,
      'password': password,
      'displayName': displayName,
      'isVerified': isVerified, // Add this line
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
    };
  }
}
