import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/vocabulary_provider.dart';
import '../../models/vocabulary.dart';

class FlashcardsPracticeScreen extends StatefulWidget {
  const FlashcardsPracticeScreen({super.key});

  @override
  State<FlashcardsPracticeScreen> createState() => _FlashcardsPracticeScreenState();
}

class _FlashcardsPracticeScreenState extends State<FlashcardsPracticeScreen>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _slideController;
  late Animation<double> _flipAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isSessionComplete = false;
  bool _isPaused = false;
  
  int _knownCount = 0;
  int _unknownCount = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  
  List<Vocabulary> _flashcards = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadFlashcards();
  }

  void _initializeAnimations() {
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));
  }

  void _loadFlashcards() {
    final vocabularyProvider = Provider.of<VocabularyProvider>(context, listen: false);
    setState(() {
      _flashcards = vocabularyProvider.vocabularies;
      if (_flashcards.isEmpty) {
        _isSessionComplete = true;
      }
    });
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
    
    if (_isFlipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  void _markAsKnown() {
    setState(() {
      _knownCount++;
      _currentStreak++;
      if (_currentStreak > _bestStreak) {
        _bestStreak = _currentStreak;
      }
    });
    _nextCard();
  }

  void _markAsUnknown() {
    setState(() {
      _unknownCount++;
      _currentStreak = 0;
    });
    _nextCard();
  }

  void _nextCard() {
    if (_currentIndex < _flashcards.length - 1) {
      _slideController.forward().then((_) {
        setState(() {
          _currentIndex++;
          _isFlipped = false;
        });
        _flipController.reset();
        _slideController.reset();
      });
    } else {
      _completeSession();
    }
  }

  void _completeSession() {
    setState(() {
      _isSessionComplete = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total cards: \${_flashcards.length}'),
            Text('Known: $_knownCount'),
            Text('Unknown: $_unknownCount'),
            Text('Best streak: $_bestStreak'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _restartSession,
            child: const Text('Restart'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  void _restartSession() {
    Navigator.pop(context); // Close dialog
    setState(() {
      _currentIndex = 0;
      _isFlipped = false;
      _isSessionComplete = false;
      _knownCount = 0;
      _unknownCount = 0;
      _currentStreak = 0;
    });
    _flipController.reset();
    _slideController.reset();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Flashcard Practice'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.style, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No flashcards available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Please add some vocabulary first',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Practice'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _togglePause,
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
          ),
        ],
      ),
      body: _isSessionComplete
          ? _buildCompletionScreen()
          : _buildPracticeScreen(),
    );
  }

  Widget _buildPracticeScreen() {
    return Column(
      children: [
        // Progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Card \${_currentIndex + 1} of \${_flashcards.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _flashcards.length,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Known: $_knownCount', style: const TextStyle(color: Colors.green)),
                  Text('Unknown: $_unknownCount', style: const TextStyle(color: Colors.red)),
                  Text('Streak: $_currentStreak', style: const TextStyle(color: Colors.blue)),
                ],
              ),
            ],
          ),
        ),

        // Flashcard
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: _slideAnimation,
                    child: _buildFlashCard(),
                  );
                },
              ),
            ),
          ),
        ),

        // Control buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _markAsUnknown,
                icon: const Icon(Icons.close),
                label: const Text('Unknown'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _flipCard,
                icon: Icon(_isFlipped ? Icons.visibility_off : Icons.visibility),
                label: Text(_isFlipped ? 'Hide' : 'Show'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _markAsKnown,
                icon: const Icon(Icons.check),
                label: const Text('Known'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlashCard() {
    final vocabulary = _flashcards[_currentIndex];
    
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: 300,
      child: Card(
        elevation: 8,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isFlipped
              ? _buildCardBack(vocabulary)
              : _buildCardFront(vocabulary),
        ),
      ),
    );
  }

  Widget _buildCardFront(Vocabulary vocabulary) {
    return Container(
      key: const ValueKey('front'),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz, size: 48, color: Colors.blue),
          const SizedBox(height: 20),
          Text(
            vocabulary.word,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            vocabulary.pronunciation,
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'Tap to see definition',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(Vocabulary vocabulary) {
    return Container(
      key: const ValueKey('back'),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lightbulb, size: 48, color: Colors.orange),
          const SizedBox(height: 20),
          Text(
            vocabulary.definition,
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (vocabulary.example.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Example:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              vocabulary.example,
              style: const TextStyle(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Session Complete!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Total cards: \${_flashcards.length}'),
                    Text('Known: $_knownCount'),
                    Text('Unknown: $_unknownCount'),
                    Text('Best streak: $_bestStreak'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _restartSession,
                  child: const Text('Practice Again'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
