import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QuestionReviewWidget extends StatelessWidget {
  final Map<String, dynamic> question;
  final int questionNumber;
  final dynamic userAnswer;
  final bool isCorrect;

  const QuestionReviewWidget({
    Key? key,
    required this.question,
    required this.questionNumber,
    required this.userAnswer,
    required this.isCorrect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Question $questionNumber',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        (isCorrect ? Colors.green : Colors.red).withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCorrect ? 'Correct' : 'Incorrect',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Question text
            Text(
              question['question'],
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            // Question image (if available)
            if (question['imageUrl'] != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: question['imageUrl'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 150,
                      color: Theme.of(context).colorScheme.surface,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 150,
                      color: Theme.of(context).colorScheme.surface,
                      child: const Center(
                        child: Icon(Icons.error_outline),
                      ),
                    ),
                  ),
                ),
              ),

            // Answer analysis
            _buildAnswerAnalysis(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerAnalysis() {
    switch (question['type']) {
      case 'multiple_choice':
        return _buildMultipleChoiceAnalysis();
      case 'fill_in_blank':
        return _buildFillInBlankAnalysis();
      case 'matching':
        return _buildMatchingAnalysis();
      default:
        return const SizedBox();
    }
  }

  Widget _buildMultipleChoiceAnalysis() {
    final options = question['options'] as List<String>;
    final correctAnswer = question['correctAnswer'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Answer Options:',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isCorrectOption = index == correctAnswer;
          final isUserSelection = userAnswer == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCorrectOption
                  ? Colors.green.withAlpha(26)
                  : isUserSelection && !isCorrectOption
                      ? Colors.red.withAlpha(26)
                      : Colors.transparent,
              border: Border.all(
                color: isCorrectOption
                    ? Colors.green
                    : isUserSelection && !isCorrectOption
                        ? Colors.red
                        : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isCorrectOption
                      ? Icons.check_circle
                      : isUserSelection && !isCorrectOption
                          ? Icons.cancel
                          : Icons.radio_button_unchecked,
                  size: 20,
                  color: isCorrectOption
                      ? Colors.green
                      : isUserSelection && !isCorrectOption
                          ? Colors.red
                          : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    option,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isCorrectOption
                          ? Colors.green
                          : isUserSelection && !isCorrectOption
                              ? Colors.red
                              : Colors.grey[600],
                    ),
                  ),
                ),
                if (isUserSelection)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isCorrectOption ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Your answer',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFillInBlankAnalysis() {
    final correctAnswer = question['correctAnswer'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAnswerItem(
          'Your Answer:',
          userAnswer?.toString() ?? 'Not answered',
          isCorrect ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 8),
        _buildAnswerItem(
          'Correct Answer:',
          correctAnswer,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildMatchingAnalysis() {
    final correctPairs = question['pairs'] as List<Map<String, String>>;
    final userPairs = userAnswer as Map<String, String>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Matching Results:',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...correctPairs.map((pair) {
          final country = pair['country']!;
          final correctCapital = pair['capital']!;
          final userCapital = userPairs[country];
          final isCorrectMatch = userCapital == correctCapital;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCorrectMatch
                  ? Colors.green.withAlpha(26)
                  : Colors.red.withAlpha(26),
              border: Border.all(
                color: isCorrectMatch ? Colors.green : Colors.red,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isCorrectMatch ? Icons.check_circle : Icons.cancel,
                  color: isCorrectMatch ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$country → ${userCapital ?? 'Not answered'}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!isCorrectMatch)
                        Text(
                          'Correct: $correctCapital',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAnswerItem(String label, String answer, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            answer,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
