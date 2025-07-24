import 'package:cloud_firestore/cloud_firestore.dart';

class Feedback {
  final String id;
  final String userId;
  final String type; // 'app_feedback', 'video_rating', 'content_suggestion', 'bug_report'
  final String title;
  final String content; // For video ratings, this is the comment
  final double? rating; // 1-5 stars for ratings
  final String? relatedItemId; // video ID, test ID, etc.
  final String status; // 'pending', 'reviewed', 'resolved'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? adminResponse;
  final String? adminId;

  // Compatibility getter for comment
  String get comment => content;

  Feedback({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    this.rating,
    this.relatedItemId,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
    this.adminResponse,
    this.adminId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'content': content,
      'rating': rating,
      'relatedItemId': relatedItemId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'adminResponse': adminResponse,
      'adminId': adminId,
    };
  }

  factory Feedback.fromMap(Map<String, dynamic> map) {
    return Feedback(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      rating: map['rating']?.toDouble(),
      relatedItemId: map['relatedItemId'],
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      adminResponse: map['adminResponse'],
      adminId: map['adminId'],
    );
  }

  factory Feedback.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Feedback.fromMap(data..['id'] = doc.id);
  }

  Feedback copyWith({
    String? type,
    String? title,
    String? content,
    double? rating,
    String? relatedItemId,
    String? status,
    DateTime? updatedAt,
    String? adminResponse,
    String? adminId,
  }) {
    return Feedback(
      id: id,
      userId: userId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      rating: rating ?? this.rating,
      relatedItemId: relatedItemId ?? this.relatedItemId,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminResponse: adminResponse ?? this.adminResponse,
      adminId: adminId ?? this.adminId,
    );
  }

  @override
  String toString() {
    return 'Feedback(id: $id, type: $type, title: $title, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Feedback && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class UserProgress {
  final String id;
  final String userId;
  final String type; // 'vocabulary', 'video', 'test'
  final String itemId;
  final int progressPercent;
  final DateTime lastAccessedAt;
  final DateTime createdAt;
  final Map<String, dynamic> metadata; // Additional progress data

  UserProgress({
    required this.id,
    required this.userId,
    required this.type,
    required this.itemId,
    required this.progressPercent,
    required this.lastAccessedAt,
    required this.createdAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'itemId': itemId,
      'progressPercent': progressPercent,
      'lastAccessedAt': Timestamp.fromDate(lastAccessedAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      itemId: map['itemId'] ?? '',
      progressPercent: map['progressPercent'] ?? 0,
      lastAccessedAt: (map['lastAccessedAt'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  factory UserProgress.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProgress.fromMap(data);
  }

  UserProgress copyWith({
    String? type,
    String? itemId,
    int? progressPercent,
    DateTime? lastAccessedAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserProgress(
      id: id,
      userId: userId,
      type: type ?? this.type,
      itemId: itemId ?? this.itemId,
      progressPercent: progressPercent ?? this.progressPercent,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      createdAt: createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'UserProgress(id: $id, type: $type, progress: $progressPercent%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProgress && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// FeedbackModel for compatibility with AdminProvider
class FeedbackModel {
  final String id;
  final String userId;
  final String userName;
  final String type;
  final String title;
  final String content;
  final double? rating;
  final String? relatedItemId; // Add this line
  final DateTime createdAt;
  final DateTime updatedAt;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.title,
    required this.content,
    this.rating,
    this.relatedItemId, // Add this line
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'type': type,
      'title': title,
      'content': content,
      'rating': rating,
      'relatedItemId': relatedItemId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      type: map['type'] ?? 'general',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      rating: map['rating']?.toDouble(),
      relatedItemId: map['relatedItemId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}