import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io'; // Add this import

import '../../core/app_export.dart';
import '../../providers/admin_provider.dart';
import '../../models/question.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';

class AdminQuestionsScreen extends StatefulWidget {
  const AdminQuestionsScreen({super.key});

  @override
  State<AdminQuestionsScreen> createState() => _AdminQuestionsScreenState();
}

class _AdminQuestionsScreenState extends State<AdminQuestionsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question Management',
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
            onPressed: () => _showAddQuestionDialog(context.read<AdminProvider>()),
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
                    onPressed: () => adminProvider.fetchQuestions(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final questions = _filterQuestions(adminProvider.questions);

          return Column(
            children: [
              // Search Bar
              _buildSearchBar(),
              
              // Question List
              Expanded(
                child: questions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.help_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No questions found',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          return _buildQuestionCard(question, adminProvider);
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
        hintText: 'Search questions...',
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

  Widget _buildQuestionCard(Question question, AdminProvider adminProvider) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.help_outline,
            color: AppTheme.primaryLight,
          ),
        ),
        title: Text(
          question.content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Correct answer: ${question.options[question.correctAnswer]}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.green[600],
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Options:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                ...question.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isCorrect = index == question.correctAnswer;
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isCorrect ? Colors.green : Colors.grey,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${String.fromCharCode(65 + index)}. $option',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isCorrect ? Colors.green[600] : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                SizedBox(height: 16),
                Text(
                  'Explanation:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  question.explanation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEditQuestionDialog(question, adminProvider),
                      icon: Icon(Icons.edit, size: 16),
                      label: Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showDeleteConfirmation(question, adminProvider),
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
        ],
      ),
    );
  }

  List<Question> _filterQuestions(List<Question> questions) {
    return questions.where((question) {
      final matchesSearch = _searchQuery.isEmpty ||
          question.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          question.options.any((option) => option.toLowerCase().contains(_searchQuery.toLowerCase()));
      
      return matchesSearch;
    }).toList();
  }

  void _showAddQuestionDialog(AdminProvider adminProvider) {
    final contentController = TextEditingController();
    final explanationController = TextEditingController();
    final imageUrlController = TextEditingController();
    final audioUrlController = TextEditingController();
    final optionControllers = List.generate(4, (index) => TextEditingController());
    int correctAnswer = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(
                  controller: contentController,
                  hintText: 'Question content',
                  textInputType: TextInputType.multiline,
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                CustomTextFormField(
                  controller: imageUrlController,
                  hintText: 'Image URL (optional)',
                  textInputType: TextInputType.url,
                  suffix: IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () async {
                      final url = await _pickAndUploadFile(FileType.image, context);
                      if (url != null) {
                        setState(() {
                          imageUrlController.text = url;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(height: 16),
                CustomTextFormField(
                  controller: audioUrlController,
                  hintText: 'Audio URL (optional)',
                  textInputType: TextInputType.url,
                  suffix: IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () async {
                      final url = await _pickAndUploadFile(FileType.audio, context);
                      if (url != null) {
                        setState(() {
                          audioUrlController.text = url;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Options:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                ...optionControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: index,
                          groupValue: correctAnswer,
                          onChanged: (int? value) {
                            setState(() {
                              correctAnswer = value ?? 0;
                            });
                          },
                        ),
                        Expanded(
                          child: CustomTextFormField(
                            controller: controller,
                            hintText: 'Option ${String.fromCharCode(65 + index)}',
                            textInputType: TextInputType.text,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                SizedBox(height: 16),
                CustomTextFormField(
                  controller: explanationController,
                  hintText: 'Explanation',
                  textInputType: TextInputType.multiline,
                  maxLines: 3,
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
                if (contentController.text.trim().isEmpty ||
                    explanationController.text.trim().isEmpty ||
                    optionControllers.any((controller) => controller.text.trim().isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final newQuestion = Question(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  content: contentController.text.trim(),
                  options: optionControllers.map((controller) => controller.text.trim()).toList(),
                  correctAnswer: correctAnswer,
                  explanation: explanationController.text.trim(),
                  imageUrl: imageUrlController.text.trim().isEmpty ? null : imageUrlController.text.trim(),
                  audioUrl: audioUrlController.text.trim().isEmpty ? null : audioUrlController.text.trim(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  createdBy: 'admin', // TODO: Get from auth provider
                );

                final success = await adminProvider.addQuestion(newQuestion);
                
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Question added successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add question')),
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

  void _showEditQuestionDialog(Question question, AdminProvider adminProvider) {
    final contentController = TextEditingController(text: question.content);
    final explanationController = TextEditingController(text: question.explanation);
    final imageUrlController = TextEditingController(text: question.imageUrl);
    final audioUrlController = TextEditingController(text: question.audioUrl);
    final optionControllers = question.options.map((option) => TextEditingController(text: option)).toList();
    int correctAnswer = question.correctAnswer;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Question'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(
                  controller: contentController,
                  hintText: 'Question content',
                  textInputType: TextInputType.multiline,
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                CustomTextFormField(
                  controller: imageUrlController,
                  hintText: 'Image URL (optional)',
                  textInputType: TextInputType.url,
                  suffix: IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () async {
                      final url = await _pickAndUploadFile(FileType.image, context);
                      if (url != null) {
                        setState(() {
                          imageUrlController.text = url;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(height: 16),
                CustomTextFormField(
                  controller: audioUrlController,
                  hintText: 'Audio URL (optional)',
                  textInputType: TextInputType.url,
                  suffix: IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () async {
                      final url = await _pickAndUploadFile(FileType.audio, context);
                      if (url != null) {
                        setState(() {
                          audioUrlController.text = url;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Options:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                ...optionControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: index,
                          groupValue: correctAnswer,
                          onChanged: (int? value) {
                            setState(() {
                              correctAnswer = value ?? 0;
                            });
                          },
                        ),
                        Expanded(
                          child: CustomTextFormField(
                            controller: controller,
                            hintText: 'Option ${String.fromCharCode(65 + index)}',
                            textInputType: TextInputType.text,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                SizedBox(height: 16),
                CustomTextFormField(
                  controller: explanationController,
                  hintText: 'Explanation',
                  textInputType: TextInputType.multiline,
                  maxLines: 3,
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
                if (contentController.text.trim().isEmpty ||
                    explanationController.text.trim().isEmpty ||
                    optionControllers.any((controller) => controller.text.trim().isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final updatedQuestion = question.copyWith(
                  content: contentController.text.trim(),
                  options: optionControllers.map((controller) => controller.text.trim()).toList(),
                  correctAnswer: correctAnswer,
                  explanation: explanationController.text.trim(),
                  imageUrl: imageUrlController.text.trim().isEmpty ? null : imageUrlController.text.trim(),
                  audioUrl: audioUrlController.text.trim().isEmpty ? null : audioUrlController.text.trim(),
                  updatedAt: DateTime.now(),
                );

                final success = await adminProvider.updateQuestion(updatedQuestion);
                
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Question updated successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update question')),
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

  Future<String?> _pickAndUploadFile(FileType type, BuildContext context) async {
    print('Attempting to pick file of type: $type');
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: type);

    if (result != null) {
      PlatformFile file = result.files.first;
      print('File picked: ${file.name}, size: ${file.size} bytes');
      try {
        // Upload file to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref();
        final uploadPath = 'question_media/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        print('Uploading to path: $uploadPath');
        UploadTask uploadTask;
        if (file.bytes != null) {
          uploadTask = storageRef.child(uploadPath).putData(file.bytes!);
        } else if (file.path != null) {
          uploadTask = storageRef.child(uploadPath).putFile(File(file.path!));
        } else {
          throw Exception('File data or path is null.');
        }
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print('File uploaded successfully. Download URL: $downloadUrl');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File uploaded successfully!')),
        );
        return downloadUrl;
      } catch (e) {
        print('Error uploading file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file: $e')),
        );
        return null;
      }
    } else {
      print('File picking cancelled by user.');
      // User canceled the picker
      return null;
    }
  }

  void _showDeleteConfirmation(Question question, AdminProvider adminProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Question'),
        content: Text('Are you sure you want to delete this question? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await adminProvider.deleteQuestion(question.id);
              
              Navigator.pop(context);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Question deleted successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete question')),
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
}
