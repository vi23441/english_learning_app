import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/vocabulary.dart';
import '../../models/vocabulary_set.dart';
import '../../services/vocabulary_service.dart';

class AddFlashcardScreen extends StatefulWidget {
  const AddFlashcardScreen({Key? key}) : super(key: key);

  @override
  State<AddFlashcardScreen> createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _definitionController = TextEditingController();
  final _exampleController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final VocabularyService _vocabularyService = VocabularyService();

  @override
  void dispose() {
    _wordController.dispose();
    _definitionController.dispose();
    _exampleController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _addFlashcard() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to add flashcards.')),
        );
        return;
      }

      try {
        // Get or create the user's default flashcard set
        final defaultSet = await _vocabularyService.getOrCreateDefaultFlashcardSet(user.uid);

        final newVocab = Vocabulary(
          id: _vocabularyService.getNewVocabId(),
          topicId: '', // Not associated with a specific topic, but part of a set
          word: _wordController.text.trim(),
          definition: _definitionController.text.trim(),
          pronunciation: '',
          phonetic: '',
          example: _exampleController.text.trim(),
          imageUrl: _imageUrlController.text.trim(),
          partOfSpeech: '',
          level: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _vocabularyService.createVocabulary(newVocab);
        await _vocabularyService.addWordToSet(defaultSet.id, newVocab.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flashcard added successfully!')),
        );

        // Clear fields
        _wordController.clear();
        _definitionController.clear();
        _exampleController.clear();
        _imageUrlController.clear();

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add flashcard: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Flashcard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _wordController,
                decoration: const InputDecoration(
                  labelText: 'Word',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a word';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _definitionController,
                decoration: const InputDecoration(
                  labelText: 'Definition',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a definition';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _exampleController,
                decoration: const InputDecoration(
                  labelText: 'Example Sentence (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _addFlashcard,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Add Flashcard', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
