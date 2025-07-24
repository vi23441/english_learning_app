import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/video_upload_service.dart';
import '../providers/admin_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_elevated_button.dart';

class VideoUploadDialog extends StatefulWidget {
  final String? videoId;
  final String? initialTitle;
  final String? initialDescription;
  final String? initialVideoUrl;
  final String? initialThumbnailUrl;
  final String? initialLevel;
  final String? initialCategory;

  const VideoUploadDialog({
    Key? key,
    this.videoId,
    this.initialTitle,
    this.initialDescription,
    this.initialVideoUrl,
    this.initialThumbnailUrl,
    this.initialLevel,
    this.initialCategory,
  }) : super(key: key);

  @override
  State<VideoUploadDialog> createState() => _VideoUploadDialogState();
}

class _VideoUploadDialogState extends State<VideoUploadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();
  final VideoUploadService _uploadService = VideoUploadService();

  File? _selectedVideoFile;
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  bool _isLoading = false;
  String? _uploadedVideoUrl;
  String _selectedLevel = 'Beginner';
  String _selectedCategory = 'Grammar';

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _categories = ['Grammar', 'Vocabulary', 'Pronunciation', 'Listening', 'Speaking', 'Writing'];

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
    if (widget.initialDescription != null) {
      _descriptionController.text = widget.initialDescription!;
    }
    if (widget.initialThumbnailUrl != null) {
      _thumbnailUrlController.text = widget.initialThumbnailUrl!;
    }
    if (widget.initialVideoUrl != null) {
      _uploadedVideoUrl = widget.initialVideoUrl!;
    }
    if (widget.initialLevel != null) {
      _selectedLevel = widget.initialLevel!;
    }
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final file = await _uploadService.pickVideoFile();
      if (file != null) {
        setState(() {
          _selectedVideoFile = file;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking video: $e')),
      );
    }
  }

  Future<void> _uploadVideo() async {
    if (_selectedVideoFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final fileName = _uploadService.generateFileName(_selectedVideoFile!.path.split('/').last);
      
      final videoUrl = await _uploadService.uploadVideo(
        videoFile: _selectedVideoFile!,
        fileName: fileName,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      setState(() {
        _uploadedVideoUrl = videoUrl;
        _isUploading = false;
        _selectedVideoFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded successfully!')),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  Future<void> _saveVideo() async {
    if (!_formKey.currentState!.validate()) return;

    if (_uploadedVideoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a video first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);

      final videoData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'videoUrl': _uploadedVideoUrl!,
        'thumbnailUrl': _thumbnailUrlController.text.trim(),
        'level': _selectedLevel,
        'category': _selectedCategory,
        'duration': 0, // TODO: Get actual duration from video
        'views': 0,
        'likes': 0,
        'isActive': true,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      if (widget.videoId != null) {
        await adminProvider.updateVideo(widget.videoId!, videoData);
      } else {
        await adminProvider.createVideo(videoData);
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving video: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.videoId != null ? 'Edit Video' : 'Upload Video',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Upload Section
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildVideoUploadSection(),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Video Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Thumbnail URL
                      TextFormField(
                        controller: _thumbnailUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Thumbnail URL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Level and Category
                      Column(
                        children: [
                          // Level Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedLevel,
                            decoration: const InputDecoration(
                              labelText: 'Level',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            isExpanded: true,
                            items: _levels.map((level) {
                              return DropdownMenuItem(
                                value: level,
                                child: Text(
                                  level,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedLevel = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // Category Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            isExpanded: true,
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                CustomElevatedButton(
                  onPressed: _isLoading ? null : _saveVideo,
                  text: widget.videoId != null ? 'Update' : 'Create',
                  isLoading: _isLoading,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoUploadSection() {
    if (_isUploading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(value: _uploadProgress),
          const SizedBox(height: 16),
          Text('Uploading... ${(_uploadProgress * 100).toStringAsFixed(1)}%'),
        ],
      );
    }

    if (_uploadedVideoUrl != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 48,
            color: AppTheme.successLight,
          ),
          const SizedBox(height: 16),
          const Text('Video uploaded successfully!'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _pickVideo,
            child: const Text('Choose different video'),
          ),
        ],
      );
    }

    if (_selectedVideoFile != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_file,
            size: 48,
            color: AppTheme.primaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedVideoFile!.path.split('/').last,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          Text(
            _uploadService.formatFileSize(_selectedVideoFile!.lengthSync()),
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          CustomElevatedButton(
            onPressed: _uploadVideo,
            text: 'Upload Video',
            width: 150,
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        const Text('Select a video to upload'),
        const SizedBox(height: 16),
        CustomElevatedButton(
          onPressed: _pickVideo,
          text: 'Choose Video',
          width: 150,
        ),
      ],
    );
  }
}
