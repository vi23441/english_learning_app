import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class PerformanceChartWidget extends StatefulWidget {
  final int correct;
  final int incorrect;
  final int unanswered;

  const PerformanceChartWidget({
    Key? key,
    required this.correct,
    required this.incorrect,
    required this.unanswered,
  }) : super(key: key);

  @override
  State<PerformanceChartWidget> createState() => _PerformanceChartWidgetState();
}

class _PerformanceChartWidgetState extends State<PerformanceChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.correct + widget.incorrect + widget.unanswered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),

        // Pie chart
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _getPieChartSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem(
              'Correct',
              widget.correct,
              total,
              Colors.green,
            ),
            _buildLegendItem(
              'Incorrect',
              widget.incorrect,
              total,
              Colors.red,
            ),
            if (widget.unanswered > 0)
              _buildLegendItem(
                'Unanswered',
                widget.unanswered,
                total,
                Colors.grey,
              ),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    final total = widget.correct + widget.incorrect + widget.unanswered;

    return [
      PieChartSectionData(
        value: widget.correct.toDouble(),
        color: Colors.green,
        title: '${((widget.correct / total) * 100).round()}%',
        radius: 60 * _animation.value,
        titleStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: widget.incorrect.toDouble(),
        color: Colors.red,
        title: '${((widget.incorrect / total) * 100).round()}%',
        radius: 60 * _animation.value,
        titleStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      if (widget.unanswered > 0)
        PieChartSectionData(
          value: widget.unanswered.toDouble(),
          color: Colors.grey,
          title: '${((widget.unanswered / total) * 100).round()}%',
          radius: 60 * _animation.value,
          titleStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
    ];
  }

  Widget _buildLegendItem(String label, int value, int total, Color color) {
    final percentage = ((value / total) * 100).round();

    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '$value ($percentage%)',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
          ),
        ),
      ],
    );
  }
}
