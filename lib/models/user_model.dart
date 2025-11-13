import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final DateTime registrationDate;
  final String? dateOfBirth;
  final String? displayName;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.registrationDate,
    this.dateOfBirth,
    this.displayName,
  });

  // Get full name
  String get fullName => '$firstName $lastName';

  // Get display name or full name
  String get name => displayName ?? fullName;

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'dateOfBirth': dateOfBirth,
      'displayName': displayName ?? fullName,
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime registrationDate;
    if (map['registrationDate'] != null) {
      if (map['registrationDate'] is Timestamp) {
        registrationDate = (map['registrationDate'] as Timestamp).toDate();
      } else if (map['registrationDate'] is DateTime) {
        registrationDate = map['registrationDate'] as DateTime;
      } else {
        // Fallback to current date if invalid format
        registrationDate = DateTime.now();
      }
    } else {
      // Fallback to current date if null
      registrationDate = DateTime.now();
    }

    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      role: map['role'] ?? 'user',
      registrationDate: registrationDate,
      dateOfBirth: map['dateOfBirth'],
      displayName: map['displayName'],
    );
  }

  // Create from Firestore DocumentSnapshot
  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data();
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception('Invalid document data');
    }
    return UserModel.fromMap(data);
  }

  // Copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    DateTime? registrationDate,
    String? dateOfBirth,
    String? displayName,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      registrationDate: registrationDate ?? this.registrationDate,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      displayName: displayName ?? this.displayName,
    );
  }
}