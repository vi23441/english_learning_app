import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../providers/admin_provider.dart';
import '../../models/test.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';

class AdminTestsScreen extends StatefulWidget {
  const AdminTestsScreen({super.key});

  @override
  State<AdminTestsScreen> createState() => _AdminTestsScreenState();
}

class _AdminTestsScreenState extends State<AdminTestsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchTests();
      context.read<AdminProvider>().fetchQuestions(); // Đảm bảo luôn có câu hỏi
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test Management',
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
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: AppTheme.primaryLight),
            onPressed: () => _showAddTestDialog(context.read<AdminProvider>()),
          ),
        ],
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
                    onPressed: () => adminProvider.fetchTests(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final tests = _filterTests(adminProvider.tests);

          return Column(
            children: [
              // Search Bar
              _buildSearchBar(),
              
              // Test List
              Expanded(
                child: tests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.quiz,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No tests found',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: tests.length,
                        itemBuilder: (context, index) {
                          final test = tests[index];
                          return _buildTestCard(test, adminProvider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
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
      child: CustomTextFormField(
        hintText: 'Search tests...',
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
    );
  }

  Widget _buildTestCard(TestModel test, AdminProvider adminProvider) {
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
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.quiz,
                    color: AppTheme.primaryLight,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        test.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Test Info
            Row(
              children: [
                _buildInfoChip('Questions', test.questions.length.toString()),
                SizedBox(width: 8),
                _buildInfoChip('Duration', '${test.duration} min'),
                SizedBox(width: 8),
                _buildInfoChip('Level', test.level),
              ],
            ),
            SizedBox(height: 12),
            
            // Actions
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () => _showAddQuestionsToTestDialog(test, adminProvider),
                  icon: Icon(Icons.playlist_add, size: 16),
                  label: Text('Thêm câu hỏi'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showEditTestDialog(test, adminProvider),
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(test, adminProvider),
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

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[700],
        ),
      ),
    );
  }

  List<TestModel> _filterTests(List<TestModel> tests) {
    return tests.where((test) {
      final matchesSearch = _searchQuery.isEmpty ||
          test.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          test.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesSearch;
    }).toList();
  }

  void _showAddTestDialog(AdminProvider adminProvider) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final durationController = TextEditingController();
    String selectedLevel = 'Beginner';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Test'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(
                  controller: titleController,
                  hintText: 'Test Title',
                  textInputType: TextInputType.text,
                ),
                SizedBox(height: 16),
                CustomTextFormField(
                  controller: descriptionController,
                  hintText: 'Description',
                  textInputType: TextInputType.multiline,
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                CustomTextFormField(
                  controller: durationController,
                  hintText: 'Duration (minutes)',
                  textInputType: TextInputType.number,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedLevel,
                  decoration: InputDecoration(
                    labelText: 'Level',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        selectedLevel = value;
                      });
                    }
                  },
                  items: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty ||
                    descriptionController.text.trim().isEmpty ||
                    durationController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final newTest = TestModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  questions: [], // Empty questions list, will be added later
                  duration: int.tryParse(durationController.text.trim()) ?? 0,
                  level: selectedLevel,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                final success = await adminProvider.addTest(newTest);
                
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Test added successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add test')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTestDialog(TestModel test, AdminProvider adminProvider) {
    final titleController = TextEditingController(text: test.title);
    final descriptionController = TextEditingController(text: test.description);
    final durationController = TextEditingController(text: test.duration.toString());
    String selectedLevel = test.level;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Test'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(
                  controller: titleController,
                  hintText: 'Test Title',
                  textInputType: TextInputType.text,
                ),
                SizedBox(height: 16),
                CustomTextFormField(
                  controller: descriptionController,
                  hintText: 'Description',
                  textInputType: TextInputType.multiline,
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                CustomTextFormField(
                  controller: durationController,
                  hintText: 'Duration (minutes)',
                  textInputType: TextInputType.number,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedLevel,
                  decoration: InputDecoration(
                    labelText: 'Level',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        selectedLevel = value;
                      });
                    }
                  },
                  items: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty ||
                    descriptionController.text.trim().isEmpty ||
                    durationController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final updatedTest = test.copyWith(
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  duration: int.tryParse(durationController.text.trim()) ?? 0,
                  level: selectedLevel,
                  updatedAt: DateTime.now(),
                );

                final success = await adminProvider.updateTest(updatedTest);
                
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Test updated successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update test')),
                  );
                }
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(TestModel test, AdminProvider adminProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Test'),
        content: Text('Are you sure you want to delete "${test.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await adminProvider.deleteTest(test.id);
              
              Navigator.pop(context);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Test deleted successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete test')),
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

  // Sửa dialog chọn câu hỏi: nếu không có câu hỏi thì hiển thị thông báo
  void _showAddQuestionsToTestDialog(TestModel test, AdminProvider adminProvider) async {
    final allQuestions = adminProvider.questions;
    if (allQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không có câu hỏi nào để chọn!')),
      );
      return;
    }
    final selectedQuestions = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        final selected = Set<String>.from(test.questions);
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Chọn câu hỏi cho bài test'),
            content: SizedBox(
              width: 400,
              height: 400,
              child: ListView(
                children: allQuestions.map((q) {
                  return CheckboxListTile(
                    value: selected.contains(q.id),
                    title: Text(q.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text('ID: ${q.id}'),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selected.add(q.id);
                        } else {
                          selected.remove(q.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selected.toList()),
                child: Text('Lưu'),
              ),
            ],
          ),
        );
      },
    );
    if (selectedQuestions != null) {
      final updatedTest = test.copyWith(
        questions: selectedQuestions,
        updatedAt: DateTime.now(),
      );
      final success = await adminProvider.updateTest(updatedTest);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật câu hỏi cho bài test!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thất bại!')),
        );
      }
    }
  }
}
