import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vocabulary.dart';
import '../models/vocabulary_set.dart';

class VocabularyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _vocabCollection;
  late final CollectionReference _vocabSetsCollection;
  late final CollectionReference _topicsCollection;

  VocabularyService() : 
    _vocabCollection = FirebaseFirestore.instance.collection('vocabularies'),
    _vocabSetsCollection = FirebaseFirestore.instance.collection('vocabulary_sets'),
    _topicsCollection = FirebaseFirestore.instance.collection('vocabulary_topics');

  // Get all public vocabulary sets
  Future<List<VocabularySet>> getPublicVocabularySets() async {
    try {
      final querySnapshot = await _vocabSetsCollection.where('isPublic', isEqualTo: true).get();
      return querySnapshot.docs.map((doc) => VocabularySet.fromDocument(doc)).toList();
    } catch (e) {
      print('Error getting public vocabulary sets: $e');
      return [];
    }
  }

  // Get user-created vocabulary sets
  Future<List<VocabularySet>> getUserVocabularySets(String userId) async {
    try {
      final querySnapshot = await _vocabSetsCollection.where('createdBy', isEqualTo: userId).get();
      return querySnapshot.docs.map((doc) => VocabularySet.fromDocument(doc)).toList();
    } catch (e) {
      print('Error getting user vocabulary sets: $e');
      return [];
    }
  }

  // Get a single vocabulary set by ID
  Future<VocabularySet?> getVocabularySetById(String setId) async {
    try {
      final docSnapshot = await _vocabSetsCollection.doc(setId).get();
      if (docSnapshot.exists) {
        return VocabularySet.fromDocument(docSnapshot);
      }
      return null;
    } catch (e) {
      print('Error getting vocabulary set by ID: $e');
      return null;
    }
  }

  String getNewId() {
    return _vocabSetsCollection.doc().id;
  }

  String getNewVocabId() {
    return _vocabCollection.doc().id;
  }

  // Create a new vocabulary word
  Future<void> createVocabulary(Vocabulary newVocab) async {
    try {
      await _vocabCollection.doc(newVocab.id).set(newVocab.toMap());
    } catch (e) {
      print('Error creating vocabulary: $e');
      throw e;
    }
  }

  // Get or create a user's default flashcard set
  Future<VocabularySet> getOrCreateDefaultFlashcardSet(String userId) async {
    try {
      final querySnapshot = await _vocabSetsCollection
          .where('createdBy', isEqualTo: userId)
          .where('name', isEqualTo: 'My Flashcards')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return VocabularySet.fromDocument(querySnapshot.docs.first);
      } else {
        // Create a new default set
        final newSet = VocabularySet(
          id: _vocabSetsCollection.doc().id,
          name: 'My Flashcards',
          description: 'My personal collection of flashcards',
          createdBy: userId,
          vocabularyIds: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isPublic: false,
        );
        await createVocabularySet(newSet);
        return newSet;
      }
    } catch (e) {
      print('Error getting or creating default flashcard set: $e');
      throw e;
    }
  }

  // Get all vocabulary words for a given set
  Future<List<Vocabulary>> getVocabulariesForSet(String setId) async {
    try {
      final set = await getVocabularySetById(setId);
      if (set == null || set.vocabularyIds.isEmpty) return [];

      // Firestore 'in' queries are limited to 10 items per query.
      // We need to batch the requests if there are more than 10 words.
      List<Vocabulary> vocabularies = [];
      List<List<String>> chunks = [];
      for (var i = 0; i < set.vocabularyIds.length; i += 10) {
        chunks.add(set.vocabularyIds.sublist(i, i + 10 > set.vocabularyIds.length ? set.vocabularyIds.length : i + 10));
      }

      for (var chunk in chunks) {
        final querySnapshot = await _vocabCollection.where(FieldPath.documentId, whereIn: chunk).get();
        vocabularies.addAll(querySnapshot.docs.map((doc) => Vocabulary.fromDocument(doc)));
      }

      return vocabularies;
    } catch (e) {
      print('Error getting vocabularies for set: $e');
      return [];
    }
  }

  // Create a new vocabulary set for a user
  Future<void> createVocabularySet(VocabularySet newSet) async {
    try {
      await _vocabSetsCollection.doc(newSet.id).set(newSet.toMap());
    } catch (e) {
      print('Error creating vocabulary set: $e');
      throw e;
    }
  }

  // Add a word to a user's vocabulary set
  Future<void> addWordToSet(String setId, String vocabId) async {
    try {
      await _vocabSetsCollection.doc(setId).update({
        'vocabularyIds': FieldValue.arrayUnion([vocabId])
      });
    } catch (e) {
      print('Error adding word to set: $e');
      throw e;
    }
  }

  // Remove a word from a user's vocabulary set
  Future<void> removeWordFromSet(String setId, String vocabId) async {
    try {
      await _vocabSetsCollection.doc(setId).update({
        'vocabularyIds': FieldValue.arrayRemove([vocabId])
      });
    } catch (e) {
      print('Error removing word from set: $e');
      throw e;
    }
  }

  // Update a vocabulary word's flashcard-related fields
  Future<void> updateVocabularyFlashcardState(String vocabId, DateTime lastReviewedAt, DateTime nextReviewAt, int familiarityScore) async {
    try {
      await _vocabCollection.doc(vocabId).update({
        'lastReviewedAt': Timestamp.fromDate(lastReviewedAt),
        'nextReviewAt': Timestamp.fromDate(nextReviewAt),
        'familiarityScore': familiarityScore,
      });
    } catch (e) {
      print('Error updating vocabulary flashcard state: $e');
      throw e;
    }
  }

  // Get all topics
  Future<List<VocabularyTopic>> getAllTopics() async {
    try {
      final querySnapshot = await _topicsCollection.get();
      return querySnapshot.docs.map((doc) => VocabularyTopic.fromDocument(doc)).toList();
    } catch (e) {
      print('Error getting all topics: $e');
      return [];
    }
  }

  // Get vocabularies by topic
  Future<List<Vocabulary>> getVocabulariesByTopic(String topicId) async {
    try {
      final querySnapshot = await _vocabCollection.where('topicId', isEqualTo: topicId).get();
      return querySnapshot.docs.map((doc) => Vocabulary.fromDocument(doc)).toList();
    } catch (e) {
      print('Error getting vocabularies by topic: $e');
      return [];
    }
  }

  // Toggle bookmark
  Future<void> toggleBookmark(String vocabularyId, String userId) async {
    try {
      final docRef = _vocabCollection.doc(vocabularyId);
      final doc = await docRef.get();
      if (doc.exists) {
        final isBookmarked = doc.get('isBookmarked') ?? false;
        await docRef.update({'isBookmarked': !isBookmarked});
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
      throw e;
    }
  }

  // Get bookmarked vocabularies
  Future<List<Vocabulary>> getBookmarkedVocabularies(String userId) async {
    try {
      final querySnapshot = await _vocabCollection.where('isBookmarked', isEqualTo: true).get();
      return querySnapshot.docs.map((doc) => Vocabulary.fromDocument(doc)).toList();
    } catch (e) {
      print('Error getting bookmarked vocabularies: $e');
      return [];
    }
  }

  // Save practice session
  Future<void> savePracticeSession(String userId, String topicId, int knownWords, int unknownWords, int streak, double accuracy) async {
    try {
      // Implementation for saving practice session
    } catch (e) {
      print('Error saving practice session: $e');
      throw e;
    }
  }
}
