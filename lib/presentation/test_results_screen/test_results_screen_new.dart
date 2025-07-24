import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../models/test.dart';

class TestResultsScreen extends StatefulWidget {
  const TestResultsScreen({Key? key}) : super(key: key);

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TestResult? testResult;
  Test? test;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      testResult = args['testResult'] as TestResult?;
      test = args['test'] as Test?;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (testResult == null || test == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Test Results'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'No test results found',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.dashboardHomeScreen,
                ),
                child: Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }

    final score = testResult!.score;
    final totalQuestions = testResult!.totalQuestions;
    final percentage = score;
    final timeTaken = (testResult!.timeTaken / 60).round(); // Convert to minutes

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test Results',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Share functionality not implemented')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Score overview
          Container(
            padding: const EdgeInsets.all(16),
            child: _buildScoreCard(testResult!.correctAnswers, totalQuestions, percentage, timeTaken),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.dashboardHomeScreen,
                        (route) => false,
                      );
                    },
                    child: const Text('Back to Home'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.testListScreen,
                      );
                    },
                    child: const Text('Take Another Test'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics, size: 18),
                      SizedBox(width: 4),
                      Text('Overview'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz, size: 18),
                      SizedBox(width: 4),
                      Text('Review'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 18),
                      SizedBox(width: 4),
                      Text('Stats'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(testResult!.correctAnswers, totalQuestions, percentage, timeTaken),
                _buildReviewTab(test!.questions, testResult!.answers),
                _buildStatisticsTab(testResult!, test!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(int score, int totalQuestions, int percentage, int timeTaken) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Your Score',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getScoreColor(percentage).withOpacity(0.1),
                border: Border.all(
                  color: _getScoreColor(percentage),
                  width: 4,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$percentage%',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(percentage),
                      ),
                    ),
                    Text(
                      '$score/$totalQuestions',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreStat('Time Taken', '${timeTaken}m'),
                _buildScoreStat('Accuracy', '$percentage%'),
                _buildScoreStat('Status', percentage >= 70 ? 'Passed' : 'Failed'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildOverviewTab(int score, int totalQuestions, int percentage, int timeTaken) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Summary',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOverviewRow('Total Questions', totalQuestions.toString()),
                  _buildOverviewRow('Correct Answers', score.toString()),
                  _buildOverviewRow('Incorrect Answers', (totalQuestions - score).toString()),
                  _buildOverviewRow('Accuracy', '$percentage%'),
                  _buildOverviewRow('Time Taken', '${timeTaken} minutes'),
                  _buildOverviewRow('Status', percentage >= 70 ? 'Passed ✅' : 'Failed ❌'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Feedback
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feedback',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getFeedback(percentage),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Recommendations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommendations',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._getRecommendations(percentage).map(
                    (recommendation) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ', style: GoogleFonts.inter(fontSize: 14)),
                          Expanded(
                            child: Text(
                              recommendation,
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getFeedback(int percentage) {
    if (percentage >= 90) {
      return 'Excellent work! You have demonstrated a strong understanding of the material.';
    } else if (percentage >= 80) {
      return 'Great job! You performed very well on this test.';
    } else if (percentage >= 70) {
      return 'Good work! You passed the test. Consider reviewing the topics you missed.';
    } else if (percentage >= 60) {
      return 'Not bad, but there\'s room for improvement. Review the material and try again.';
    } else {
      return 'This test was challenging for you. Consider reviewing the material thoroughly before retaking.';
    }
  }

  List<String> _getRecommendations(int percentage) {
    if (percentage >= 80) {
      return [
        'Continue practicing to maintain your excellent performance',
        'Try more advanced tests to challenge yourself',
        'Help others who are struggling with this topic',
      ];
    } else if (percentage >= 70) {
      return [
        'Review the questions you got wrong',
        'Practice similar questions to improve your skills',
        'Focus on understanding concepts rather than memorizing',
      ];
    } else {
      return [
        'Review the course material thoroughly',
        'Take additional practice tests',
        'Consider seeking help from an instructor or tutor',
        'Focus on understanding the fundamental concepts',
      ];
    }
  }

  Widget _buildReviewTab(List<TestQuestion> questions, Map<String, String> userAnswers) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        final userAnswer = userAnswers[question.id] ?? '';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${index + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  question.question,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                const SizedBox(height: 12),
                
                // User answer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isAnswerCorrect(question, userAnswer)
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isAnswerCorrect(question, userAnswer)
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Answer:',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        userAnswer.isEmpty ? 'No answer provided' : _formatUserAnswer(question, userAnswer),
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Correct Answer:',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatCorrectAnswer(question),
                        style: GoogleFonts.inter(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _isAnswerCorrect(question, userAnswer)
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 16,
                            color: _isAnswerCorrect(question, userAnswer)
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isAnswerCorrect(question, userAnswer)
                                ? 'Correct'
                                : 'Incorrect',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _isAnswerCorrect(question, userAnswer)
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatUserAnswer(TestQuestion question, String userAnswer) {
    if (question.questionType == 'multiple_choice' && question.options.isNotEmpty) {
      try {
        final index = int.parse(userAnswer);
        if (index >= 0 && index < question.options.length) {
          return question.options[index];
        }
      } catch (e) {
        // If parsing fails, return the raw answer
      }
    }
    return userAnswer;
  }

  String _formatCorrectAnswer(TestQuestion question) {
    if (question.questionType == 'multiple_choice' && question.options.isNotEmpty) {
      try {
        final index = int.parse(question.correctAnswer);
        if (index >= 0 && index < question.options.length) {
          return question.options[index];
        }
      } catch (e) {
        // If parsing fails, return the raw answer
      }
    }
    return question.correctAnswer;
  }

  Widget _buildStatisticsTab(TestResult testResult, Test test) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Test info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test Information',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow('Test Title', test.title),
                  _buildStatRow('Category', test.category.displayName),
                  _buildStatRow('Difficulty', test.difficulty.displayName),
                  _buildStatRow('Duration', '${test.duration} minutes'),
                  _buildStatRow('Passing Score', '${test.passingScore}%'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Performance stats card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Statistics',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow('Score', '${testResult.score}%'),
                  _buildStatRow('Correct Answers', '${testResult.correctAnswers}/${testResult.totalQuestions}'),
                  _buildStatRow('Time Taken', '${(testResult.timeTaken / 60).round()} minutes'),
                  _buildStatRow('Status', testResult.isPassed ? 'Passed' : 'Failed'),
                  _buildStatRow('Completed At', testResult.completedAt.toString().split('.')[0]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  bool _isAnswerCorrect(TestQuestion question, String userAnswer) {
    if (userAnswer.isEmpty) return false;

    switch (question.questionType) {
      case 'multiple_choice':
        // For multiple choice, check if the selected option index matches
        try {
          final selectedIndex = int.parse(userAnswer);
          final correctIndex = int.parse(question.correctAnswer);
          return selectedIndex == correctIndex;
        } catch (e) {
          // If parsing fails, do string comparison
          return userAnswer.toLowerCase() == question.correctAnswer.toLowerCase();
        }
      case 'fill_blank':
      case 'fill_in_blank':
        return userAnswer.toLowerCase().trim() == question.correctAnswer.toLowerCase().trim();
      case 'true_false':
        return userAnswer.toLowerCase() == question.correctAnswer.toLowerCase();
      case 'essay':
        // For essay questions, we might need more sophisticated checking
        // For now, just check if something was written
        return userAnswer.trim().isNotEmpty;
      default:
        return userAnswer.toLowerCase() == question.correctAnswer.toLowerCase();
    }
  }
}
