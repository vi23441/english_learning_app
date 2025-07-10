import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/recent_searches_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/search_suggestions_widget.dart';
import './widgets/word_card_widget.dart';
import 'widgets/recent_searches_widget.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/search_suggestions_widget.dart';
import 'widgets/word_card_widget.dart';

class VocabularyLookupScreen extends StatefulWidget {
  const VocabularyLookupScreen({super.key});

  @override
  State<VocabularyLookupScreen> createState() => _VocabularyLookupScreenState();
}

class _VocabularyLookupScreenState extends State<VocabularyLookupScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearching = false;
  bool _isLoading = false;
  String _searchQuery = '';
  List<String> _searchSuggestions = [];
  List<String> _recentSearches = [];
  Map<String, dynamic>? _currentWord;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _isSearching = _searchQuery.isNotEmpty;
    });

    if (_searchQuery.isNotEmpty) {
      _generateSuggestions();
    } else {
      setState(() {
        _searchSuggestions.clear();
        _currentWord = null;
      });
    }
  }

  void _generateSuggestions() {
    // Mock suggestions based on search query
    final suggestions = [
      '${_searchQuery}able',
      '${_searchQuery}tion',
      '${_searchQuery}ment',
      '${_searchQuery}ing',
      '${_searchQuery}ed',
    ].where((suggestion) => suggestion.length > _searchQuery.length).toList();

    setState(() {
      _searchSuggestions = suggestions.take(5).toList();
    });
  }

  void _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList('recent_searches') ?? [];
    setState(() {
      _recentSearches = recent.take(10).toList();
    });
  }

  void _saveRecentSearch(String word) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recent = prefs.getStringList('recent_searches') ?? [];
    recent.remove(word);
    recent.insert(0, word);
    recent = recent.take(10).toList();
    await prefs.setStringList('recent_searches', recent);
    setState(() {
      _recentSearches = recent;
    });
  }

  void _performSearch(String word) async {
    if (word.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    // Mock word data
    await Future.delayed(const Duration(milliseconds: 800));

    final mockWordData = {
      'word': word.toLowerCase(),
      'phonetic': _getPhonetic(word),
      'definitions': _getDefinitions(word),
      'examples': _getExamples(word),
      'difficulty': _getDifficultyLevel(word),
      'etymology': _getEtymology(word),
      'relatedWords': _getRelatedWords(word),
      'audioUrl':
          'https://ssl.gstatic.com/dictionary/static/sounds/20200429/${word.toLowerCase()}-en.mp3',
    };

    setState(() {
      _currentWord = mockWordData;
      _isLoading = false;
    });

    _saveRecentSearch(word);
    _searchController.text = word;
    _searchFocusNode.unfocus();
  }

  String _getPhonetic(String word) {
    // Mock phonetic transcription
    final phonetics = {
      'hello': '/həˈloʊ/',
      'world': '/wɜːrld/',
      'flutter': '/ˈflʌtər/',
      'learn': '/lɜːrn/',
      'vocabulary': '/voʊˈkæbjʊˌleri/',
    };
    return phonetics[word.toLowerCase()] ?? '/wɜːrd/';
  }

  List<Map<String, String>> _getDefinitions(String word) {
    return [
      {
        'partOfSpeech': 'noun',
        'definition':
            'A ${word.toLowerCase()} is a word or phrase that has a specific meaning.',
        'example': 'The ${word.toLowerCase()} was difficult to understand.',
      },
      {
        'partOfSpeech': 'verb',
        'definition':
            'To ${word.toLowerCase()} means to perform an action related to this word.',
        'example': 'I ${word.toLowerCase()} every day to improve my skills.',
      },
    ];
  }

  List<String> _getExamples(String word) {
    return [
      'The ${word.toLowerCase()} appears frequently in academic texts.',
      'Students often struggle with the pronunciation of ${word.toLowerCase()}.',
      'Understanding ${word.toLowerCase()} is crucial for language learners.',
    ];
  }

  String _getDifficultyLevel(String word) {
    final levels = ['Beginner', 'Intermediate', 'Advanced'];
    return levels[word.length % 3];
  }

  String _getEtymology(String word) {
    return 'The word "${word.toLowerCase()}" comes from Middle English, derived from Old French and Latin roots.';
  }

  List<String> _getRelatedWords(String word) {
    return [
      '${word.toLowerCase()}able',
      '${word.toLowerCase()}tion',
      '${word.toLowerCase()}ment',
      '${word.toLowerCase()}ing',
      '${word.toLowerCase()}ed',
    ];
  }

  void _addToVocabularyList() {
    if (_currentWord != null) {
      HapticFeedback.mediumImpact();
      Fluttertoast.showToast(
        msg: 'Added "${_currentWord!['word']}" to vocabulary list',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _createFlashcard() {
    if (_currentWord != null) {
      HapticFeedback.mediumImpact();
      Navigator.pushNamed(
        context,
        AppRoutes.flashcardsPracticeScreen,
        arguments: _currentWord,
      );
    }
  }

  void _shareDefinition() {
    if (_currentWord != null) {
      HapticFeedback.lightImpact();
      final shareText = '''
${_currentWord!['word']} ${_currentWord!['phonetic']}

${_currentWord!['definitions'][0]['definition']}

Example: ${_currentWord!['definitions'][0]['example']}
      ''';

      // In a real app, you would use share_plus package
      Fluttertoast.showToast(
        msg: 'Definition shared',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _toggleOfflineMode() {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: 'Offline mode toggled',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary Lookup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implement camera scan functionality
              Fluttertoast.showToast(
                msg: 'Camera scan feature',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.wifi_off_outlined),
            onPressed: _toggleOfflineMode,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SearchBarWidget(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onSearch: _performSearch,
              onVoiceSearch: () {
                HapticFeedback.lightImpact();
                // TODO: Implement voice search
                Fluttertoast.showToast(
                  msg: 'Voice search feature',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
            ),
          ),

          // Content Area
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _currentWord != null
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: WordCardWidget(
                          wordData: _currentWord!,
                          onAddToVocabulary: _addToVocabularyList,
                          onCreateFlashcard: _createFlashcard,
                          onShare: _shareDefinition,
                        ),
                      )
                    : _isSearching && _searchSuggestions.isNotEmpty
                        ? SearchSuggestionsWidget(
                            suggestions: _searchSuggestions,
                            onSuggestionTap: _performSearch,
                          )
                        : RecentSearchesWidget(
                            recentSearches: _recentSearches,
                            onRecentSearchTap: _performSearch,
                            onClearRecent: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.remove('recent_searches');
                              setState(() {
                                _recentSearches.clear();
                              });
                            },
                          ),
          ),
        ],
      ),
    );
  }
}