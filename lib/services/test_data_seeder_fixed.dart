import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/test.dart';

class TestDataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedTestData() async {
    try {
      // Check if tests already exist
      final existingTests = await _firestore.collection('tests').limit(1).get();
      if (existingTests.docs.isNotEmpty) {
        print('Test data already exists, skipping seed');
        return;
      }

      // Create sample tests
      await _createSampleTests();
      print('Test data seeded successfully');
    } catch (e) {
      print('Error seeding test data: $e');
    }
  }

  Future<void> _createSampleTests() async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    // Sample Test 1: Basic English Grammar
    final test1 = Test(
      id: 'test_grammar_basic_001',
      title: 'Basic English Grammar',
      description: 'Test your understanding of basic English grammar rules including tenses, articles, and sentence structure.',
      level: 'Beginner',
      skill: 'Grammar',
      category: TestCategory.grammar,
      difficulty: TestDifficulty.beginner,
      questionIds: [],
      questions: [
        TestQuestion(
          id: 'q1_grammar_001',
          testId: 'test_grammar_basic_001',
          question: 'Which sentence is grammatically correct?',
          questionType: 'multiple_choice',
          options: [
            'She don\'t like apples.',
            'She doesn\'t like apples.',
            'She doesn\'t likes apples.',
            'She don\'t likes apples.'
          ],
          correctAnswer: '1',
          explanation: 'The correct form is "doesn\'t" (does not) with the base form of the verb.',
          points: 1,
          imageUrl: '',
          audioUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
        TestQuestion(
          id: 'q2_grammar_002',
          testId: 'test_grammar_basic_001',
          question: 'Complete the sentence: "I _____ to school every day."',
          questionType: 'multiple_choice',
          options: [
            'go',
            'goes',
            'going',
            'gone'
          ],
          correctAnswer: '0',
          explanation: 'With "I", we use the base form of the verb "go".',
          points: 1,
          imageUrl: '',
          audioUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
        TestQuestion(
          id: 'q3_grammar_003',
          testId: 'test_grammar_basic_001',
          question: 'Fill in the blank: "There _____ many books on the table."',
          questionType: 'fill_blank',
          options: [],
          correctAnswer: 'are',
          explanation: 'Use "are" with plural nouns like "books".',
          points: 1,
          imageUrl: '',
          audioUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
        TestQuestion(
          id: 'q4_grammar_004',
          testId: 'test_grammar_basic_001',
          question: 'Is this sentence correct? "He can plays the piano."',
          questionType: 'true_false',
          options: ['True', 'False'],
          correctAnswer: 'false',
          explanation: 'After modal verbs like "can", use the base form: "He can play the piano."',
          points: 1,
          imageUrl: '',
          audioUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
        TestQuestion(
          id: 'q5_grammar_005',
          testId: 'test_grammar_basic_001',
          question: 'Choose the correct article: "I saw _____ elephant at the zoo."',
          questionType: 'multiple_choice',
          options: [
            'a',
            'an',
            'the',
            'no article'
          ],
          correctAnswer: '1',
          explanation: 'Use "an" before vowel sounds. "Elephant" starts with a vowel sound.',
          points: 1,
          imageUrl: '',
          audioUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      timeLimit: 15,
      duration: 15,
      passingScore: 70,
      createdBy: 'system',
      createdAt: now,
      updatedAt: now,
      isActive: true,
      isShuffled: false,
    );

    // Sample Test 2: Vocabulary Building
    final test2 = Test(
      id: 'test_vocabulary_001',
      title: 'Essential English Vocabulary',
      description: 'Expand your English vocabulary with common words and their meanings.',
      level: 'Intermediate',
      skill: 'Vocabulary',
      category: TestCategory.vocabulary,
      difficulty: TestDifficulty.intermediate,
      questionIds: [],
      questions: [
        TestQuestion(
          id: 'q1_vocab_001',
          testId: 'test_vocabulary_001',
          question: 'What does "abundant" mean?',
          questionType: 'multiple_choice',
          options: [
            'Scarce',
            'Plentiful',
            'Expensive',
            'Difficult'
          ],
          correctAnswer: '1',
          explanation: 'Abundant means existing in large quantities; plentiful.',
          points: 1,
          imageUrl: '',
          audioUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
        TestQuestion(
          id: 'q2_vocab_002',
          testId: 'test_vocabulary_001',
          question: 'Choose the synonym for "meticulous":',
          questionType: 'multiple_choice',
          options: [
            'Careless',
            'Quick',
            'Careful',
            'Lazy'
          ],
          correctAnswer: '2',
          explanation: 'Meticulous means showing great attention to detail; very careful.',
          points: 1,
          imageUrl: '',
          audioUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
        TestQuestion(
          id: 'q3_vocab_003',
          testId: 'test_vocabulary_001',
          question: 'Fill in the blank: "The evidence was _____ and proved his innocence."',
          questionType: 'fill_blank',
          options: [],
          correctAnswer: 'conclusive',
          explanation: 'Conclusive evidence is decisive and convincing.',
          points: 1,
          imageUrl: '',
          audioUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
        TestQuestion(
          id: 'q4_vocab_004',
          testId: 'test_vocabulary_001',
          question: '"Benevolent" means kind and generous.',
          questionType: 'true_false',
          options: ['True', 'False'],
          correctAnswer: 'true',
          explanation: 'Benevolent means well-meaning and kindly.',
          points: 1,
          imageUrl: '',
          audioUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      timeLimit: 10,
      duration: 10,
      passingScore: 75,
      createdBy: 'system',
      createdAt: now,
      updatedAt: now,
      isActive: true,
      isShuffled: false,
    );

    // Sample Test 3: Reading Comprehension
    final test3 = Test(
      id: 'test_reading_001',
      title: 'Reading Comprehension - Short Passage',
      description: 'Test your reading comprehension skills with a short passage and questions.',
      level: 'Intermediate',
      skill: 'Reading',
      category: TestCategory.reading,
      difficulty: TestDifficulty.intermediate,
      questionIds: [],
      questions: [
        TestQuestion(
          id: 'q1_reading_001',
          testId: 'test_reading_001',
          question: 'Read the passage below and answer the questions:\n\n"The benefits of regular exercise extend far beyond physical fitness. Studies have shown that people who exercise regularly experience improved mental health, better sleep quality, and increased energy levels. Exercise releases endorphins, which are natural mood elevators that help reduce stress and anxiety. Additionally, regular physical activity can improve cognitive function and memory."\n\nWhat is the main idea of this passage?',
          questionType: 'multiple_choice',
          options: [
            'Exercise only improves physical fitness',
            'Exercise has multiple benefits beyond physical fitness',
            'Exercise is difficult to maintain',
            'Exercise is only good for mental health'
          ],
          correctAnswer: '1',
          explanation: 'The passage discusses various benefits of exercise, not just physical fitness.',
          points: 2,
          imageUrl: '',
          audioUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
        TestQuestion(
          id: 'q2_reading_002',
          testId: 'test_reading_001',
          question: 'According to the passage, what are endorphins?',
          questionType: 'multiple_choice',
          options: [
            'Harmful chemicals',
            'Natural mood elevators',
            'Sleep medications',
            'Exercise equipment'
          ],
          correctAnswer: '1',
          explanation: 'The passage states that endorphins are natural mood elevators.',
          points: 1,
          imageUrl: '',
          audioUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
        TestQuestion(
          id: 'q3_reading_003',
          testId: 'test_reading_001',
          question: 'Exercise can improve cognitive function and memory.',
          questionType: 'true_false',
          options: ['True', 'False'],
          correctAnswer: 'true',
          explanation: 'The passage explicitly mentions that exercise can improve cognitive function and memory.',
          points: 1,
          imageUrl: '',
          audioUrl: '',
          createdAt: now,
          updatedAt: now,
        ),
      ],
      timeLimit: 20,
      duration: 20,
      passingScore: 70,
      createdBy: 'system',
      createdAt: now,
      updatedAt: now,
      isActive: true,
      isShuffled: false,
    );

    // Add tests to Firestore
    final test1Ref = _firestore.collection('tests').doc(test1.id);
    final test2Ref = _firestore.collection('tests').doc(test2.id);
    final test3Ref = _firestore.collection('tests').doc(test3.id);

    batch.set(test1Ref, test1.toMap());
    batch.set(test2Ref, test2.toMap());
    batch.set(test3Ref, test3.toMap());

    await batch.commit();
  }

  Future<void> clearTestData() async {
    try {
      final tests = await _firestore.collection('tests').get();
      final batch = _firestore.batch();
      
      for (final doc in tests.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('Test data cleared successfully');
    } catch (e) {
      print('Error clearing test data: $e');
    }
  }
}
