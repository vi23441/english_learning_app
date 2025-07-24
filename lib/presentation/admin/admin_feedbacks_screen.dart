import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../providers/admin_provider.dart';
import '../../models/feedback.dart';
import '../../widgets/custom_text_form_field.dart';

class AdminFeedbacksScreen extends StatefulWidget {
  const AdminFeedbacksScreen({super.key});

  @override
  State<AdminFeedbacksScreen> createState() => _AdminFeedbacksScreenState();
}

class _AdminFeedbacksScreenState extends State<AdminFeedbacksScreen> {
  String _searchQuery = '';
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchFeedbacks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feedback Management',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryLight,
              ),
            );
          }

          if (adminProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${adminProvider.error}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => adminProvider.fetchFeedbacks(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final feedbacks = _filterFeedbacks(adminProvider.feedbacks);

          return Column(
            children: [
              // Search and Filter Bar
              _buildSearchAndFilter(),
              
              // Feedback List
              Expanded(
                child: feedbacks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.feedback,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No feedback found',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: feedbacks.length,
                        itemBuilder: (context, index) {
                          final feedback = feedbacks[index];
                          return _buildFeedbackCard(feedback, adminProvider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          CustomTextFormField(
            hintText: 'Search feedback...',
            prefix: Container(
              margin: EdgeInsets.fromLTRB(16, 16, 8, 16),
              child: Icon(
                Icons.search,
                color: Colors.grey[600],
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          SizedBox(height: 12),
          
          // Type Filter
          Row(
            children: [
              Text(
                'Filter by type:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String?>(
                  value: _selectedType,
                  isExpanded: true,
                  hint: Text('All types'),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All types'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'bug',
                      child: Text('Bug Report'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'suggestion',
                      child: Text('Suggestion'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'complaint',
                      child: Text('Complaint'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'general',
                      child: Text('General'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackModel feedback, AdminProvider adminProvider) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getTypeColor(feedback.type).withOpacity(0.1),
                  child: Icon(
                    _getTypeIcon(feedback.type),
                    color: _getTypeColor(feedback.type),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        feedback.userName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(feedback.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    feedback.type.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getTypeColor(feedback.type),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Content
            Text(
              feedback.content,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12),
            
            // Rating (if available)
            if (feedback.rating != null) ...[
              Row(
                children: [
                  Text(
                    'Rating: ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ...List.generate(5, (index) {
                    return Icon(
                      index < feedback.rating! ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                  SizedBox(width: 4),
                  Text(
                    '(${feedback.rating})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
            ],
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(feedback.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(feedback, adminProvider),
                  icon: Icon(Icons.delete, size: 16),
                  label: Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'bug':
        return Colors.red;
      case 'suggestion':
        return Colors.blue;
      case 'complaint':
        return Colors.orange;
      case 'general':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'bug':
        return Icons.bug_report;
      case 'suggestion':
        return Icons.lightbulb_outline;
      case 'complaint':
        return Icons.report_problem;
      case 'general':
        return Icons.feedback;
      default:
        return Icons.message;
    }
  }

  List<FeedbackModel> _filterFeedbacks(List<FeedbackModel> feedbacks) {
    return feedbacks.where((feedback) {
      final matchesSearch = _searchQuery.isEmpty ||
          feedback.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          feedback.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          feedback.userName.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesType = _selectedType == null || feedback.type == _selectedType;
      
      return matchesSearch && matchesType;
    }).toList();
  }

  void _showDeleteConfirmation(FeedbackModel feedback, AdminProvider adminProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Feedback'),
        content: Text('Are you sure you want to delete this feedback? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await adminProvider.deleteFeedback(feedback.id, feedback.relatedItemId!);
              
              Navigator.pop(context);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Feedback deleted successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete feedback')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
