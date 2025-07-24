import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/video.dart';
import '../models/test.dart';
import '../models/question.dart';
import '../models/vocabulary.dart';
import '../models/feedback.dart';
import '../models/admin_stats.dart';
import '../models/test_history.dart'; // Import TestHistory

class AdminProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  String? _error;
  
  // Data lists
  List<UserModel> _users = [];
  List<VideoModel> _videos = [];
  List<TestModel> _tests = [];
  List<Question> _questions = [];
  List<VocabularyModel> _vocabularies = [];
  List<FeedbackModel> _feedbacks = [];
  AdminStats? _stats;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserModel> get users => _users;
  List<VideoModel> get videos => _videos;
  List<TestModel> get tests => _tests;
  List<Question> get questions => _questions;
  List<VocabularyModel> get vocabularies => _vocabularies;
  List<FeedbackModel> get feedbacks => _feedbacks;
  AdminStats? get stats => _stats;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // ==========================================================================
  // USER MANAGEMENT
  // ==========================================================================

  Future<void> fetchUsers() async {
    try {
      _setLoading(true);
      _clearError();
      
      final snapshot = await _firestore.collection('users').get();
      _users = snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Error fetching users: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateUser(UserModel user) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestore.collection('users').doc(user.id).update(user.toMap());
      
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Error updating user: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestore.collection('users').doc(userId).delete();
      
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Error deleting user: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================================
  // VIDEO MANAGEMENT
  // ==========================================================================

  Future<void> fetchVideos() async {
    try {
      _setLoading(true);
      _clearError();
      
      final snapshot = await _firestore.collection('videos').get();
      _videos = snapshot.docs.map((doc) => VideoModel.fromMap(doc.data())).toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Error fetching videos: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addVideo(VideoModel video) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestore.collection('videos').doc(video.id).set(video.toMap());
      
      _videos.add(video);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Error adding video: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createVideo(Map<String, dynamic> videoData) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Generate a unique ID for the video
      final videoId = DateTime.now().millisecondsSinceEpoch.toString();
      videoData['id'] = videoId;
      
      await _firestore.collection('videos').doc(videoId).set(videoData);
      
      // Create VideoModel from the data and add to local list
      final video = VideoModel.fromMap(videoData);
      _videos.add(video);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Error creating video: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateVideo(String videoId, Map<String, dynamic> videoData) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestore.collection('videos').doc(videoId).update(videoData);
      
      // Update local list
      final index = _videos.indexWhere((v) => v.id == videoId);
      if (index != -1) {
        final updatedVideo = VideoModel.fromMap({...videoData, 'id': videoId});
        _videos[index] = updatedVideo;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Error updating video: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteVideo(String videoId) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestore.collection('videos').doc(videoId).delete();
      
      _videos.removeWhere((v) => v.id == videoId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Error deleting video: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================================
  // TEST MANAGEMENT
  // ==========================================================================

  Future<void> fetchTests() async {
    try {
      _setLoading(true);
      _clearError();
      
      final snapshot = await _firestore.collection('tests').get();
      _tests = snapshot.docs.map((doc) => TestModel.fromMap(doc.data())).toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Error fetching tests: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addTest(TestModel test) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestore.collection('tests').doc(test.id).set(test.toMap());
      
      _tests.add(test);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Error adding test: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTest(TestModel test) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestore.collection('tests').doc(test.id).update(test.toMap());
      
      final index = _tests.indexWhere((t) => t.id == test.id);
      if (index != -1) {
        _tests[index] = test;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Error updating test: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTest(String testId) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestore.collection('tests').doc(testId).delete();
      
      _tests.removeWhere((t) => t.id == testId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Error deleting test: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================================
  // QUESTION MANAGEMENT
  // ==========================================================================

  Future<void> fetchQuestions() async {
    try {
      _setLoading(true);
      _clearError();
      
      final snapshot = await _firestore.collection('questions').get();
      _questions = snapshot.docs.map((doc) => Question.fromMap(doc.data())).toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Error fetching questions: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addQuestion(Question question) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestore.collection('questions').doc(question.id).set(question.toMap());
      
      _questions.add(question);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Error adding question: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateQuestion(Question question) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestore.collection('questions').doc(question.id).update(question.toMap());
      
      final index = _questions.indexWhere((q) => q.id == question.id);
      if (index != -1) {
        _questions[index] = question;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Error updating question: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteQuestion(String questionId) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestore.collection('questions').doc(questionId).delete();
      
      _questions.removeWhere((q) => q.id == questionId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Error deleting question: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================================
  // VOCABULARY MANAGEMENT
  // ==========================================================================

  Future<void> fetchVocabularies() async {
    try {
      _setLoading(true);
      _clearError();
      
      final snapshot = await _firestore.collection('vocabularies').get();
      _vocabularies = snapshot.docs.map((doc) => VocabularyModel.fromMap(doc.data())).toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Error fetching vocabularies: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================================
  // FEEDBACK MANAGEMENT
  // ==========================================================================

  Future<void> fetchFeedbacks() async {
    try {
      _setLoading(true);
      _clearError();
      
      final List<FeedbackModel> allFeedbacks = [];
      final videosSnapshot = await _firestore.collection('videos').get();

      for (var videoDoc in videosSnapshot.docs) {
        final feedbackSnapshot = await videoDoc.reference.collection('feedback').get();
        for (var feedbackDoc in feedbackSnapshot.docs) {
          final data = feedbackDoc.data();
          final userId = data['userId'];
          String userName = 'Unknown User';

          if (userId != null) {
            final userDoc = await _firestore.collection('users').doc(userId).get();
            if (userDoc.exists) {
              userName = userDoc.data()?['name'] ?? 'Unknown User';
            }
          }

          allFeedbacks.add(FeedbackModel.fromMap({
            ...data,
            'id': feedbackDoc.id,
            'userId': userId, // Ensure userId is passed
            'userName': userName,
            'relatedItemId': videoDoc.id, // Add videoId as relatedItemId
            'type': data['type'] ?? 'video_rating', // Default type if not specified
            'title': data['title'] ?? 'Video Feedback', // Default title
          }));
        }
      }
      _feedbacks = allFeedbacks;
      notifyListeners();
    } catch (e) {
      _setError('Error fetching feedbacks: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteFeedback(String feedbackId, String videoId) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _firestore.collection('videos').doc(videoId).collection('feedback').doc(feedbackId).delete();
      
      _feedbacks.removeWhere((f) => f.id == feedbackId && f.relatedItemId == videoId);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError('Error deleting feedback: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================================================
  // STATISTICS
  // ==========================================================================

  Future<void> fetchStats() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Fetch all data for stats calculation
      final usersSnapshot = await _firestore.collection('users').get();
      final videosSnapshot = await _firestore.collection('videos').get();
      final testsSnapshot = await _firestore.collection('tests').get();
      final vocabulariesSnapshot = await _firestore.collection('vocabularies').get();
      final feedbacksSnapshot = await _firestore.collection('feedbacks').get();
      final testResultsSnapshot = await _firestore.collection('test_results').get(); // Fetch test results
      final testHistorySnapshot = await _firestore.collection('test_history').get(); // Fetch test history

      final users = usersSnapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
      final videos = videosSnapshot.docs.map((doc) => Video.fromDocument(doc)).toList(); // Use Video model
      final testResults = testResultsSnapshot.docs.map((doc) => TestResult.fromDocument(doc)).toList(); // Use TestResult model
      final testHistory = testHistorySnapshot.docs.map((doc) => TestHistory.fromFirestore(doc)).toList(); // Use TestHistory model
      
      // Calculate stats
      Map<String, int> usersByRole = {};
      for (var user in users) {
        usersByRole[user.role.name] = (usersByRole[user.role.name] ?? 0) + 1;
      }
      
      // Test Score Distribution
      Map<String, int> testScoreDistribution = {
        '0-20': 0,
        '21-40': 0,
        '41-60': 0,
        '61-80': 0,
        '81-100': 0,
      };
      for (var result in testResults) {
        if (result.score >= 0 && result.score <= 20) {
          testScoreDistribution['0-20'] = (testScoreDistribution['0-20'] ?? 0) + 1;
        } else if (result.score >= 21 && result.score <= 40) {
          testScoreDistribution['21-40'] = (testScoreDistribution['21-40'] ?? 0) + 1;
        } else if (result.score >= 41 && result.score <= 60) {
          testScoreDistribution['41-60'] = (testScoreDistribution['41-60'] ?? 0) + 1;
        } else if (result.score >= 61 && result.score <= 80) {
          testScoreDistribution['61-80'] = (testScoreDistribution['61-80'] ?? 0) + 1;
        } else if (result.score >= 81 && result.score <= 100) {
          testScoreDistribution['81-100'] = (testScoreDistribution['81-100'] ?? 0) + 1;
        }
      }
      
      // Video View Stats
      int totalVideoViews = 0;
      for (var video in videos) {
        totalVideoViews += video.viewCount;
      }
      // For now, just total views. More granular stats (daily/weekly/monthly) would require more complex data structures in Firestore.
      Map<String, int> videoViewStats = {
        'Total Views': totalVideoViews,
      };
      
      // Vocabulary Learning Stats (simplified - count of unique words learned/reviewed)
      // This would ideally come from user-specific progress tracking, which is not fully implemented yet.
      // For now, we can count total vocabularies and perhaps unique vocabularies in user's sets.
      int totalUniqueVocabularies = vocabulariesSnapshot.docs.length;
      Map<String, int> vocabularyLearningStats = {
        'Total Vocabularies': totalUniqueVocabularies,
        // 'Words Learned': 0, // Requires user-specific tracking
        // 'Words Reviewed': 0, // Requires user-specific tracking
      };
      
      // Recent Activities (from TestHistory)
      List<UserActivity> recentActivities = [];
      // Sort test history by completedAt descending to get most recent
      testHistory.sort((a, b) => b.completedAt.compareTo(a.completedAt));
      for (var i = 0; i < testHistory.length && i < 5; i++) { // Get up to 5 recent activities
        final history = testHistory[i];
        recentActivities.add(UserActivity(
          userId: history.userId,
          userName: users.firstWhere((u) => u.id == history.userId, orElse: () => UserModel(id: '', name: 'Unknown User', email: '', role: UserRole.student, createdAt: DateTime.now(), updatedAt: DateTime.now())).name, // Get user name
          activity: 'Completed test: ${history.testTitle}',
          timestamp: history.completedAt.toDate(),
          details: 'Score: ${history.score}%',
        ));
      }
      
      _stats = AdminStats(
        totalUsers: usersSnapshot.docs.length,
        totalVideos: videosSnapshot.docs.length,
        totalTests: testsSnapshot.docs.length,
        totalVocabularies: vocabulariesSnapshot.docs.length,
        totalFeedbacks: feedbacksSnapshot.docs.length,
        usersByRole: usersByRole,
        testScoreDistribution: testScoreDistribution,
        videoViewStats: videoViewStats,
        vocabularyLearningStats: vocabularyLearningStats,
        recentActivities: recentActivities,
      );
      
      notifyListeners();
    } catch (e) {
      _setError('Error fetching stats: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
}