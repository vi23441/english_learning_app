import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TestQuestionWidget extends StatefulWidget {
  final Map<String, dynamic> question;
  final int questionNumber;
  final dynamic userAnswer;
  final Function(dynamic) onAnswerChanged;
  final bool isFlagged;
  final VoidCallback onFlagToggle;

  const TestQuestionWidget({
    Key? key,
    required this.question,
    required this.questionNumber,
    required this.userAnswer,
    required this.onAnswerChanged,
    required this.isFlagged,
    required this.onFlagToggle,
  }) : super(key: key);

  @override
  State<TestQuestionWidget> createState() => _TestQuestionWidgetState();
}

class _TestQuestionWidgetState extends State<TestQuestionWidget> {
  late TextEditingController _textController;
  int? _selectedOption;
  Map<String, String> _matchingAnswers = {};

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _initializeAnswers();
  }

  void _initializeAnswers() {
    if (widget.userAnswer != null) {
      switch (widget.question['type']) {
        case 'multiple_choice':
          _selectedOption = widget.userAnswer;
          break;
        case 'fill_in_blank':
          _textController.text = widget.userAnswer.toString();
          break;
        case 'matching':
          _matchingAnswers = Map<String, String>.from(widget.userAnswer ?? {});
          break;
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Question ${widget.questionNumber}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onFlagToggle,
                  child: Icon(
                    widget.isFlagged ? Icons.flag : Icons.flag_outlined,
                    color: widget.isFlagged
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Question text
            Text(
              widget.question['question'],
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Question image (if available)
            if (widget.question['imageUrl'] != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: widget.question['imageUrl'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Theme.of(context).colorScheme.surface,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
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
            _buildQuestionContent(),

            // Audio player (if available)
            if (widget.question['audioUrl'] != null)
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
                        // TODO: Implement audio playback
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Audio playback not implemented')),
                        );
                      },
                      child: const Text('Play'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    switch (widget.question['type']) {
      case 'multiple_choice':
        return _buildMultipleChoice();
      case 'fill_in_blank':
        return _buildFillInBlank();
      case 'matching':
        return _buildMatching();
      default:
        return const SizedBox();
    }
  }

  Widget _buildMultipleChoice() {
    final options = widget.question['options'] as List<String>;

    return Column(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;

        return RadioListTile<int>(
          title: Text(
            option,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          value: index,
          groupValue: _selectedOption,
          onChanged: (value) {
            setState(() {
              _selectedOption = value;
            });
            widget.onAnswerChanged(value);
          },
        );
      }).toList(),
    );
  }

  Widget _buildFillInBlank() {
    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        hintText: 'Enter your answer here...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: (value) {
        widget.onAnswerChanged(value);
      },
      style: GoogleFonts.inter(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildMatching() {
    final pairs = widget.question['pairs'] as List<Map<String, String>>;

    return Column(
      children: [
        Text(
          'Drag and drop to match the items:',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: pairs.map((pair) {
            final country = pair['country']!;
            final capital = pair['capital']!;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        country,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      hint: Text('Select capital'),
                      value: _matchingAnswers[country],
                      items: pairs.map((p) => p['capital']!).map((capital) {
                        return DropdownMenuItem<String>(
                          value: capital,
                          child: Text(capital),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          if (value != null) {
                            _matchingAnswers[country] = value;
                          }
                        });
                        widget.onAnswerChanged(_matchingAnswers);
                      },
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
