import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/performance_chart_widget.dart';
import './widgets/question_review_widget.dart';
import './widgets/score_card_widget.dart';

class TestResultsScreen extends StatefulWidget {
  const TestResultsScreen({Key? key}) : super(key: key);

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? testResults;

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
      testResults = args;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (testResults == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Test Results'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final score = testResults!['score'] as int;
    final totalQuestions = testResults!['totalQuestions'] as int;
    final userAnswers = testResults!['userAnswers'] as Map<int, dynamic>;
    final questions = testResults!['questions'] as List<Map<String, dynamic>>;
    final timeTaken = testResults!['timeTaken'] as int;
    final percentage = (score / totalQuestions * 100).round();

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
            child: ScoreCardWidget(
              score: score,
              totalQuestions: totalQuestions,
              percentage: percentage,
              timeTaken: timeTaken,
            ),
          ),

          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics, size: 18),
                      const SizedBox(width: 4),
                      Text('Overview'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz, size: 18),
                      const SizedBox(width: 4),
                      Text('Review'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 18),
                      const SizedBox(width: 4),
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
                // Overview tab
                _buildOverviewTab(score, totalQuestions, percentage, timeTaken),

                // Review tab
                _buildReviewTab(questions, userAnswers),

                // Statistics tab
                _buildStatisticsTab(
                    score, totalQuestions, questions, userAnswers),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
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
                    AppRoutes.testTakingScreen,
                  );
                },
                child: const Text('Retake Test'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
      int score, int totalQuestions, int percentage, int timeTaken) {
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem(
                          'Correct Answers',
                          '$score/$totalQuestions',
                          Icons.check_circle,
                          Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Expanded(
                        child: _buildSummaryItem(
                          'Accuracy',
                          '$percentage%',
                          Icons.help_outline,
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem(
                          'Time Taken',
                          '${timeTaken}m',
                          Icons.timer,
                          Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      Expanded(
                        child: _buildSummaryItem(
                          'Grade',
                          _getGrade(percentage),
                          Icons.grade,
                          _getGradeColor(percentage),
                        ),
                      ),
                    ],
                  ),
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
                          Icon(
                            Icons.lightbulb,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              recommendation,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
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

  Widget _buildReviewTab(
      List<Map<String, dynamic>> questions, Map<int, dynamic> userAnswers) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        return QuestionReviewWidget(
          question: questions[index],
          questionNumber: index + 1,
          userAnswer: userAnswers[index],
          isCorrect: _isAnswerCorrect(questions[index], userAnswers[index]),
        );
      },
    );
  }

  Widget _buildStatisticsTab(int score, int totalQuestions,
      List<Map<String, dynamic>> questions, Map<int, dynamic> userAnswers) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Performance chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: PerformanceChartWidget(
                correct: score,
                incorrect: totalQuestions - score,
                unanswered: totalQuestions - userAnswers.length,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Question type breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question Type Performance',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._getQuestionTypeStats(questions, userAnswers).entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  entry.key,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: LinearProgressIndicator(
                                  value: (entry.value['percentage'] as int) / 100,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withAlpha(51),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${entry.value['percentage']}%',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
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

  Widget _buildSummaryItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getGrade(int percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  Color _getGradeColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getFeedback(int percentage) {
    if (percentage >= 90) {
      return 'Excellent work! You have mastered this topic and demonstrated exceptional understanding.';
    } else if (percentage >= 80) {
      return 'Great job! You have a solid understanding of the material with minor areas for improvement.';
    } else if (percentage >= 70) {
      return 'Good effort! You understand most concepts but may benefit from reviewing some topics.';
    } else if (percentage >= 60) {
      return 'Fair performance. Consider reviewing the material and practicing more to improve your understanding.';
    } else {
      return 'This topic needs more attention. Review the material thoroughly and consider seeking additional help.';
    }
  }

  List<String> _getRecommendations(int percentage) {
    if (percentage >= 90) {
      return [
        'Challenge yourself with advanced topics',
        'Help others who are struggling with this material',
        'Consider taking more advanced courses',
      ];
    } else if (percentage >= 80) {
      return [
        'Review the questions you got wrong',
        'Practice similar problems to reinforce learning',
        'Move on to the next topic when ready',
      ];
    } else if (percentage >= 70) {
      return [
        'Review the material for topics you struggled with',
        'Take practice tests to identify weak areas',
        'Consider forming study groups with classmates',
      ];
    } else if (percentage >= 60) {
      return [
        'Dedicate more time to studying this material',
        'Seek help from teachers or tutors',
        'Use additional learning resources and practice materials',
      ];
    } else {
      return [
        'Start with the basics and build your foundation',
        'Seek immediate help from teachers or tutors',
        'Use multiple learning resources and study methods',
        'Consider retaking the test after more preparation',
      ];
    }
  }

  bool _isAnswerCorrect(Map<String, dynamic> question, dynamic userAnswer) {
    if (userAnswer == null) return false;

    switch (question['type']) {
      case 'multiple_choice':
        return userAnswer == question['correctAnswer'];
      case 'fill_in_blank':
        return userAnswer.toString().toLowerCase() ==
            question['correctAnswer'].toString().toLowerCase();
      case 'matching':
        // For simplicity, assume correct if all pairs match
        final correctPairs = question['pairs'] as List<Map<String, String>>;
        final userPairs = userAnswer as Map<String, String>;
        for (var pair in correctPairs) {
          if (userPairs[pair['country']] != pair['capital']) {
            return false;
          }
        }
        return true;
      default:
        return false;
    }
  }

  Map<String, Map<String, int>> _getQuestionTypeStats(
      List<Map<String, dynamic>> questions, Map<int, dynamic> userAnswers) {
    Map<String, Map<String, int>> stats = {};

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final type = question['type'] as String;
      final isCorrect = _isAnswerCorrect(question, userAnswers[i]);

      if (!stats.containsKey(type)) {
        stats[type] = {'correct': 0, 'total': 0};
      }

      stats[type]!['total'] = stats[type]!['total']! + 1;
      if (isCorrect) {
        stats[type]!['correct'] = stats[type]!['correct']! + 1;
      }
    }

    // Convert to percentage
    Map<String, Map<String, int>> result = {};
    stats.forEach((type, data) {
      result[type] = {
        'percentage': ((data['correct']! / data['total']!) * 100).round(),
        'correct': data['correct']!,
        'total': data['total']!,
      };
    });

    return result;
  }
}