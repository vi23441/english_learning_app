import 'package:cloud_firestore/cloud_firestore.dart';

class VocabularySet {
  final String id;
  final String name;
  final String description;
  final String createdBy; // User ID or 'admin'
  final List<String> vocabularyIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;

  VocabularySet({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.vocabularyIds,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'vocabularyIds': vocabularyIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublic': isPublic,
    };
  }

  factory VocabularySet.fromMap(Map<String, dynamic> map) {
    return VocabularySet(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['createdBy'] ?? '',
      vocabularyIds: List<String>.from(map['vocabularyIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isPublic: map['isPublic'] ?? false,
    );
  }

  factory VocabularySet.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VocabularySet.fromMap(data..['id'] = doc.id);
  }

  VocabularySet copyWith({
    String? name,
    String? description,
    List<String>? vocabularyIds,
    DateTime? updatedAt,
    bool? isPublic,
  }) {
    return VocabularySet(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy,
      vocabularyIds: vocabularyIds ?? this.vocabularyIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
    );
  }
}
