import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart';
import './widgets/flashcard_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/session_complete_widget.dart';
import './widgets/session_controls_widget.dart';
import 'widgets/flashcard_widget.dart';
import 'widgets/progress_indicator_widget.dart';
import 'widgets/session_complete_widget.dart';
import 'widgets/session_controls_widget.dart';

class FlashcardsPracticeScreen extends StatefulWidget {
  const FlashcardsPracticeScreen({super.key});

  @override
  State<FlashcardsPracticeScreen> createState() =>
      _FlashcardsPracticeScreenState();
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

  List<Map<String, dynamic>> _flashcards = [];

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
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  void _loadFlashcards() {
    // Mock flashcards data
    _flashcards = [
      {
        'word': 'Serendipity',
        'phonetic': '/ˌserənˈdipədē/',
        'definition':
            'The occurrence and development of events by chance in a happy or beneficial way.',
        'example': 'A fortunate stroke of serendipity brought us together.',
        'difficulty': 'Advanced',
        'category': 'Vocabulary',
      },
      {
        'word': 'Ephemeral',
        'phonetic': '/əˈfem(ə)rəl/',
        'definition': 'Lasting for a very short time.',
        'example': 'The beauty of cherry blossoms is ephemeral.',
        'difficulty': 'Intermediate',
        'category': 'Vocabulary',
      },
      {
        'word': 'Ubiquitous',
        'phonetic': '/yo͞uˈbikwədəs/',
        'definition': 'Present, appearing, or found everywhere.',
        'example': 'Smartphones have become ubiquitous in modern society.',
        'difficulty': 'Advanced',
        'category': 'Vocabulary',
      },
      {
        'word': 'Mellifluous',
        'phonetic': '/məˈliflo͞oəs/',
        'definition':
            'Having a smooth, flowing sound that is pleasant to hear.',
        'example': 'Her mellifluous voice captivated the audience.',
        'difficulty': 'Advanced',
        'category': 'Vocabulary',
      },
      {
        'word': 'Pragmatic',
        'phonetic': '/praɡˈmadik/',
        'definition': 'Dealing with things sensibly and realistically.',
        'example': 'She took a pragmatic approach to solving the problem.',
        'difficulty': 'Intermediate',
        'category': 'Vocabulary',
      },
    ];
  }

  @override
  void dispose() {
    _flipController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _flipCard() {
    HapticFeedback.lightImpact();
    setState(() {
      _isFlipped = !_isFlipped;
    });

    if (_isFlipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  void _handleSwipe(bool isKnown) {
    if (_isSessionComplete) return;

    HapticFeedback.mediumImpact();

    setState(() {
      if (isKnown) {
        _knownCount++;
        _currentStreak++;
        if (_currentStreak > _bestStreak) {
          _bestStreak = _currentStreak;
        }
      } else {
        _unknownCount++;
        _currentStreak = 0;
      }
    });

    // Slide animation
    _slideController.forward().then((_) {
      if (_currentIndex < _flashcards.length - 1) {
        setState(() {
          _currentIndex++;
          _isFlipped = false;
        });
        _flipController.reset();
        _slideController.reset();
      } else {
        _completeSession();
      }
    });
  }

  void _completeSession() {
    setState(() {
      _isSessionComplete = true;
    });

    // Celebration haptic feedback
    HapticFeedback.heavyImpact();

    // Show completion animation
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SessionCompleteWidget(
          totalCards: _flashcards.length,
          knownCount: _knownCount,
          unknownCount: _unknownCount,
          bestStreak: _bestStreak,
          onContinue: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          onRestart: () {
            Navigator.pop(context);
            _restartSession();
          },
        ),
      );
    });
  }

  void _restartSession() {
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

  void _pauseSession() {
    setState(() {
      _isPaused = !_isPaused;
    });
    HapticFeedback.lightImpact();
  }

  void _playAudio() {
    HapticFeedback.lightImpact();
    // TODO: Implement audio playback
    Fluttertoast.showToast(
      msg: 'Playing pronunciation',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showHint() {
    HapticFeedback.lightImpact();
    if (!_isFlipped) {
      _flipCard();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSessionComplete) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Flashcard Practice'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: _pauseSession,
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          ProgressIndicatorWidget(
            currentIndex: _currentIndex,
            totalCards: _flashcards.length,
            knownCount: _knownCount,
            unknownCount: _unknownCount,
            currentStreak: _currentStreak,
          ),

          // Flashcard Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: _isPaused
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pause_circle_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Session Paused',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _pauseSession,
                            child: const Text('Resume'),
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: _flipCard,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FlashcardWidget(
                            flashcard: _flashcards[_currentIndex],
                            isFlipped: _isFlipped,
                            flipAnimation: _flipAnimation,
                            onSwipeRight: () => _handleSwipe(true),
                            onSwipeLeft: () => _handleSwipe(false),
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // Session Controls
          SessionControlsWidget(
            onPlayAudio: _playAudio,
            onShowHint: _showHint,
            onMarkKnown: () => _handleSwipe(true),
            onMarkUnknown: () => _handleSwipe(false),
            isFlipped: _isFlipped,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}