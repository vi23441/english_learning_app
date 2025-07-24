import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  teacher,
  admin,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> testHistory;
  final Map<String, int> vocabStats;
  final String? profileImageUrl;
  final String? phoneNumber;
  final DateTime? lastLoginAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.testHistory = const [],
    this.vocabStats = const {},
    this.profileImageUrl,
    this.phoneNumber,
    this.lastLoginAt,
    this.isActive = true,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'testHistory': testHistory,
      'vocabStats': vocabStats,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'isActive': isActive,
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.student,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      testHistory: List<String>.from(map['testHistory'] ?? []),
      vocabStats: Map<String, int>.from(map['vocabStats'] ?? {}),
      profileImageUrl: map['profileImageUrl'],
      phoneNumber: map['phoneNumber'],
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  // Create a copy with updated values
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? testHistory,
    Map<String, int>? vocabStats,
    String? profileImageUrl,
    String? phoneNumber,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      testHistory: testHistory ?? this.testHistory,
      vocabStats: vocabStats ?? this.vocabStats,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// For backwards compatibility
class User extends UserModel {
  User({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.createdAt,
    required super.updatedAt,
    super.testHistory,
    super.vocabStats,
    super.profileImageUrl,
    super.phoneNumber,
    super.lastLoginAt,
    super.isActive,
  });

  String get uid => id;
}
