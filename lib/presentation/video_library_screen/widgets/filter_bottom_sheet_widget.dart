import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final List<String> categories;
  final List<String> activeFilters;
  final Function(List<String>) onFiltersChanged;

  const FilterBottomSheetWidget({
    Key? key,
    required this.categories,
    required this.activeFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late List<String> _selectedFilters;
  String _selectedDifficulty = 'All';
  String _selectedDuration = 'All';
  String _selectedStatus = 'All';

  final List<String> _difficulties = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced'
  ];
  final List<String> _durations = [
    'All',
    'Short (< 15 min)',
    'Medium (15-30 min)',
    'Long (> 30 min)'
  ];
  final List<String> _statuses = [
    'All',
    'Completed',
    'In Progress',
    'Not Started'
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilters = List.from(widget.activeFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Text(
                  'Filter Videos',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilters = ['All Videos'];
                      _selectedDifficulty = 'All';
                      _selectedDuration = 'All';
                      _selectedStatus = 'All';
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories section
                  _buildSectionHeader('Categories'),
                  SizedBox(height: 2.h),
                  _buildCategoryChips(),

                  SizedBox(height: 3.h),

                  // Difficulty section
                  _buildSectionHeader('Difficulty Level'),
                  SizedBox(height: 2.h),
                  _buildDifficultyOptions(),

                  SizedBox(height: 3.h),

                  // Duration section
                  _buildSectionHeader('Video Duration'),
                  SizedBox(height: 2.h),
                  _buildDurationOptions(),

                  SizedBox(height: 3.h),

                  // Status section
                  _buildSectionHeader('Completion Status'),
                  SizedBox(height: 2.h),
                  _buildStatusOptions(),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onFiltersChanged(_selectedFilters);
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: widget.categories.map((category) {
        final isSelected = _selectedFilters.contains(category);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (category == 'All Videos') {
                _selectedFilters = ['All Videos'];
              } else {
                _selectedFilters.remove('All Videos');
                if (isSelected) {
                  _selectedFilters.remove(category);
                } else {
                  _selectedFilters.add(category);
                }
                if (_selectedFilters.isEmpty) {
                  _selectedFilters = ['All Videos'];
                }
              }
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: Text(
              category,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? Colors.white
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultyOptions() {
    return Column(
      children: _difficulties.map((difficulty) {
        return RadioListTile<String>(
          title: Text(
            difficulty,
            style: AppTheme.lightTheme.textTheme.bodyLarge,
          ),
          value: difficulty,
          groupValue: _selectedDifficulty,
          onChanged: (value) {
            setState(() {
              _selectedDifficulty = value!;
            });
          },
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildDurationOptions() {
    return Column(
      children: _durations.map((duration) {
        return RadioListTile<String>(
          title: Text(
            duration,
            style: AppTheme.lightTheme.textTheme.bodyLarge,
          ),
          value: duration,
          groupValue: _selectedDuration,
          onChanged: (value) {
            setState(() {
              _selectedDuration = value!;
            });
          },
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildStatusOptions() {
    return Column(
      children: _statuses.map((status) {
        return RadioListTile<String>(
          title: Text(
            status,
            style: AppTheme.lightTheme.textTheme.bodyLarge,
          ),
          value: status,
          groupValue: _selectedStatus,
          onChanged: (value) {
            setState(() {
              _selectedStatus = value!;
            });
          },
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }
}
