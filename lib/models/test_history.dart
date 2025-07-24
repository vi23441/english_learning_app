import 'package:cloud_firestore/cloud_firestore.dart';

class TestHistory {
  final String id;
  final String userId;
  final String testId;
  final String testTitle;
  final int score;
  final int totalQuestions;
  final Timestamp completedAt;
  final Map<String, dynamic> userAnswers; // Store questionId and selected answer

  TestHistory({
    required this.id,
    required this.userId,
    required this.testId,
    required this.testTitle,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
    required this.userAnswers,
  });

  factory TestHistory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TestHistory(
      id: doc.id,
      userId: data['userId'] ?? '',
      testId: data['testId'] ?? '',
      testTitle: data['testTitle'] ?? '',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      completedAt: data['completedAt'] ?? Timestamp.now(),
      userAnswers: Map<String, dynamic>.from(data['userAnswers'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'testId': testId,
      'testTitle': testTitle,
      'score': score,
      'totalQuestions': totalQuestions,
      'completedAt': completedAt,
      'userAnswers': userAnswers,
    };
  }
}
