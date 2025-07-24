import 'package:cloud_firestore/cloud_firestore.dart';

enum TestCategory {
  vocabulary,
  grammar,
  listening,
  reading,
  writing,
  speaking,
  general,
}

extension TestCategoryExtension on TestCategory {
  String get displayName {
    switch (this) {
      case TestCategory.vocabulary:
        return 'Vocabulary';
      case TestCategory.grammar:
        return 'Grammar';
      case TestCategory.listening:
        return 'Listening';
      case TestCategory.reading:
        return 'Reading';
      case TestCategory.writing:
        return 'Writing';
      case TestCategory.speaking:
        return 'Speaking';
      case TestCategory.general:
        return 'General';
    }
  }
  
  String get value {
    switch (this) {
      case TestCategory.vocabulary:
        return 'vocabulary';
      case TestCategory.grammar:
        return 'grammar';
      case TestCategory.listening:
        return 'listening';
      case TestCategory.reading:
        return 'reading';
      case TestCategory.writing:
        return 'writing';
      case TestCategory.speaking:
        return 'speaking';
      case TestCategory.general:
        return 'general';
    }
  }
  
  static TestCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'vocabulary':
        return TestCategory.vocabulary;
      case 'grammar':
        return TestCategory.grammar;
      case 'listening':
        return TestCategory.listening;
      case 'reading':
        return TestCategory.reading;
      case 'writing':
        return TestCategory.writing;
      case 'speaking':
        return TestCategory.speaking;
      case 'general':
        return TestCategory.general;
      default:
        return TestCategory.general;
    }
  }
}

enum TestDifficulty {
  beginner,
  intermediate,
  advanced,
}

extension TestDifficultyExtension on TestDifficulty {
  String get displayName {
    switch (this) {
      case TestDifficulty.beginner:
        return 'Beginner';
      case TestDifficulty.intermediate:
        return 'Intermediate';
      case TestDifficulty.advanced:
        return 'Advanced';
    }
  }
  
  String get value {
    switch (this) {
      case TestDifficulty.beginner:
        return 'beginner';
      case TestDifficulty.intermediate:
        return 'intermediate';
      case TestDifficulty.advanced:
        return 'advanced';
    }
  }
  
  static TestDifficulty fromString(String value) {
    switch (value.toLowerCase()) {
      case 'beginner':
        return TestDifficulty.beginner;
      case 'intermediate':
        return TestDifficulty.intermediate;
      case 'advanced':
        return TestDifficulty.advanced;
      default:
        return TestDifficulty.beginner;
    }
  }
}

class Test {
  final String id;
  final String title;
  final String description;
  final String level; // 'beginner', 'intermediate', 'advanced'
  final String skill; // 'listening', 'reading', 'writing', 'speaking', 'grammar'
  final TestCategory category;
  final TestDifficulty difficulty;
  final List<String> questionIds;
  final List<TestQuestion> questions;
  final int timeLimit; // in minutes
  final int duration; // in minutes
  final int passingScore; // percentage
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool isActive;
  final bool isShuffled;

  Test({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.skill,
    required this.category,
    required this.difficulty,
    required this.questionIds,
    required this.questions,
    required this.timeLimit,
    required this.duration,
    required this.passingScore,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.isActive = true,
    this.isShuffled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'skill': skill,
      'category': category.value,
      'difficulty': difficulty.value,
      'questionIds': questionIds,
      'questions': questions.map((e) => e.toMap()).toList(),
      'timeLimit': timeLimit,
      'duration': duration,
      'passingScore': passingScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
      'isActive': isActive,
      'isShuffled': isShuffled,
    };
  }

  factory Test.fromMap(Map<String, dynamic> map) {
    return Test(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'No Title',
      description: map['description'] as String? ?? 'No Description',
      level: map['level'] as String? ?? 'N/A',
      skill: map['skill'] as String? ?? 'N/A',
      category: TestCategoryExtension.fromString(map['category'] as String? ?? 'general'),
      difficulty: TestDifficultyExtension.fromString(map['difficulty'] as String? ?? 'beginner'),
      questionIds: List<String>.from(map['questionIds'] as List<dynamic>? ?? []),
      questions: (map['questions'] as List<dynamic>?)
              ?.map((e) {
                if (e is Map<String, dynamic>) {
                  return TestQuestion.fromMap(e);
                }
                return null;
              })
              .where((element) => element != null)
              .map((e) => e as TestQuestion)
              .toList() ??
          [],
      timeLimit: map['timeLimit'] as int? ?? 60,
      duration: map['duration'] as int? ?? map['timeLimit'] as int? ?? 60,
      passingScore: map['passingScore'] as int? ?? 70,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      isShuffled: map['isShuffled'] as bool? ?? false,
    );
  }

  factory Test.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Test.fromMap(data);
  }

  Test copyWith({
    String? title,
    String? description,
    String? level,
    String? skill,
    TestCategory? category,
    TestDifficulty? difficulty,
    List<String>? questionIds,
    List<TestQuestion>? questions,
    int? timeLimit,
    int? duration,
    int? passingScore,
    DateTime? updatedAt,
    bool? isActive,
    bool? isShuffled,
  }) {
    return Test(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      skill: skill ?? this.skill,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      questionIds: questionIds ?? this.questionIds,
      questions: questions ?? this.questions,
      timeLimit: timeLimit ?? this.timeLimit,
      duration: duration ?? this.duration,
      passingScore: passingScore ?? this.passingScore,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy,
      isActive: isActive ?? this.isActive,
      isShuffled: isShuffled ?? this.isShuffled,
    );
  }

  @override
  String toString() {
    return 'Test(id: $id, title: $title, level: $level, skill: $skill)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Test && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class TestQuestion {
  final String id;
  final String testId;
  final String question;
  final String questionType; // 'multiple_choice', 'true_false', 'fill_blank', 'essay'
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String imageUrl;
  final String audioUrl;
  final int points;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  TestQuestion({
    required this.id,
    required this.testId,
    required this.question,
    required this.questionType,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.imageUrl = '',
    this.audioUrl = '',
    this.points = 1,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'testId': testId,
      'question': question,
      'questionType': questionType,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'points': points,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  factory TestQuestion.fromMap(Map<String, dynamic> map) {
    return TestQuestion(
      id: map['id'] as String? ?? '',
      testId: map['testId'] as String? ?? '',
      question: map['question'] as String? ?? map['content'] as String? ?? '',
      questionType: map['questionType'] as String? ?? '',
      options: (map['options'] as List<dynamic>? ?? []).map((o) => o.toString()).toList(),
      correctAnswer: map['correctAnswer']?.toString() ?? '',
      explanation: map['explanation'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      audioUrl: map['audioUrl'] as String? ?? '',
      points: map['points'] as int? ?? 1,
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : (map['createdAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
              : DateTime.now()),
      updatedAt: (map['updatedAt'] is Timestamp)
          ? (map['updatedAt'] as Timestamp).toDate()
          : (map['updatedAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
              : DateTime.now()),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  factory TestQuestion.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestQuestion.fromMap(data);
  }

  TestQuestion copyWith({
    String? testId,
    String? question,
    String? questionType,
    List<String>? options,
    String? correctAnswer,
    String? explanation,
    String? imageUrl,
    String? audioUrl,
    int? points,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return TestQuestion(
      id: id,
      testId: testId ?? this.testId,
      question: question ?? this.question,
      questionType: questionType ?? this.questionType,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      points: points ?? this.points,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'TestQuestion(id: $id, question: $question, type: $questionType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestQuestion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class QuestionResult {
  final String questionId;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final int points;
  final int timeSpent; // in seconds

  QuestionResult({
    required this.questionId,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.points,
    required this.timeSpent,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'points': points,
      'timeSpent': timeSpent,
    };
  }

  factory QuestionResult.fromMap(Map<String, dynamic> map) {
    return QuestionResult(
      questionId: map['questionId'] ?? '',
      selectedAnswer: map['selectedAnswer'] ?? '',
      correctAnswer: map['correctAnswer'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
      points: map['points'] ?? 0,
      timeSpent: map['timeSpent'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'QuestionResult(questionId: $questionId, isCorrect: $isCorrect)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionResult && other.questionId == questionId;
  }

  @override
  int get hashCode => questionId.hashCode;
}

class TestResult {
  final String id;
  final String testId;
  final String userId;
  final Map<String, String> answers; // questionId -> selectedAnswer
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int timeSpent; // in seconds
  final int timeTaken; // in seconds
  final DateTime startedAt;
  final DateTime completedAt;
  final bool isPassed;
  final List<QuestionResult> questionResults;

  TestResult({
    required this.id,
    required this.testId,
    required this.userId,
    required this.answers,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpent,
    required this.timeTaken,
    required this.startedAt,
    required this.completedAt,
    required this.isPassed,
    required this.questionResults,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'testId': testId,
      'userId': userId,
      'answers': answers,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'timeSpent': timeSpent,
      'timeTaken': timeTaken,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': Timestamp.fromDate(completedAt),
      'isPassed': isPassed,
      'questionResults': questionResults.map((e) => e.toMap()).toList(),
    };
  }

  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      id: map['id'] ?? '',
      testId: map['testId'] ?? '',
      userId: map['userId'] ?? '',
      answers: Map<String, String>.from(map['answers'] ?? {}),
      score: map['score'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      timeSpent: map['timeSpent'] ?? 0,
      timeTaken: map['timeTaken'] ?? map['timeSpent'] ?? 0,
      startedAt: (map['startedAt'] is Timestamp)
          ? (map['startedAt'] as Timestamp).toDate()
          : (map['startedAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['startedAt'] as int)
              : DateTime.now()),
      completedAt: (map['completedAt'] is Timestamp)
          ? (map['completedAt'] as Timestamp).toDate()
          : (map['completedAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int)
              : DateTime.now()),
      isPassed: map['isPassed'] ?? false,
      questionResults: (map['questionResults'] as List<dynamic>?)
          ?.map((e) => QuestionResult.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  factory TestResult.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestResult.fromMap(data);
  }

  TestResult copyWith({
    String? id,
    String? testId,
    String? userId,
    Map<String, String>? answers,
    int? score,
    int? correctAnswers,
    int? totalQuestions,
    int? timeSpent,
    int? timeTaken,
    DateTime? startedAt,
    DateTime? completedAt,
    bool? isPassed,
    List<QuestionResult>? questionResults,
  }) {
    return TestResult(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      userId: userId ?? this.userId,
      answers: answers ?? this.answers,
      score: score ?? this.score,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      timeSpent: timeSpent ?? this.timeSpent,
      timeTaken: timeTaken ?? this.timeTaken,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      isPassed: isPassed ?? this.isPassed,
      questionResults: questionResults ?? this.questionResults,
    );
  }

  double get percentage => totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

  @override
  String toString() {
    return 'TestResult(id: $id, score: $score/$totalQuestions, passed: $isPassed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestResult && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// TestModel for compatibility with AdminProvider
class TestModel {
  final String id;
  final String title;
  final String description;
  final List<String> questions;
  final int duration; // in minutes
  final String level;
  final DateTime createdAt;
  final DateTime updatedAt;

  TestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.duration,
    required this.level,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions,
      'duration': duration,
      'level': level,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory TestModel.fromMap(Map<String, dynamic> map) {
    return TestModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      questions: List<String>.from(map['questions'] ?? []),
      duration: map['duration'] ?? 0,
      level: map['level'] ?? 'Beginner',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  TestModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? questions,
    int? duration,
    String? level,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      duration: duration ?? this.duration,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
