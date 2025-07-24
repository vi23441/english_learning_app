import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';

class VideoUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Check if user is authenticated
  bool get isUserAuthenticated => _auth.currentUser != null;
  
  // Upload video to Firebase Storage
  Future<String> uploadVideo({
    required File videoFile,
    required String fileName,
    required Function(double) onProgress,
  }) async {
    try {
      // Check if user is authenticated
      if (!isUserAuthenticated) {
        throw Exception('User must be authenticated to upload videos. Please log in first.');
      }
      
      // Get current user ID for folder organization
      final String userId = _auth.currentUser!.uid;
      
      // Create a reference to the file in Firebase Storage with user folder
      final Reference ref = _storage
          .ref()
          .child('videos')
          .child(userId)
          .child(fileName);
      
      // Upload the file with metadata
      final UploadTask uploadTask = ref.putFile(
        videoFile,
        SettableMetadata(
          contentType: 'video/mp4',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
            'originalName': videoFile.path.split('/').last,
          },
        ),
      );
      
      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
      
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } on FirebaseException catch (e) {
      if (e.code == 'unauthorized' || e.code == 'storage/unauthorized') {
        throw Exception('You do not have permission to upload videos. Please check your authentication or contact administrator.');
      } else if (e.code == 'storage/quota-exceeded') {
        throw Exception('Storage quota exceeded. Please try again later or contact administrator.');
      } else if (e.code == 'storage/invalid-argument') {
        throw Exception('Invalid file format or corrupted file.');
      }
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }
  
  // Pick video file from device
  Future<File?> pickVideoFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Check file size (limit to 100MB)
        if (file.size > 100 * 1024 * 1024) {
          throw Exception('Video file size must be less than 100MB');
        }
        
        // Validate file type
        if (!isValidVideoFile(file.name)) {
          throw Exception('Invalid video file format. Supported formats: mp4, avi, mov, mkv, wmv, flv, webm');
        }
        
        return File(file.path!);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to pick video file: $e');
    }
  }
  
  // Delete video from Firebase Storage
  Future<void> deleteVideo(String videoUrl) async {
    try {
      if (!isUserAuthenticated) {
        throw Exception('User must be authenticated to delete videos');
      }
      
      final Reference ref = _storage.refFromURL(videoUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        throw Exception('Video not found');
      } else if (e.code == 'unauthorized') {
        throw Exception('You do not have permission to delete this video');
      }
      throw Exception('Failed to delete video: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete video: $e');
    }
  }
  
  // Get video metadata
  Future<Map<String, dynamic>> getVideoMetadata(String videoUrl) async {
    try {
      final Reference ref = _storage.refFromURL(videoUrl);
      final FullMetadata metadata = await ref.getMetadata();
      
      return {
        'name': metadata.name,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated,
        'updated': metadata.updated,
        'customMetadata': metadata.customMetadata,
      };
    } catch (e) {
      throw Exception('Failed to get video metadata: $e');
    }
  }
  
  // Generate unique filename
  String generateFileName(String originalName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalName.split('.').last;
    return 'video_${timestamp}.$extension';
  }
  
  // Validate video file
  bool isValidVideoFile(String fileName) {
    final validExtensions = ['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', 'webm'];
    final extension = fileName.split('.').last.toLowerCase();
    return validExtensions.contains(extension);
  }
  
  // Format file size
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  // Test Firebase Storage connection and permissions
  Future<bool> testStoragePermissions() async {
    try {
      if (!isUserAuthenticated) {
        print('❌ User not authenticated');
        return false;
      }

      final userId = _auth.currentUser!.uid;
      print('🔍 Testing storage permissions for user: $userId');

      // Test basic storage access
      final ref = _storage.ref().child('videos').child(userId);
      await ref.listAll();
      
      print('✅ Storage permissions OK');
      return true;
    } catch (e) {
      print('❌ Storage permission test failed: $e');
      return false;
    }
  }
}
