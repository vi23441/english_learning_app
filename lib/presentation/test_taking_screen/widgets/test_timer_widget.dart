import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TestTimerWidget extends StatefulWidget {
  final int remainingMinutes;
  final VoidCallback onTimeUp;

  const TestTimerWidget({
    Key? key,
    required this.remainingMinutes,
    required this.onTimeUp,
  }) : super(key: key);

  @override
  State<TestTimerWidget> createState() => _TestTimerWidgetState();
}

class _TestTimerWidgetState extends State<TestTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _setupColorAnimation();

    if (widget.remainingMinutes <= 5) {
      _animationController.repeat(reverse: true);
    }
  }

  void _setupColorAnimation() {
    Color startColor = _getTimerColor();
    Color endColor =
        widget.remainingMinutes <= 5 ? Colors.red.shade700 : startColor;

    _colorAnimation = ColorTween(
      begin: startColor,
      end: endColor,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Color _getTimerColor() {
    if (widget.remainingMinutes <= 5) {
      return Colors.red;
    } else if (widget.remainingMinutes <= 10) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  void didUpdateWidget(TestTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remainingMinutes != widget.remainingMinutes) {
      _setupColorAnimation();
      if (widget.remainingMinutes <= 5 && !_animationController.isAnimating) {
        _animationController.repeat(reverse: true);
      } else if (widget.remainingMinutes > 5 &&
          _animationController.isAnimating) {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(int minutes) {
    int hours = minutes ~/ 60;
    int mins = minutes % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    } else {
      return '${mins}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _colorAnimation.value?.withAlpha(26) ??
                _getTimerColor().withAlpha(26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _colorAnimation.value ?? _getTimerColor(),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                size: 16,
                color: _colorAnimation.value ?? _getTimerColor(),
              ),
              const SizedBox(width: 4),
              Text(
                _formatTime(widget.remainingMinutes),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _colorAnimation.value ?? _getTimerColor(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
