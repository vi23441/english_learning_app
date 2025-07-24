import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vocabulary_set.dart';
import '../../providers/auth_provider.dart';
import '../../services/vocabulary_service.dart';
import '../../routes/app_routes.dart';


class VocabularySetsScreen extends StatefulWidget {
  @override
  _VocabularySetsScreenState createState() => _VocabularySetsScreenState();
}

class _VocabularySetsScreenState extends State<VocabularySetsScreen> {
  final VocabularyService _vocabularyService = VocabularyService();
  late Future<List<VocabularySet>> _publicSetsFuture;
  late Future<List<VocabularySet>> _userSetsFuture;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _publicSetsFuture = _vocabularyService.getPublicVocabularySets();
    _userSetsFuture = _vocabularyService.getUserVocabularySets(authProvider.user!.uid);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _showCreateSetDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a New Vocabulary Set'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Set Name'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
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
              child: const Text('Create'),
              onPressed: () {
                _createSet();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _createSet() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final newSet = VocabularySet(
      id: _vocabularyService.getNewId(), // You'll need to implement this in your service
      name: _nameController.text,
      description: _descriptionController.text,
      createdBy: authProvider.user!.uid,
      vocabularyIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _vocabularyService.createVocabularySet(newSet);
    // Refresh the list of user sets
    setState(() {
      _userSetsFuture = _vocabularyService.getUserVocabularySets(authProvider.user!.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vocabulary Sets'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSetList('Public Sets', _publicSetsFuture),
            _buildSetList('My Sets', _userSetsFuture),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateSetDialog,
        child: Icon(Icons.add),
        tooltip: 'Create New Set',
      ),
    );
  }

  Widget _buildSetList(String title, Future<List<VocabularySet>> future) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        FutureBuilder<List<VocabularySet>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No sets found.'));
            }
            final sets = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: sets.length,
              itemBuilder: (context, index) {
                final set = sets[index];
                return ListTile(
                  title: Text(set.name),
                  subtitle: Text(set.description),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.flashcardSetDetailScreen,
                      arguments: set.id,
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
