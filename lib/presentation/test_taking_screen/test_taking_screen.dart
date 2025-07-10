import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
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
  int currentQuestionIndex = 0;
  int totalQuestions = 20;
  int remainingTimeInMinutes = 30;
  Map<int, dynamic> userAnswers = {};
  Set<int> flaggedQuestions = {};
  bool showQuestionOverview = false;

  final List<Map<String, dynamic>> testQuestions = [
    {
      'id': 1,
      'type': 'multiple_choice',
      'question': 'What is the capital of France?',
      'options': ['London', 'Berlin', 'Paris', 'Madrid'],
      'correctAnswer': 2,
      'imageUrl': null,
      'audioUrl': null,
    },
    {
      'id': 2,
      'type': 'fill_in_blank',
      'question': 'The largest planet in our solar system is _______.',
      'correctAnswer': 'Jupiter',
      'imageUrl':
          'https://images.unsplash.com/photo-1446776653964-20c1d3a81b06?w=400&h=300&fit=crop',
      'audioUrl': null,
    },
    {
      'id': 3,
      'type': 'multiple_choice',
      'question': 'Which of the following is a programming language?',
      'options': ['HTML', 'CSS', 'Python', 'All of the above'],
      'correctAnswer': 2,
      'imageUrl': null,
      'audioUrl': null,
    },
    {
      'id': 4,
      'type': 'matching',
      'question': 'Match the following countries with their capitals:',
      'pairs': [
        {'country': 'Italy', 'capital': 'Rome'},
        {'country': 'Japan', 'capital': 'Tokyo'},
        {'country': 'Brazil', 'capital': 'Brasília'},
      ],
      'imageUrl': null,
      'audioUrl': null,
    },
    {
      'id': 5,
      'type': 'multiple_choice',
      'question': 'What is 2 + 2?',
      'options': ['3', '4', '5', '6'],
      'correctAnswer': 1,
      'imageUrl': null,
      'audioUrl': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted && remainingTimeInMinutes > 0) {
        setState(() {
          remainingTimeInMinutes--;
        });
        _startTimer();
      } else if (remainingTimeInMinutes <= 0) {
        _autoSubmitTest();
      }
    });
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

  void _submitTest() {
    int score = _calculateScore();
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.testResultsScreen,
      arguments: {
        'score': score,
        'totalQuestions': testQuestions.length,
        'userAnswers': userAnswers,
        'questions': testQuestions,
        'timeTaken': 30 - remainingTimeInMinutes,
      },
    );
  }

  int _calculateScore() {
    int correct = 0;
    for (int i = 0; i < testQuestions.length; i++) {
      final question = testQuestions[i];
      final userAnswer = userAnswers[i];

      if (question['type'] == 'multiple_choice') {
        if (userAnswer == question['correctAnswer']) {
          correct++;
        }
      } else if (question['type'] == 'fill_in_blank') {
        if (userAnswer?.toString().toLowerCase() ==
            question['correctAnswer'].toString().toLowerCase()) {
          correct++;
        }
      }
    }
    return correct;
  }

  void _saveAnswer(dynamic answer) {
    setState(() {
      userAnswers[currentQuestionIndex] = answer;
    });
  }

  void _toggleFlag() {
    setState(() {
      if (flaggedQuestions.contains(currentQuestionIndex)) {
        flaggedQuestions.remove(currentQuestionIndex);
      } else {
        flaggedQuestions.add(currentQuestionIndex);
      }
    });
  }

  void _navigateToQuestion(int index) {
    setState(() {
      currentQuestionIndex = index;
      showQuestionOverview = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mathematics Test',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TestTimerWidget(
            remainingMinutes: remainingTimeInMinutes,
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
                  totalQuestions: testQuestions.length,
                  completedQuestions: userAnswers.keys.length,
                  flaggedQuestions: flaggedQuestions.length,
                ),
              ),

              // Question content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: TestQuestionWidget(
                    question: testQuestions[currentQuestionIndex],
                    questionNumber: currentQuestionIndex + 1,
                    userAnswer: userAnswers[currentQuestionIndex],
                    onAnswerChanged: _saveAnswer,
                    isFlagged: flaggedQuestions.contains(currentQuestionIndex),
                    onFlagToggle: _toggleFlag,
                  ),
                ),
              ),

              // Navigation controls
              Container(
                padding: EdgeInsets.all(16),
                child: TestNavigationWidget(
                  currentIndex: currentQuestionIndex,
                  totalQuestions: testQuestions.length,
                  onPrevious: currentQuestionIndex > 0
                      ? () => setState(() => currentQuestionIndex--)
                      : null,
                  onNext: currentQuestionIndex < testQuestions.length - 1
                      ? () => setState(() => currentQuestionIndex++)
                      : null,
                  onSubmit: _showSubmissionDialog,
                  isLastQuestion:
                      currentQuestionIndex == testQuestions.length - 1,
                ),
              ),
            ],
          ),

          // Question overview overlay
          if (showQuestionOverview)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Question Overview',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: testQuestions.length,
                          itemBuilder: (context, index) {
                            final isAnswered = userAnswers.containsKey(index);
                            final isFlagged = flaggedQuestions.contains(index);
                            final isCurrent = index == currentQuestionIndex;

                            return GestureDetector(
                              onTap: () => _navigateToQuestion(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? Theme.of(context).colorScheme.primary
                                      : isAnswered
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : Theme.of(context)
                                              .colorScheme
                                              .surface,
                                  border: Border.all(
                                    color: isFlagged
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).colorScheme.outline,
                                    width: isFlagged ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isCurrent
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLegendItem(
                            color: Theme.of(context).colorScheme.primary,
                            label: 'Current',
                          ),
                          _buildLegendItem(
                            color: Theme.of(context).colorScheme.secondary,
                            label: 'Answered',
                          ),
                          _buildLegendItem(
                            color: Theme.of(context).colorScheme.surface,
                            label: 'Unanswered',
                            borderColor: Theme.of(context).colorScheme.outline,
                          ),
                          _buildLegendItem(
                            color: Theme.of(context).colorScheme.surface,
                            label: 'Flagged',
                            borderColor: Theme.of(context).colorScheme.error,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            setState(() => showQuestionOverview = false),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => showQuestionOverview = true),
        tooltip: 'Question Overview',
        child: Icon(Icons.grid_view),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    Color? borderColor,
  }) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            border: borderColor != null
                ? Border.all(color: borderColor, width: 2)
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10),
        ),
      ],
    );
  }
}
