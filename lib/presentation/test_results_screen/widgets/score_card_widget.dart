import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreCardWidget extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final int percentage;
  final int timeTaken;

  const ScoreCardWidget({
    Key? key,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.timeTaken,
  }) : super(key: key);

  @override
  State<ScoreCardWidget> createState() => _ScoreCardWidgetState();
}

class _ScoreCardWidgetState extends State<ScoreCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: widget.percentage / 100.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getScoreColor() {
    if (widget.percentage >= 80) return Colors.green;
    if (widget.percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Score display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular progress indicator
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: _scoreAnimation.value,
                            strokeWidth: 8,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .outline
                                .withAlpha(51),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_getScoreColor()),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(_scoreAnimation.value * 100).round()}%',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: _getScoreColor(),
                              ),
                            ),
                            Text(
                              '${widget.score}/${widget.totalQuestions}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Score details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDetailItem(
                  'Correct',
                  '${widget.score}',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildDetailItem(
                  'Wrong',
                  '${widget.totalQuestions - widget.score}',
                  Icons.cancel,
                  Colors.red,
                ),
                _buildDetailItem(
                  'Time',
                  '${widget.timeTaken}m',
                  Icons.timer,
                  Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Performance badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getScoreColor().withAlpha(26),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getScoreColor()),
              ),
              child: Text(
                _getPerformanceText(),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getScoreColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _getPerformanceText() {
    if (widget.percentage >= 90) return 'Excellent Performance';
    if (widget.percentage >= 80) return 'Great Work';
    if (widget.percentage >= 70) return 'Good Job';
    if (widget.percentage >= 60) return 'Fair Performance';
    return 'Needs Improvement';
  }
}
