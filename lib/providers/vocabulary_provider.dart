import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../services/vocabulary_service.dart';

class VocabularyProvider with ChangeNotifier {
  final VocabularyService _vocabularyService = VocabularyService();
  
  List<VocabularyTopic> _topics = [];
  List<Vocabulary> _vocabularies = [];
  List<Vocabulary> _filteredVocabularies = [];
  VocabularyTopic? _currentTopic;
  bool _isLoading = false;
  String? _error;
  
  // Flashcard practice state
  int _currentFlashcardIndex = 0;
  bool _isFlashcardFlipped = false;
  List<String> _practicedWords = [];
  int _correctAnswers = 0;
  int _totalAnswers = 0;
  
  // Getters
  List<VocabularyTopic> get topics => _topics;
  List<Vocabulary> get vocabularies => _vocabularies;
  List<Vocabulary> get filteredVocabularies => _filteredVocabularies;
  VocabularyTopic? get currentTopic => _currentTopic;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Flashcard getters
  int get currentFlashcardIndex => _currentFlashcardIndex;
  bool get isFlashcardFlipped => _isFlashcardFlipped;
  List<String> get practicedWords => _practicedWords;
  int get correctAnswers => _correctAnswers;
  int get totalAnswers => _totalAnswers;
  double get accuracy => _totalAnswers > 0 ? _correctAnswers / _totalAnswers : 0.0;
  
  Vocabulary? get currentFlashcard => 
    _filteredVocabularies.isNotEmpty && _currentFlashcardIndex < _filteredVocabularies.length
      ? _filteredVocabularies[_currentFlashcardIndex]
      : null;
  
  // Load all topics
  Future<void> loadTopics() async {
    _setLoading(true);
    try {
      _topics = await _vocabularyService.getAllTopics();
      _clearError();
    } catch (e) {
      _setError('Failed to load topics: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Load vocabularies for a specific topic
  Future<void> loadVocabulariesByTopic(String topicId) async {
    _setLoading(true);
    try {
      _vocabularies = await _vocabularyService.getVocabulariesByTopic(topicId);
      _filteredVocabularies = List.from(_vocabularies);
      _currentTopic = _topics.firstWhere(
        (topic) => topic.id == topicId,
        orElse: () => VocabularyTopic(
          id: topicId,
          name: 'Unknown Topic',
          title: 'Unknown Topic',
          description: '',
          level: 'beginner',
          totalWords: 0,
          imageUrl: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      _clearError();
    } catch (e) {
      _setError('Failed to load vocabularies: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Search vocabularies
  void searchVocabularies(String query) {
    if (query.isEmpty) {
      _filteredVocabularies = List.from(_vocabularies);
    } else {
      _filteredVocabularies = _vocabularies.where((vocab) =>
        vocab.word.toLowerCase().contains(query.toLowerCase()) ||
        vocab.definition.toLowerCase().contains(query.toLowerCase()) ||
        vocab.example.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }
  
  // Filter vocabularies by level
  void filterByLevel(VocabularyLevel? level) {
    if (level == null) {
      _filteredVocabularies = List.from(_vocabularies);
    } else {
      _filteredVocabularies = _vocabularies.where((vocab) =>
        vocab.level == level
      ).toList();
    }
    notifyListeners();
  }
  
  // Flashcard methods
  void startFlashcardPractice() {
    _currentFlashcardIndex = 0;
    _isFlashcardFlipped = false;
    _practicedWords.clear();
    _correctAnswers = 0;
    _totalAnswers = 0;
    
    // Shuffle vocabularies for practice
    _filteredVocabularies.shuffle();
    notifyListeners();
  }
  
  void flipFlashcard() {
    _isFlashcardFlipped = !_isFlashcardFlipped;
    notifyListeners();
  }
  
  void nextFlashcard() {
    if (_currentFlashcardIndex < _filteredVocabularies.length - 1) {
      _currentFlashcardIndex++;
      _isFlashcardFlipped = false;
      notifyListeners();
    }
  }
  
  void previousFlashcard() {
    if (_currentFlashcardIndex > 0) {
      _currentFlashcardIndex--;
      _isFlashcardFlipped = false;
      notifyListeners();
    }
  }
  
  void markAnswer(bool isCorrect) {
    if (currentFlashcard != null) {
      _practicedWords.add(currentFlashcard!.word);
      _totalAnswers++;
      if (isCorrect) {
        _correctAnswers++;
      }
      notifyListeners();
    }
  }
  
  void resetFlashcardProgress() {
    _currentFlashcardIndex = 0;
    _isFlashcardFlipped = false;
    _practicedWords.clear();
    _correctAnswers = 0;
    _totalAnswers = 0;
    notifyListeners();
  }
  
  // Quiz methods
  List<Map<String, dynamic>> generateQuizQuestions(int count) {
    if (_filteredVocabularies.length < count) {
      count = _filteredVocabularies.length;
    }
    
    final shuffled = List.from(_filteredVocabularies)..shuffle();
    final questions = <Map<String, dynamic>>[];
    
    for (int i = 0; i < count; i++) {
      final correct = shuffled[i];
      final options = <String>[correct.definition];
      
      // Add 3 random wrong options
      final wrongOptions = _filteredVocabularies
          .where((v) => v.id != correct.id)
          .map((v) => v.definition)
          .toList()
        ..shuffle();
      
      options.addAll(wrongOptions.take(3));
      options.shuffle();
      
      questions.add({
        'question': 'What is the meaning of "${correct.word}"?',
        'options': options,
        'correctAnswer': correct.definition,
        'vocabulary': correct,
      });
    }
    
    return questions;
  }
  
  // Bookmark methods
  Future<void> toggleBookmark(String vocabularyId, String userId) async {
    try {
      await _vocabularyService.toggleBookmark(vocabularyId, userId);
      
      // Update local state
      final index = _vocabularies.indexWhere((v) => v.id == vocabularyId);
      if (index != -1) {
        _vocabularies[index] = _vocabularies[index].copyWith(
          isBookmarked: !_vocabularies[index].isBookmarked,
        );
        
        // Update filtered list too
        final filteredIndex = _filteredVocabularies.indexWhere((v) => v.id == vocabularyId);
        if (filteredIndex != -1) {
          _filteredVocabularies[filteredIndex] = _filteredVocabularies[filteredIndex].copyWith(
            isBookmarked: !_filteredVocabularies[filteredIndex].isBookmarked,
          );
        }
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to update bookmark: ${e.toString()}');
    }
  }
  
  // Load bookmarked vocabularies
  Future<void> loadBookmarkedVocabularies(String userId) async {
    _setLoading(true);
    try {
      _vocabularies = await _vocabularyService.getBookmarkedVocabularies(userId);
      _filteredVocabularies = List.from(_vocabularies);
      _clearError();
    } catch (e) {
      _setError('Failed to load bookmarked vocabularies: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Practice statistics
  Future<void> savePracticeSession(String userId, String topicId, {
    required int totalWords,
    required int correctAnswers,
    required int timeSpent,
  }) async {
    try {
      final unknownWords = totalWords - correctAnswers;
      final accuracy = totalWords > 0 ? correctAnswers / totalWords : 0.0;
      
      await _vocabularyService.savePracticeSession(
        userId,
        topicId,
        correctAnswers, // knownWords
        unknownWords, // unknownWords
        correctAnswers, // streak
        accuracy, // accuracy
      );
    } catch (e) {
      _setError('Failed to save practice session: ${e.toString()}');
    }
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
    _topics.clear();
    _vocabularies.clear();
    _filteredVocabularies.clear();
    _currentTopic = null;
    _error = null;
    _isLoading = false;
    resetFlashcardProgress();
    notifyListeners();
  }
}
