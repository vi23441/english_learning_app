import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/feedback.dart';
import '../../models/video.dart';

class VideoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  late final CollectionReference _videosCollection;

  VideoService() : _videosCollection = FirebaseFirestore.instance.collection('videos');

  // Get all videos
  Future<List<Video>> getAllVideos() async {
    try {
      final querySnapshot = await _videosCollection.where('isActive', isEqualTo: true).get();
      return querySnapshot.docs.map((doc) => Video.fromDocument(doc)).toList();
    } catch (e) {
      print('Error getting all videos: $e');
      return [];
    }
  }

  // Get a single video by its ID
  Future<Video?> getVideoById(String id) async {
    try {
      final docSnapshot = await _videosCollection.doc(id).get();
      if (docSnapshot.exists) {
        return Video.fromDocument(docSnapshot);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting video by ID: $e');
      return null;
    }
  }

  // Get videos by category
  Future<List<Video>> getVideosByCategory(String category) async {
    try {
      final querySnapshot = await _videosCollection
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .get();
      return querySnapshot.docs.map((doc) => Video.fromDocument(doc)).toList();
    } catch (e) {
      print('Error getting videos by category: $e');
      return [];
    }
  }

  // Get videos by level
  Future<List<Video>> getVideosByLevel(String level) async {
    try {
      final querySnapshot = await _videosCollection
          .where('level', isEqualTo: level)
          .where('isActive', isEqualTo: true)
          .get();
      return querySnapshot.docs.map((doc) => Video.fromDocument(doc)).toList();
    } catch (e) {
      print('Error getting videos by level: $e');
      return [];
    }
  }

  // Get popular videos (by viewCount)
  Future<List<Video>> getPopularVideos({int limit = 10}) async {
    try {
      final querySnapshot = await _videosCollection
          .where('isActive', isEqualTo: true)
          .orderBy('viewCount', descending: true)
          .limit(limit)
          .get();
      return querySnapshot.docs.map((doc) => Video.fromDocument(doc)).toList();
    } catch (e) {
      print('Error getting popular videos: $e');
      return [];
    }
  }

  // Get recent videos (by createdAt)
  Future<List<Video>> getRecentVideos({int limit = 10}) async {
    try {
      final querySnapshot = await _videosCollection
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return querySnapshot.docs.map((doc) => Video.fromDocument(doc)).toList();
    } catch (e) {
      print('Error getting recent videos: $e');
      return [];
    }
  }

  // Get top-rated videos (by averageRating)
  Future<List<Video>> getTopRatedVideos({int limit = 10}) async {
    try {
      final querySnapshot = await _videosCollection
          .where('isActive', isEqualTo: true)
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();
      return querySnapshot.docs.map((doc) => Video.fromDocument(doc)).toList();
    } catch (e) {
      print('Error getting top-rated videos: $e');
      return [];
    }
  }

  // Search videos by title or tags
  Future<List<Video>> searchVideos(String query) async {
    if (query.isEmpty) return [];
    try {
      // This is a simplified search. For production, use a dedicated search service like Algolia or Elasticsearch.
      final titleQuery = await _videosCollection
          .where('isActive', isEqualTo: true)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      final tagsQuery = await _videosCollection
          .where('isActive', isEqualTo: true)
          .where('tags', arrayContains: query)
          .get();

      final results = {...titleQuery.docs, ...tagsQuery.docs}.map((doc) => Video.fromDocument(doc)).toList();
      return results;
    } catch (e) {
      print('Error searching videos: $e');
      return [];
    }
  }

  // Add a new video
  Future<void> addVideo(Video video) async {
    try {
      await _videosCollection.doc(video.id).set(video.toMap());
    } catch (e) {
      print('Error adding video: $e');
      throw e;
    }
  }

  // Update an existing video
  Future<void> updateVideo(String videoId, Video video) async {
    try {
      await _videosCollection.doc(videoId).update(video.toMap());
    } catch (e) {
      print('Error updating video: $e');
      throw e;
    }
  }

  // Delete a video (soft delete by setting isActive to false)
  Future<void> deleteVideo(String videoId) async {
    try {
      await _videosCollection.doc(videoId).update({'isActive': false});
    } catch (e) {
      print('Error deleting video: $e');
      throw e;
    }
  }

  // Increment view count for a video
  Future<void> incrementViewCount(String videoId) async {
    try {
      await _videosCollection.doc(videoId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  // Rate a video
  Future<void> rateVideo(String videoId, double rating, String userId) async {
    try {
      final feedbackRef = _videosCollection.doc(videoId).collection('feedback').doc(userId);
      await feedbackRef.set({
        'rating': rating,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _updateVideoAverageRating(videoId);
    } catch (e) {
      print('Error rating video: $e');
      throw e;
    }
  }

  // Upload a video file
  Future<String> uploadVideoFile(String filePath, String fileName) async {
    try {
      final ref = _storage.ref('videos/$fileName');
      final uploadTask = await ref.putFile(File(filePath));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading video file: $e');
      throw e;
    }
  }

  // Upload a thumbnail image
  Future<String> uploadThumbnail(String filePath, String fileName) async {
    try {
      final ref = _storage.ref('thumbnails/$fileName');
      final uploadTask = await ref.putFile(File(filePath));
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading thumbnail: $e');
      throw e;
    }
  }

  // Get all videos uploaded by a specific user
  Future<List<Video>> getVideosByUploader(String uploaderId) async {
    try {
      final querySnapshot = await _videosCollection
          .where('uploadedBy', isEqualTo: uploaderId)
          .where('isActive', isEqualTo: true)
          .get();
      return querySnapshot.docs.map((doc) => Video.fromDocument(doc)).toList();
    } catch (e) {
      print('Error getting videos by uploader: $e');
      return [];
    }
  }

  // Get statistics for a specific video
  Future<Map<String, dynamic>> getVideoStatistics(String videoId) async {
    try {
      final doc = await _videosCollection.doc(videoId).get();
      if (!doc.exists) return {};

      final feedbackSnapshot = await _videosCollection.doc(videoId).collection('feedback').get();
      return {
        'viewCount': doc.get('viewCount') ?? 0,
        'ratingCount': doc.get('ratingCount') ?? 0,
        'averageRating': doc.get('averageRating') ?? 0.0,
        'feedbackCount': feedbackSnapshot.size,
      };
    } catch (e) {
      print('Error getting video statistics: $e');
      return {};
    }
  }

  // Get a specific user's feedback for a video
  Future<Feedback?> getUserFeedback(String videoId, String userId) async {
    try {
      final docSnapshot = await _videosCollection.doc(videoId).collection('feedback').doc(userId).get();
      if (docSnapshot.exists) {
        return Feedback.fromDocument(docSnapshot);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user feedback: $e');
      return null;
    }
  }

  // Submit or update feedback (rating + comment)
  Future<void> submitFeedback({
    required String videoId,
    required String userId,
    required double rating,
    required String comment,
  }) async {
    final feedbackRef = _videosCollection.doc(videoId).collection('feedback').doc(userId);

    final newFeedback = Feedback(
      id: userId, // Use userId as the document ID for feedback
      userId: userId,
      type: 'video_rating',
      title: 'Video Rating',
      content: comment,
      rating: rating,
      relatedItemId: videoId,
      status: 'reviewed',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await feedbackRef.set(newFeedback.toMap(), SetOptions(merge: true));

    // After submitting, we must recalculate the video's average rating
    await _updateVideoAverageRating(videoId);
  }

  // Helper to update the average rating on the video document
  Future<void> _updateVideoAverageRating(String videoId) async {
    final feedbackQuery = await _videosCollection.doc(videoId).collection('feedback').get();

    if (feedbackQuery.docs.isEmpty) {
      await _videosCollection.doc(videoId).update({
        'averageRating': 0.0,
        'ratingCount': 0,
      });
      return;
    }

    double totalRating = 0;
    for (var doc in feedbackQuery.docs) {
      totalRating += (doc.data()['rating'] as num? ?? 0.0).toDouble();
    }
    double average = totalRating / feedbackQuery.docs.length;

    await _videosCollection.doc(videoId).update({
      'averageRating': average,
      'ratingCount': feedbackQuery.docs.length,
    });
  }
}

class VideoStatistics {
  final int totalVideos;
  final int totalViews;
  final double averageViewsPerVideo;
  final Map<String, int> videosByCategory;
  final Map<String, int> videosByLevel;

  VideoStatistics({
    required this.totalVideos,
    required this.totalViews,
    required this.averageViewsPerVideo,
    required this.videosByCategory,
    required this.videosByLevel,
  });
}
