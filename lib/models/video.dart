import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final List<String> tags;
  final String uploadedBy;
  final double averageRating;
  final int ratingCount;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category; // 'grammar', 'pronunciation', 'conversation', 'vocabulary'
  final String level; // 'beginner', 'intermediate', 'advanced'
  final int duration; // in seconds
  final bool isActive;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.tags,
    required this.uploadedBy,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.viewCount = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.level,
    required this.duration,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'tags': tags,
      'uploadedBy': uploadedBy,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'viewCount': viewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'category': category,
      'level': level,
      'duration': duration,
      'isActive': isActive,
    };
  }

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      uploadedBy: map['uploadedBy'] ?? '',
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      viewCount: map['viewCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      category: map['category'] ?? '',
      level: map['level'] ?? '',
      duration: map['duration'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  factory Video.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Video.fromMap(data..['id'] = doc.id);
  }

  Video copyWith({
    String? title,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    List<String>? tags,
    double? averageRating,
    int? ratingCount,
    int? viewCount,
    DateTime? updatedAt,
    String? category,
    String? level,
    int? duration,
    bool? isActive,
  }) {
    return Video(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      tags: tags ?? this.tags,
      uploadedBy: uploadedBy,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      level: level ?? this.level,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Video(id: $id, title: $title, category: $category, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Video && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// New VideoModel for compatibility with AdminProvider
class VideoModel {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String? thumbnailUrl;
  final int duration; // in minutes
  final String level;
  final String category;
  final int views;
  final DateTime createdAt;
  final DateTime updatedAt;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.duration,
    required this.level,
    required this.category,
    this.views = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'level': level,
      'category': category,
      'views': views,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      duration: map['duration'] ?? 0,
      level: map['level'] ?? 'Beginner',
      category: map['category'] ?? 'Grammar',
      views: map['views'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  VideoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    int? duration,
    String? level,
    String? category,
    int? views,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      level: level ?? this.level,
      category: category ?? this.category,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}