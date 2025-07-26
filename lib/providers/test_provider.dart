import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/test.dart';
import '../models/test_history.dart';
import '../services/test_service.dart';

class TestProvider with ChangeNotifier {
  final TestService _testService = TestService();
  
  List<Test> _tests = [];
  List<Test> _filteredTests = [];
  Test? _currentTest;
  List<TestResult> _testResults = [];
  List<TestHistory> _testHistory = [];
  bool _isLoading = false;
  String? _error;
  
  // Current test session state
  int _currentQuestionIndex = 0;
  List<String> _userAnswers = [];
  Map<String, dynamic>? _currentAnswer;
  DateTime? _testStartTime;
  DateTime? _testEndTime;
  bool _isTestCompleted = false;
  
  // Getters
  List<Test> get tests => _tests;
  List<Test> get filteredTests => _filteredTests;
  Test? get currentTest => _currentTest;
  List<TestResult> get testResults => _testResults;
  List<TestHistory> get testHistory => _testHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Test session getters
  int get currentQuestionIndex => _currentQuestionIndex;
  List<String> get userAnswers => _userAnswers;
  Map<String, dynamic>? get currentAnswer => _currentAnswer;
  DateTime? get testStartTime => _testStartTime;
  DateTime? get testEndTime => _testEndTime;
  bool get isTestCompleted => _isTestCompleted;
  
  TestQuestion? get currentQuestion => 
    _currentTest != null && _currentQuestionIndex < _currentTest!.questions.length
      ? _currentTest!.questions[_currentQuestionIndex]
      : null;
  
  int get totalQuestions => _currentTest?.questions.length ?? 0;
  int get remainingQuestions => totalQuestions - _currentQuestionIndex;
  Duration get timeElapsed => _testStartTime != null 
    ? DateTime.now().difference(_testStartTime!) 
    : Duration.zero;
  
  // Load all tests
  Future<void> loadTests() async {
    _setLoading(true);
    try {
      print('TestProvider: Starting to load tests...');
      _tests = await _testService.getTests();
      print('TestProvider: Loaded ${_tests.length} tests');
      _filteredTests = List.from(_tests);
      _clearError();
    } catch (e) {
      print('TestProvider: Error loading tests: $e');
      _setError('Failed to load tests: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load tests by category
  Future<void> loadTestsByCategory(TestCategory category) async {
    _setLoading(true);
    try {
      _tests = await _testService.getTestsByCategory(category);
      _filteredTests = List.from(_tests);
      _clearError();
    } catch (e) {
      _setError('Failed to load tests: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load tests by difficulty
  Future<void> loadTestsByDifficulty(TestDifficulty difficulty) async {
    _setLoading(true);
    try {
      _tests = await _testService.getTestsByDifficulty(difficulty);
      _filteredTests = List.from(_tests);
      _clearError();
    } catch (e) {
      _setError('Failed to load tests: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Search tests
  void searchTests(String query) {
    if (query.isEmpty) {
      _filteredTests = List.from(_tests);
    } else {
      _filteredTests = _tests.where((test) =>
        test.title.toLowerCase().contains(query.toLowerCase()) ||
        test.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }
  
  // Filter tests
  void filterTests({
    TestCategory? category,
    TestDifficulty? difficulty,
    int? minDuration,
    int? maxDuration,
  }) {
    _filteredTests = _tests.where((test) {
      if (category != null && test.category != category) return false;
      if (difficulty != null && test.difficulty != difficulty) return false;
      if (minDuration != null && test.duration < minDuration) return false;
      if (maxDuration != null && test.duration > maxDuration) return false;
      return true;
    }).toList();
    notifyListeners();
  }
  
  // Start test session
  Future<void> startTest(String testId) async {
    _setLoading(true);
    try {
      final test = await _testService.getTestById(testId);
      if (test == null) {
        throw Exception('Test not found or failed to load');
      }
      
      _currentTest = test;
      _currentQuestionIndex = 0;
      _userAnswers = List.filled(_currentTest!.questions.length, '');
      _currentAnswer = null;
      _testStartTime = DateTime.now();
      _testEndTime = null;
      _isTestCompleted = false;
      
      // Shuffle questions if test allows it
      if (_currentTest!.isShuffled) {
        _currentTest!.questions.shuffle();
      }
      
      _clearError();
    } catch (e) {
      _setError('Failed to start test: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Answer question
  void answerQuestion(String answer) {
    if (_currentTest != null && _currentQuestionIndex < _userAnswers.length) {
      _userAnswers[_currentQuestionIndex] = answer;
      _currentAnswer = {
        'questionId': currentQuestion?.id,
        'answer': answer,
        'timestamp': DateTime.now(),
      };
      notifyListeners();
    }
  }
  
  // Navigate to next question
  void nextQuestion() {
    if (_currentTest != null && _currentQuestionIndex < _currentTest!.questions.length - 1) {
      _currentQuestionIndex++;
      _currentAnswer = null;
      notifyListeners();
    }
  }
  
  // Navigate to previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      _currentAnswer = null;
      notifyListeners();
    }
  }
  
  // Go to specific question
  void goToQuestion(int index) {
    if (_currentTest != null && index >= 0 && index < _currentTest!.questions.length) {
      _currentQuestionIndex = index;
      _currentAnswer = null;
      notifyListeners();
    }
  }
  
  // Submit test
  Future<TestResult?> submitTest(String userId) async {
    if (_currentTest == null) return null;
    
    _setLoading(true);
    try {
      _testEndTime = DateTime.now();
      _isTestCompleted = true;
      
      // Calculate score
      int correctAnswers = 0;
      final questionResults = <QuestionResult>[];
      
      for (int i = 0; i < _currentTest!.questions.length; i++) {
        final question = _currentTest!.questions[i];
        final userAnswer = _userAnswers[i];
        final isCorrect = userAnswer == question.correctAnswer;
        
        if (isCorrect) correctAnswers++;
        
        questionResults.add(QuestionResult(
          questionId: question.id,
          selectedAnswer: userAnswer,
          correctAnswer: question.correctAnswer,
          isCorrect: isCorrect,
          points: isCorrect ? 1 : 0,
          timeSpent: 0, // TODO: Track time per question
        ));
      }
      
      final score = (correctAnswers / _currentTest!.questions.length * 100).round();
      final timeTaken = _testEndTime!.difference(_testStartTime!).inSeconds;
      
      // Create test result
      final answersMap = <String, String>{};
      for (int i = 0; i < _currentTest!.questions.length; i++) {
        final question = _currentTest!.questions[i];
        final userAnswer = _userAnswers[i];
        answersMap[question.id] = userAnswer ?? '';
      }
      
      final testResult = TestResult(
        id: '', // Will be assigned by Firebase
        userId: userId,
        testId: _currentTest!.id,
        score: score,
        totalQuestions: _currentTest!.questions.length,
        correctAnswers: correctAnswers,
        timeTaken: timeTaken,
        answers: answersMap,
        completedAt: _testEndTime!,
        isPassed: score >= 70, // Pass if score >= 70%
        startedAt: _testStartTime!,
        timeSpent: timeTaken,
        questionResults: questionResults,
      );
      
      // Save to database
      final savedResult = await _testService.saveTestResult(testResult);
      
      // Save test history
      final testHistory = TestHistory(
        id: Uuid().v4(),
        userId: userId,
        testId: _currentTest!.id,
        testTitle: _currentTest!.title,
        score: score,
        totalQuestions: _currentTest!.questions.length,
        completedAt: Timestamp.now(),
        userAnswers: answersMap,
      );
      await _testService.saveTestHistory(testHistory);
      
      // Add to local results
      _testResults.insert(0, savedResult);
      
      _clearError();
      return savedResult;
    } catch (e) {
      _setError('Failed to submit test: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Load user's test results
  Future<void> loadUserTestResults(String userId) async {
    _setLoading(true);
    try {
      _testResults = await _testService.getUserTestResults(userId);
      _clearError();
    } catch (e) {
      _setError('Failed to load test results: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load user's test history
  Future<void> loadUserTestHistory(String userId) async {
    _setLoading(true);
    try {
      _testHistory = await _testService.getUserTestHistory(userId);
      _clearError();
    } catch (e) {
      _setError('Failed to load test history: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Get test statistics
  Future<Map<String, dynamic>> getTestStatistics(String userId) async {
    try {
      return await _testService.getTestStatistics(userId);
    } catch (e) {
      _setError('Failed to load test statistics: ${e.toString()}');
      return {};
    }
  }
  
  // Reset test session
  void resetTestSession() {
    _currentTest = null;
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _currentAnswer = null;
    _testStartTime = null;
    _testEndTime = null;
    _isTestCompleted = false;
    notifyListeners();
  }
  
  // Get answered questions count
  int get answeredQuestionsCount {
    return _userAnswers.where((answer) => answer.isNotEmpty).length;
  }
  
  // Get unanswered questions count
  int get unansweredQuestionsCount {
    return _userAnswers.where((answer) => answer.isEmpty).length;
  }
  
  // Check if current question is answered
  bool get isCurrentQuestionAnswered {
    return _currentQuestionIndex < _userAnswers.length && 
           _userAnswers[_currentQuestionIndex].isNotEmpty;
  }
  
  // Check if test can be submitted
  bool get canSubmitTest {
    return _currentTest != null && 
           _userAnswers.every((answer) => answer.isNotEmpty);
  }
  
  // Get progress percentage
  double get progressPercentage {
    if (_currentTest == null) return 0.0;
    return (_currentQuestionIndex + 1) / _currentTest!.questions.length;
  }
  
  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  void clearData() {
    _tests.clear();
    _filteredTests.clear();
    _currentTest = null;
    _testResults.clear();
    _error = null;
    _isLoading = false;
    resetTestSession();
    notifyListeners();
  }
}
