import 'package:flutter/material.dart';

class SessionControlsWidget extends StatelessWidget {
  final VoidCallback onPlayAudio;
  final VoidCallback onShowHint;
  final VoidCallback onMarkKnown;
  final VoidCallback onMarkUnknown;
  final bool isFlipped;

  const SessionControlsWidget({
    super.key,
    required this.onPlayAudio,
    required this.onShowHint,
    required this.onMarkKnown,
    required this.onMarkUnknown,
    required this.isFlipped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Audio and Hint Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                context,
                icon: Icons.volume_up,
                label: 'Audio',
                onPressed: onPlayAudio,
                color: Theme.of(context).colorScheme.primary,
              ),
              _buildControlButton(
                context,
                icon: Icons.lightbulb_outline,
                label: 'Hint',
                onPressed: onShowHint,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Response Buttons (only show when flipped)
          if (isFlipped)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onMarkUnknown,
                    icon: const Icon(Icons.close),
                    label: const Text('Don\'t Know'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onMarkKnown,
                    icon: const Icon(Icons.check),
                    label: const Text('Know'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      foregroundColor: Theme.of(context).colorScheme.onTertiary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          iconSize: 32,
          style: IconButton.styleFrom(
            backgroundColor: color.withAlpha(26),
            foregroundColor: color,
            padding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
