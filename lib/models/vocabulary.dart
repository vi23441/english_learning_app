import 'package:cloud_firestore/cloud_firestore.dart';

enum VocabularyLevel {
  beginner,
  intermediate,
  advanced,
}

extension VocabularyLevelExtension on VocabularyLevel {
  String get displayName {
    switch (this) {
      case VocabularyLevel.beginner:
        return 'Beginner';
      case VocabularyLevel.intermediate:
        return 'Intermediate';
      case VocabularyLevel.advanced:
        return 'Advanced';
    }
  }
  
  String get value {
    switch (this) {
      case VocabularyLevel.beginner:
        return 'beginner';
      case VocabularyLevel.intermediate:
        return 'intermediate';
      case VocabularyLevel.advanced:
        return 'advanced';
    }
  }
  
  static VocabularyLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'beginner':
        return VocabularyLevel.beginner;
      case 'intermediate':
        return VocabularyLevel.intermediate;
      case 'advanced':
        return VocabularyLevel.advanced;
      default:
        return VocabularyLevel.beginner;
    }
  }
}

class VocabularyTopic {
  final String id;
  final String name;
  final String title; // Add title property
  final String description;
  final String level; // 'beginner', 'intermediate', 'advanced'
  final String imageUrl;
  final int wordCount;
  final int totalWords; // Add totalWords property
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  VocabularyTopic({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.level,
    required this.imageUrl,
    this.wordCount = 0,
    this.totalWords = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'level': level,
      'imageUrl': imageUrl,
      'wordCount': wordCount,
      'totalWords': totalWords,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  factory VocabularyTopic.fromMap(Map<String, dynamic> map) {
    return VocabularyTopic(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      title: map['title'] ?? map['name'] ?? '',
      description: map['description'] ?? '',
      level: map['level'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      wordCount: map['wordCount'] ?? 0,
      totalWords: map['totalWords'] ?? map['wordCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  factory VocabularyTopic.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VocabularyTopic.fromMap(data);
  }

  VocabularyTopic copyWith({
    String? name,
    String? title,
    String? description,
    String? level,
    String? imageUrl,
    int? wordCount,
    int? totalWords,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return VocabularyTopic(
      id: id,
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      imageUrl: imageUrl ?? this.imageUrl,
      wordCount: wordCount ?? this.wordCount,
      totalWords: totalWords ?? this.totalWords,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'VocabularyTopic(id: $id, name: $name, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VocabularyTopic && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Vocabulary {
  final String id;
  final String topicId;
  final String word;
  final String definition;
  final String pronunciation;
  final String phonetic; // Add phonetic property
  final String example;
  final String imageUrl;
  final String audioUrl;
  final String partOfSpeech; // 'noun', 'verb', 'adjective', etc.
  final String level;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isBookmarked; // Add isBookmarked property

  // Fields for flashcard functionality
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;
  final int familiarityScore; // 0-5, 0 = new, 5 = mastered

  Vocabulary({
    required this.id,
    required this.topicId,
    required this.word,
    required this.definition,
    required this.pronunciation,
    required this.phonetic,
    required this.example,
    this.imageUrl = '',
    this.audioUrl = '',
    required this.partOfSpeech,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isBookmarked = false,
    this.lastReviewedAt,
    this.nextReviewAt,
    this.familiarityScore = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topicId': topicId,
      'word': word,
      'definition': definition,
      'pronunciation': pronunciation,
      'phonetic': phonetic,
      'example': example,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'partOfSpeech': partOfSpeech,
      'level': level,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'isBookmarked': isBookmarked,
      'lastReviewedAt': lastReviewedAt != null ? Timestamp.fromDate(lastReviewedAt!) : null,
      'nextReviewAt': nextReviewAt != null ? Timestamp.fromDate(nextReviewAt!) : null,
      'familiarityScore': familiarityScore,
    };
  }

  factory Vocabulary.fromMap(Map<String, dynamic> map) {
    return Vocabulary(
      id: map['id'] ?? '',
      topicId: map['topicId'] ?? '',
      word: map['word'] ?? '',
      definition: map['definition'] ?? '',
      pronunciation: map['pronunciation'] ?? '',
      phonetic: map['phonetic'] ?? map['pronunciation'] ?? '',
      example: map['example'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      partOfSpeech: map['partOfSpeech'] ?? '',
      level: map['level'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
      isBookmarked: map['isBookmarked'] ?? false,
      lastReviewedAt: (map['lastReviewedAt'] as Timestamp?)?.toDate(),
      nextReviewAt: (map['nextReviewAt'] as Timestamp?)?.toDate(),
      familiarityScore: map['familiarityScore'] ?? 0,
    );
  }

  factory Vocabulary.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vocabulary.fromMap(data);
  }

  Vocabulary copyWith({
    String? topicId,
    String? word,
    String? definition,
    String? pronunciation,
    String? phonetic,
    String? example,
    String? imageUrl,
    String? audioUrl,
    String? partOfSpeech,
    String? level,
    DateTime? updatedAt,
    bool? isActive,
    bool? isBookmarked,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
    int? familiarityScore,
  }) {
    return Vocabulary(
      id: id,
      topicId: topicId ?? this.topicId,
      word: word ?? this.word,
      definition: definition ?? this.definition,
      pronunciation: pronunciation ?? this.pronunciation,
      phonetic: phonetic ?? this.phonetic,
      example: example ?? this.example,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      level: level ?? this.level,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      familiarityScore: familiarityScore ?? this.familiarityScore,
    );
  }

  @override
  String toString() {
    return 'Vocabulary(id: $id, word: $word, definition: $definition)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vocabulary && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// VocabularyModel for compatibility with AdminProvider
class VocabularyModel {
  final String id;
  final String word;
  final String definition;
  final String pronunciation;
  final String example;
  final String level;
  final DateTime createdAt;
  final DateTime updatedAt;

  VocabularyModel({
    required this.id,
    required this.word,
    required this.definition,
    required this.pronunciation,
    required this.example,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'definition': definition,
      'pronunciation': pronunciation,
      'example': example,
      'level': level,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory VocabularyModel.fromMap(Map<String, dynamic> map) {
    return VocabularyModel(
      id: map['id'] ?? '',
      word: map['word'] ?? '',
      definition: map['definition'] ?? '',
      pronunciation: map['pronunciation'] ?? '',
      example: map['example'] ?? '',
      level: map['level'] ?? 'Beginner',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}