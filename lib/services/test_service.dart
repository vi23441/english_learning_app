import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/test.dart';
import '../models/test_history.dart';

class TestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Collection references
  CollectionReference get _testsCollection => _firestore.collection('tests');
  CollectionReference get _testResultsCollection =>
      _firestore.collection('test_results');
  CollectionReference get _testHistoryCollection =>
      _firestore.collection('test_history');
  CollectionReference get _statisticsCollection =>
      _firestore.collection('statistics');

  // Get all tests
  Future<List<Test>> getTests() async {
    try {
      final QuerySnapshot snapshot =
          await _testsCollection.orderBy('createdAt', descending: true).get();

      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          if (data is Map<String, dynamic>) {
            data['id'] = doc.id;
            return Test.fromMap(data);
          } else {
            print(
                'Document ${doc.id} data is not Map<String, dynamic>: ${data.runtimeType}');
            return null;
          }
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
          return null;
        }
      }).where((test) => test != null).cast<Test>().toList();
    } catch (e) {
      print('Failed to load tests: $e');
      return [];
    }
  }

  // Get tests by category
  Future<List<Test>> getTestsByCategory(TestCategory category) async {
    try {
      final QuerySnapshot snapshot = await _testsCollection
          .where('category', isEqualTo: category.name)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          if (data is Map<String, dynamic>) {
            data['id'] = doc.id;
            return Test.fromMap(data);
          } else {
            print(
                'Document ${doc.id} data is not Map<String, dynamic>: ${data.runtimeType}');
            return null;
          }
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
          return null;
        }
      }).where((test) => test != null).cast<Test>().toList();
    } catch (e) {
      print('Failed to load tests by category: $e');
      return [];
    }
  }

  // Get tests by difficulty
  Future<List<Test>> getTestsByDifficulty(TestDifficulty difficulty) async {
    try {
      final QuerySnapshot snapshot = await _testsCollection
          .where('difficulty', isEqualTo: difficulty.name)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          if (data is Map<String, dynamic>) {
            data['id'] = doc.id;
            return Test.fromMap(data);
          } else {
            print(
                'Document ${doc.id} data is not Map<String, dynamic>: ${data.runtimeType}');
            return null;
          }
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
          return null;
        }
      }).where((test) => test != null).cast<Test>().toList();
    } catch (e) {
      print('Failed to load tests by difficulty: $e');
      return [];
    }
  }

  // Get test by ID
  Future<Test?> getTestById(String testId) async {
    try {
      final DocumentSnapshot doc = await _testsCollection.doc(testId).get();

      if (!doc.exists) {
        print('Test not found: $testId');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        data['id'] = doc.id;

        // Check if 'questions' field is a list of IDs
        if (data['questions'] is List &&
            data['questions'].isNotEmpty &&
            (data['questions'][0] is String || data['questions'][0] is int)) {
          final questionIds = (data['questions'] as List<dynamic>).map((id) => id.toString()).toList();
          final questionFutures = questionIds
              .map((id) => _firestore.collection('questions').doc(id).get());
          final questionSnapshots = await Future.wait(questionFutures);

          final questionMaps = questionSnapshots.map((snap) {
            if (snap.exists) {
              final questionData = snap.data() as Map<String, dynamic>;
              questionData['id'] = snap.id;
              return questionData;
            }
            return null;
          }).where((q) => q != null).cast<Map<String, dynamic>>().toList();
          
          data['questions'] = questionMaps;
        }

        return Test.fromMap(data);
      } else {
        print('Document $testId data is null');
        return null;
      }
    } catch (e) {
      print('Failed to load test $testId: $e');
      return null;
    }
  }

  // Search tests
  Future<List<Test>> searchTests(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation - consider using Algolia or similar for better search
      final QuerySnapshot snapshot = await _testsCollection
          .orderBy('title')
          .startAt([query])
          .endAt([query + ''])
          .get();

      return snapshot.docs
          .map((doc) => Test.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search tests: $e');
    }
  }

  // Create test (admin/teacher only)
  Future<Test> createTest(Test test) async {
    try {
      final String testId = _uuid.v4();
      final testWithId = test.copyWith(
        updatedAt: DateTime.now(),
      );

      await _testsCollection.doc(testId).set(testWithId.toMap());

      return testWithId;
    } catch (e) {
      throw Exception('Failed to create test: $e');
    }
  }

  // Update test (admin/teacher only)
  Future<Test> updateTest(Test test) async {
    try {
      await _testsCollection.doc(test.id).update(test.toMap());
      return test;
    } catch (e) {
      throw Exception('Failed to update test: $e');
    }
  }

  // Delete test (admin/teacher only)
  Future<void> deleteTest(String testId) async {
    try {
      await _testsCollection.doc(testId).delete();
    } catch (e) {
      throw Exception('Failed to delete test: $e');
    }
  }

  // Save test result
  Future<TestResult> saveTestResult(TestResult testResult) async {
    try {
      final String resultId = _uuid.v4();
      final resultWithId = testResult.copyWith(id: resultId);

      await _testResultsCollection.doc(resultId).set(resultWithId.toMap());

      // Update user statistics
      await _updateUserStatistics(testResult.userId, testResult);

      return resultWithId;
    } catch (e) {
      throw Exception('Failed to save test result: $e');
    }
  }

  // Get user test results
  Future<List<TestResult>> getUserTestResults(String userId) async {
    try {
      final QuerySnapshot snapshot = await _testResultsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TestResult.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load test results: $e');
    }
  }

  // Get test results for a specific test
  Future<List<TestResult>> getTestResults(String testId) async {
    try {
      final QuerySnapshot snapshot = await _testResultsCollection
          .where('testId', isEqualTo: testId)
          .orderBy('completedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TestResult.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load test results: $e');
    }
  }

  // Get test statistics for a user
  Future<Map<String, dynamic>> getTestStatistics(String userId) async {
    try {
      final DocumentSnapshot doc =
          await _statisticsCollection.doc('test_stats_$userId').get();

      if (!doc.exists) {
        return {
          'totalTests': 0,
          'averageScore': 0.0,
          'totalTime': 0,
          'categoriesStats': <String, dynamic>{},
          'difficultyStats': <String, dynamic>{},
          'recentResults': <Map<String, dynamic>>[],
        };
      }

      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load test statistics: $e');
    }
  }

  // Get test analytics (for admin/teacher)
  Future<Map<String, dynamic>> getTestAnalytics(String testId) async {
    try {
      final List<TestResult> results = await getTestResults(testId);

      if (results.isEmpty) {
        return {
          'totalAttempts': 0,
          'averageScore': 0.0,
          'averageTime': 0,
          'difficultyAnalysis': <String, dynamic>{},
          'questionAnalysis': <String, dynamic>{},
        };
      }

      // Calculate analytics
      final int totalAttempts = results.length;
      final double averageScore =
          results.map((r) => r.score).reduce((a, b) => a + b) / totalAttempts;
      final int averageTime =
          results.map((r) => r.timeTaken).reduce((a, b) => a + b) ~/
              totalAttempts;

      // Question analysis
      final Map<String, dynamic> questionAnalysis = {};
      for (final result in results) {
        for (final questionResult in result.questionResults) {
          final questionId = questionResult.questionId;
          if (!questionAnalysis.containsKey(questionId)) {
            questionAnalysis[questionId] = {
              'totalAttempts': 0,
              'correctAnswers': 0,
              'averageTime': 0,
            };
          }

          questionAnalysis[questionId]['totalAttempts']++;
          if (questionResult.isCorrect) {
            questionAnalysis[questionId]['correctAnswers']++;
          }
          questionAnalysis[questionId]['averageTime'] =
              (questionAnalysis[questionId]['averageTime'] +
                      questionResult.timeSpent) /
                  2;
        }
      }

      return {
        'totalAttempts': totalAttempts,
        'averageScore': averageScore,
        'averageTime': averageTime,
        'questionAnalysis': questionAnalysis,
        'scoreDistribution': _calculateScoreDistribution(results),
        'timeDistribution': _calculateTimeDistribution(results),
      };
    } catch (e) {
      throw Exception('Failed to load test analytics: $e');
    }
  }

  // Save test history
  Future<void> saveTestHistory(TestHistory history) async {
    try {
      await _testHistoryCollection.doc(history.id).set(history.toMap());
    } catch (e) {
      throw Exception('Failed to save test history: $e');
    }
  }

  // Get user test history
  Future<List<TestHistory>> getUserTestHistory(String userId) async {
    try {
      final QuerySnapshot snapshot = await _testHistoryCollection
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TestHistory.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load test history: $e');
    }
  }

  // Private helper methods
  Future<void> _updateUserStatistics(String userId, TestResult testResult) async {
    try {
      final String docId = 'test_stats_$userId';
      final DocumentReference docRef = _statisticsCollection.doc(docId);

      await _firestore.runTransaction((transaction) async {
        final DocumentSnapshot doc = await transaction.get(docRef);

        Map<String, dynamic> stats = doc.exists
            ? doc.data() as Map<String, dynamic>
            : {
                'totalTests': 0,
                'totalScore': 0,
                'totalTime': 0,
                'categoriesStats': <String, dynamic>{},
                'difficultyStats': <String, dynamic>{},
                'recentResults': <Map<String, dynamic>>[],
              };

        // Update overall stats
        stats['totalTests'] = (stats['totalTests'] as int) + 1;
        stats['totalScore'] = (stats['totalScore'] as int) + testResult.score;
        stats['totalTime'] = (stats['totalTime'] as int) + testResult.timeTaken;
        stats['averageScore'] =
            (stats['totalScore'] as int) / (stats['totalTests'] as int);

        // Update recent results (keep last 10)
        final recentResults =
            List<Map<String, dynamic>>.from(stats['recentResults'] as List);
        recentResults.insert(0, {
          'testId': testResult.testId,
          'score': testResult.score,
          'completedAt': testResult.completedAt.toIso8601String(),
        });

        if (recentResults.length > 10) {
          recentResults.removeRange(10, recentResults.length);
        }

        stats['recentResults'] = recentResults;
        stats['lastUpdated'] = DateTime.now().toIso8601String();

        transaction.set(docRef, stats);
      });
    } catch (e) {
      throw Exception('Failed to update user statistics: $e');
    }
  }

  Map<String, int> _calculateScoreDistribution(List<TestResult> results) {
    final Map<String, int> distribution = {
      '0-20': 0,
      '21-40': 0,
      '41-60': 0,
      '61-80': 0,
      '81-100': 0,
    };

    for (final result in results) {
      if (result.score <= 20) {
        distribution['0-20'] = distribution['0-20']! + 1;
      } else if (result.score <= 40) {
        distribution['21-40'] = distribution['21-40']! + 1;
      } else if (result.score <= 60) {
        distribution['41-60'] = distribution['41-60']! + 1;
      } else if (result.score <= 80) {
        distribution['61-80'] = distribution['61-80']! + 1;
      } else {
        distribution['81-100'] = distribution['81-100']! + 1;
      }
    }

    return distribution;
  }

  Map<String, int> _calculateTimeDistribution(List<TestResult> results) {
    final Map<String, int> distribution = {
      '0-5min': 0,
      '5-10min': 0,
      '10-15min': 0,
      '15-20min': 0,
      '20+min': 0,
    };

    for (final result in results) {
      final minutes = result.timeTaken ~/ 60;
      if (minutes <= 5) {
        distribution['0-5min'] = distribution['0-5min']! + 1;
      } else if (minutes <= 10) {
        distribution['5-10min'] = distribution['5-10min']! + 1;
      } else if (minutes <= 15) {
        distribution['10-15min'] = distribution['10-15min']! + 1;
      } else if (minutes <= 20) {
        distribution['15-20min'] = distribution['15-20min']! + 1;
      } else {
        distribution['20+min'] = distribution['20+min']! + 1;
      }
    }

    return distribution;
  }
}