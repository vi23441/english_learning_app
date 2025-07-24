import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../providers/test_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/test.dart';
import './widgets/test_navigation_widget.dart';
import './widgets/test_progress_widget.dart';
import './widgets/test_question_widget.dart';
import './widgets/test_timer_widget.dart';

class TestTakingScreen extends StatefulWidget {
  const TestTakingScreen({Key? key}) : super(key: key);

  @override
  State<TestTakingScreen> createState() => _TestTakingScreenState();
}

class _TestTakingScreenState extends State<TestTakingScreen> {
  String? testId;
  late TestProvider testProvider;
  late AuthProvider authProvider;
  late AudioPlayer _audioPlayer;
  
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTest();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get testId from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      testId = args;
    }
    
    // Initialize providers
    testProvider = Provider.of<TestProvider>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  Future<void> _initializeTest() async {
    if (testId != null) {
      // Always start the test to ensure it's reset for a new attempt
      await testProvider.startTest(testId!);
    }
  }

  void _autoSubmitTest() {
    _showSubmissionDialog(isAutoSubmit: true);
  }

  void _showSubmissionDialog({bool isAutoSubmit = false}) {
    showDialog(
      context: context,
      barrierDismissible: !isAutoSubmit,
      builder: (context) => AlertDialog(
        title: Text(
          isAutoSubmit ? 'Time Up!' : 'Submit Test',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          isAutoSubmit
              ? 'Time has expired. Your test will be submitted automatically.'
              : 'Are you sure you want to submit your test? You cannot change your answers after submission.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          if (!isAutoSubmit)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submitTest();
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTest() async {
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    try {
      final result = await testProvider.submitTest(authProvider.user!.id);
      
      if (result != null) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.testResultsScreen,
          arguments: {
            'testResult': result,
            'test': testProvider.currentTest,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit test. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting test: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TestProvider>(
      builder: (context, testProvider, child) {
        // Show loading if test is not loaded
        if (testProvider.isLoading || testProvider.currentTest == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Loading Test...',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading test questions...'),
                ],
              ),
            ),
          );
        }

        // Show error if failed to load
        if (testProvider.error != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load test',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    testProvider.error!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final test = testProvider.currentTest!;
        final currentQuestion = testProvider.currentQuestion;
        final currentQuestionIndex = testProvider.currentQuestionIndex;
        final totalQuestions = testProvider.totalQuestions;

        // Calculate remaining time (assuming test duration is in minutes)
        final testDuration = test.duration; // Duration in minutes
        final elapsed = testProvider.timeElapsed;
        final remainingMinutes = (testDuration - elapsed.inMinutes).clamp(0, testDuration);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              test.title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              TestTimerWidget(
                remainingMinutes: remainingMinutes,
                onTimeUp: _autoSubmitTest,
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  // Progress indicator
                  Container(
                    padding: EdgeInsets.all(16),
                    child: TestProgressWidget(
                      currentQuestion: currentQuestionIndex + 1,
                      totalQuestions: totalQuestions,
                      completedQuestions: testProvider.answeredQuestionsCount,
                      flaggedQuestions: 0, // TODO: Implement flagged questions
                    ),
                  ),

                  // Question content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: currentQuestion != null
                          ? _buildQuestionWidget(currentQuestion, currentQuestionIndex + 1)
                          : Center(child: Text('No questions available')),
                    ),
                  ),

                  // Navigation controls
                  Container(
                    padding: EdgeInsets.all(16),
                    child: TestNavigationWidget(
                      currentIndex: currentQuestionIndex,
                      totalQuestions: totalQuestions,
                      onPrevious: currentQuestionIndex > 0
                          ? () => testProvider.previousQuestion()
                          : null,
                      onNext: currentQuestionIndex < totalQuestions - 1
                          ? () => testProvider.nextQuestion()
                          : null,
                      onSubmit: _showSubmissionDialog,
                      isLastQuestion: currentQuestionIndex == totalQuestions - 1,
                    ),
                  ),
                ],
              ),

              // Question overview overlay (TODO: Implement)
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // TODO: Implement question overview
            },
            tooltip: 'Question Overview',
            child: Icon(Icons.grid_view),
          ),
        );
      },
    );
  }

  Widget _buildQuestionWidget(TestQuestion question, int questionNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question $questionNumber',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            // TODO: Add flag button
          ],
        ),
        const SizedBox(height: 12),

        // Question text
        Text(
          question.question,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Question image (if available)
        if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                question.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Theme.of(context).colorScheme.surface,
                  child: const Center(
                    child: Icon(Icons.error_outline),
                  ),
                ),
              ),
            ),
          ),

        // Question content based on type
        _buildQuestionContent(question),

        // Audio player (if available)
        if (question.audioUrl.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Icon(
                  Icons.volume_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Audio available',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _playAudio(question.audioUrl);
                  },
                  child: Text('Play'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _playAudio(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }

  Widget _buildQuestionContent(TestQuestion question) {
    switch (question.questionType) {
      case 'multiple_choice':
      case '': // Handle empty question type as multiple choice
        return _buildMultipleChoiceOptions(question);
      case 'fill_blank':
      case 'fill_in_blank':
        return _buildFillInBlankInput(question);
      case 'true_false':
        return _buildTrueFalseOptions(question);
      case 'matching':
        return _buildMatchingOptions(question);
      case 'essay':
        return _buildEssayInput(question);
      default:
        return Container();
    }
  }

  Widget _buildMultipleChoiceOptions(TestQuestion question) {
    final userAnswer = testProvider.userAnswers.length > testProvider.currentQuestionIndex
        ? testProvider.userAnswers[testProvider.currentQuestionIndex]
        : null;
    final bool isAnswered = userAnswer != null && userAnswer.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...question.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          
          final isSelected = userAnswer == index.toString();
          final isCorrect = question.correctAnswer == index.toString();

          Color borderColor = Theme.of(context).colorScheme.outline;
          Color backgroundColor = Theme.of(context).colorScheme.surface;
          IconData? trailingIcon;

          if (isAnswered) {
            if (isCorrect) {
              borderColor = Colors.green;
              backgroundColor = Colors.green.withOpacity(0.1);
              trailingIcon = Icons.check_circle;
            } else if (isSelected) {
              borderColor = Colors.red;
              backgroundColor = Colors.red.withOpacity(0.1);
              trailingIcon = Icons.cancel;
            }
          } else if (isSelected) {
            borderColor = Theme.of(context).colorScheme.primary;
            backgroundColor = Theme.of(context).colorScheme.primaryContainer;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: isAnswered ? null : () => testProvider.answerQuestion(index.toString()),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(color: borderColor, width: isSelected || (isAnswered && isCorrect) ? 2 : 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isAnswered && (isCorrect || isSelected)
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 12),
                      Icon(trailingIcon, color: isCorrect ? Colors.green : Colors.red),
                    ]
                  ],
                ),
              ),
            ),
          );
        }).toList(),

        if (isAnswered && question.explanation.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explanation:',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  question.explanation,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFillInBlankInput(TestQuestion question) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Enter your answer...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: (value) => testProvider.answerQuestion(value),
      initialValue: testProvider.userAnswers.length > testProvider.currentQuestionIndex
          ? testProvider.userAnswers[testProvider.currentQuestionIndex]
          : '',
    );
  }

  Widget _buildTrueFalseOptions(TestQuestion question) {
    return Column(
      children: [
        _buildTrueFalseOption('True', true),
        const SizedBox(height: 8),
        _buildTrueFalseOption('False', false),
      ],
    );
  }

  Widget _buildTrueFalseOption(String label, bool value) {
    final isSelected = testProvider.userAnswers.length > testProvider.currentQuestionIndex &&
        testProvider.userAnswers[testProvider.currentQuestionIndex] == value.toString();

    return InkWell(
      onTap: () => testProvider.answerQuestion(value.toString()),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchingOptions(TestQuestion question) {
    // TODO: Implement matching question type
    return Text('Matching questions not yet implemented');
  }

  Widget _buildEssayInput(TestQuestion question) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Write your essay here...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      maxLines: 8,
      onChanged: (value) => testProvider.answerQuestion(value),
      initialValue: testProvider.userAnswers.length > testProvider.currentQuestionIndex
          ? testProvider.userAnswers[testProvider.currentQuestionIndex]
          : '',
    );
  }
}
