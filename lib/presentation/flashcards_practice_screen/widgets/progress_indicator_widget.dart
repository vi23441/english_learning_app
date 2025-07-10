import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentIndex;
  final int totalCards;
  final int knownCount;
  final int unknownCount;
  final int currentStreak;

  const ProgressIndicatorWidget({
    super.key,
    required this.currentIndex,
    required this.totalCards,
    required this.knownCount,
    required this.unknownCount,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCards > 0 ? (currentIndex + 1) / totalCards : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress Bar
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${currentIndex + 1}/$totalCards',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context,
                icon: Icons.check_circle,
                value: knownCount.toString(),
                label: 'Known',
                color: Theme.of(context).colorScheme.tertiary,
              ),
              _buildStatItem(
                context,
                icon: Icons.cancel,
                value: unknownCount.toString(),
                label: 'Unknown',
                color: Theme.of(context).colorScheme.error,
              ),
              _buildStatItem(
                context,
                icon: Icons.local_fire_department,
                value: currentStreak.toString(),
                label: 'Streak',
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
