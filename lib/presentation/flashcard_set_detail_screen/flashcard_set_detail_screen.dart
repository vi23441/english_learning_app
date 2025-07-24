import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../models/vocabulary.dart';
import '../../models/vocabulary_set.dart';
import '../../services/vocabulary_service.dart';
import '../../providers/auth_provider.dart';

class FlashcardSetDetailScreen extends StatefulWidget {
  final String setId;

  const FlashcardSetDetailScreen({Key? key, required this.setId}) : super(key: key);

  @override
  _FlashcardSetDetailScreenState createState() => _FlashcardSetDetailScreenState();
}

class _FlashcardSetDetailScreenState extends State<FlashcardSetDetailScreen> with SingleTickerProviderStateMixin {
  final VocabularyService _vocabularyService = VocabularyService();
  late Future<List<Vocabulary>> _vocabulariesFuture;
  List<Vocabulary> _unseenWords = [];
  Vocabulary? _currentWord;
  
  late AnimationController _controller;
  late Animation<double> _animation;

  final _wordController = TextEditingController();
  final _definitionController = TextEditingController();
  final _exampleController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isPracticeMode = false;
  String? _actualSetId; // To store the actual set ID if default is used

  @override
  void initState() {
    super.initState();
    _initializeScreen();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    _wordController.dispose();
    _definitionController.dispose();
    _exampleController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    if (widget.setId == 'default_flashcards_set_id') {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final defaultSet = await _vocabularyService.getOrCreateDefaultFlashcardSet(user.uid);
        setState(() {
          _actualSetId = defaultSet.id;
          _isPracticeMode = true; // Start directly in practice mode
        });
        _loadVocabularies();
      } else {
        // Handle case where user is not logged in but tries to access default flashcards
        setState(() {
          _actualSetId = null; // Indicate no set is loaded
        });
      }
    } else {
      setState(() {
        _actualSetId = widget.setId;
        _isPracticeMode = false; // Start in list mode for specific sets
      });
      _loadVocabularies();
    }
  }

  void _loadVocabularies() {
    if (_actualSetId != null) {
      _vocabulariesFuture = _vocabularyService.getVocabulariesForSet(_actualSetId!); // Use actualSetId
      _vocabulariesFuture.then((words) {
        setState(() {
          _unseenWords = List.from(words);
          _drawNextWord();
        });
      });
    }
  }

  void _drawNextWord() {
    setState(() {
      if (_unseenWords.isNotEmpty) {
        final randomIndex = Random().nextInt(_unseenWords.length);
        _currentWord = _unseenWords.removeAt(randomIndex);
        _controller.reset(); // Reset animation for new card
      } else {
        _currentWord = null; // No more words
      }
    });
  }

  void _flipCard() {
    if (_controller.isCompleted || _controller.isAnimating) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  Future<void> _showAddWordDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a New Word'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _wordController,
                  decoration: const InputDecoration(labelText: 'Word'),
                ),
                TextField(
                  controller: _definitionController,
                  decoration: const InputDecoration(labelText: 'Definition'),
                ),
                TextField(
                  controller: _exampleController,
                  decoration: const InputDecoration(labelText: 'Example Sentence'),
                ),
                TextField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL (Optional)'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                _addWord();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addWord() async {
    final newVocab = Vocabulary(
      id: _vocabularyService.getNewVocabId(),
      topicId: '', // Not associated with a topic
      word: _wordController.text,
      definition: _definitionController.text,
      pronunciation: '',
      phonetic: '',
      example: _exampleController.text,
      imageUrl: _imageUrlController.text,
      partOfSpeech: '',
      level: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _vocabularyService.createVocabulary(newVocab);
    if (_actualSetId != null) {
      await _vocabularyService.addWordToSet(_actualSetId!, newVocab.id);
    }
    _wordController.clear();
    _definitionController.clear();
    _exampleController.clear();
    _imageUrlController.clear();
    _loadVocabularies(); // Refresh the list of vocabularies
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_actualSetId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcard Set')),
        body: const Center(child: Text('Please log in to access your flashcards.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Set'),
        actions: [
          if (!_isPracticeMode)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                setState(() {
                  _isPracticeMode = true;
                  _loadVocabularies(); // Reload to reset practice
                });
              },
              tooltip: 'Start Practice',
            ),
          if (_isPracticeMode)
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                setState(() {
                  _isPracticeMode = false;
                });
              },
              tooltip: 'View List',
            ),
        ],
      ),
      body: _isPracticeMode ? _buildPracticeMode() : _buildListMode(authProvider.user!.uid),
      floatingActionButton: _isPracticeMode ? null : FutureBuilder<VocabularySet?>(
        future: _vocabularyService.getVocabularySetById(_actualSetId!),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Container(); // Don't show button if set isn't loaded
          }
          final set = snapshot.data!;
          if (set.createdBy == authProvider.user!.uid) {
            return FloatingActionButton(
              onPressed: _showAddWordDialog,
              child: const Icon(Icons.add),
              tooltip: 'Add New Word',
            );
          }
          return Container(); // Don't show button if it's not the user's set
        },
      ),
    );
  }

  Widget _buildPracticeMode() {
    return FutureBuilder<List<Vocabulary>>(
      future: _vocabulariesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (_currentWord == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('You have finished this set!'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _loadVocabularies(); // Restart practice
                  },
                  child: const Text('Practice Again'),
                ),
              ],
            ),
          );
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final isFront = _controller.value < 0.5;
                final rotationY = isFront ? _controller.value * pi : (_controller.value - 1) * pi;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective
                    ..rotateY(rotationY),
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: _flipCard,
                    child: Card(
                      elevation: 8,
                      child: Container(
                        width: 300,
                        height: 200,
                        alignment: Alignment.center,
                        child: isFront
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_currentWord!.imageUrl.isNotEmpty)
                                    Image.network(
                                      _currentWord!.imageUrl,
                                      height: 100,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                                    ),
                                  if (_currentWord!.imageUrl.isNotEmpty) const SizedBox(height: 10),
                                  Text(
                                    _currentWord!.word,
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentWord!.definition,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                      textAlign: TextAlign.center,
                                    ),
                                    if (_currentWord!.example.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        'Example: ${_currentWord!.example}',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _drawNextWord,
                  child: const Text('Next Word'),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Widget _buildListMode(String userId) {
    return FutureBuilder<List<Vocabulary>>(
      future: _vocabulariesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No words found in this set.'));
        }
        final vocabularies = snapshot.data!;
        return ListView.builder(
          itemCount: vocabularies.length,
          itemBuilder: (context, index) {
            final vocab = vocabularies[index];
            return ListTile(
              title: Text(vocab.word),
              subtitle: Text(vocab.definition),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  // Implement delete functionality
                  await _vocabularyService.removeWordFromSet(_actualSetId!, vocab.id);
                  _loadVocabularies(); // Refresh list
                },
              ),
            );
          },
        );
      },
    );
  }
}