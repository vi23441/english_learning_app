import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/video.dart';
import '../services/video_service.dart';

class VideoProvider extends ChangeNotifier {
  final VideoService _videoService = VideoService();
  
  List<Video> _videos = [];
  List<Video> _popularVideos = [];
  List<Video> _recentVideos = [];
  List<Video> _topRatedVideos = [];
  List<Video> _searchResults = [];
  
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Video> get videos => _videos;
  List<Video> get popularVideos => _popularVideos;
  List<Video> get recentVideos => _recentVideos;
  List<Video> get topRatedVideos => _topRatedVideos;
  List<Video> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all videos
  Future<void> loadVideos() async {
    try {
      _setLoading(true);
      _clearError();
      
      _videos = await _videoService.getAllVideos();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load videos by category
  Future<void> loadVideosByCategory(String category) async {
    try {
      _setLoading(true);
      _clearError();
      
      _videos = await _videoService.getVideosByCategory(category);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load videos by level
  Future<void> loadVideosByLevel(String level) async {
    try {
      _setLoading(true);
      _clearError();
      
      _videos = await _videoService.getVideosByLevel(level);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load popular videos
  Future<void> loadPopularVideos({int limit = 10}) async {
    try {
      _setLoading(true);
      _clearError();
      
      _popularVideos = await _videoService.getPopularVideos(limit: limit);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load recent videos
  Future<void> loadRecentVideos({int limit = 10}) async {
    try {
      _setLoading(true);
      _clearError();
      
      _recentVideos = await _videoService.getRecentVideos(limit: limit);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load top-rated videos
  Future<void> loadTopRatedVideos({int limit = 10}) async {
    try {
      _setLoading(true);
      _clearError();
      
      _topRatedVideos = await _videoService.getTopRatedVideos(limit: limit);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Search videos
  Future<void> searchVideos(String query) async {
    try {
      _setLoading(true);
      _clearError();
      
      _searchResults = await _videoService.searchVideos(query);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get video by ID
  Future<Video?> getVideoById(String videoId) async {
    try {
      return await _videoService.getVideoById(videoId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Add new video (Teacher/Admin only)
  Future<bool> addVideo(Video video) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _videoService.addVideo(video);
      
      // Refresh videos list
      await loadVideos();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update video (Teacher/Admin only)
  Future<bool> updateVideo(String videoId, Video video) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _videoService.updateVideo(videoId, video);
      
      // Update local video in lists
      _updateVideoInLists(videoId, video);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete video (Admin only)
  Future<bool> deleteVideo(String videoId) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _videoService.deleteVideo(videoId);
      
      // Remove video from local lists
      _removeVideoFromLists(videoId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Increment view count
  Future<void> incrementViewCount(String videoId) async {
    try {
      await _videoService.incrementViewCount(videoId);
      
      // Update local video view count
      _updateVideoViewCount(videoId);
      notifyListeners();
    } catch (e) {
      // Ignore errors for view count
    }
  }

  // Rate video
  Future<bool> rateVideo(String videoId, double rating) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _setError('User not authenticated');
        return false;
      }
      
      await _videoService.rateVideo(videoId, rating, user.uid);
      
      // Reload videos to get updated ratings
      await loadVideos();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Upload video file
  Future<String?> uploadVideoFile(String filePath, String fileName) async {
    try {
      _setLoading(true);
      _clearError();
      
      final downloadUrl = await _videoService.uploadVideoFile(filePath, fileName);
      return downloadUrl;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Upload thumbnail
  Future<String?> uploadThumbnail(String filePath, String fileName) async {
    try {
      _setLoading(true);
      _clearError();
      
      final downloadUrl = await _videoService.uploadThumbnail(filePath, fileName);
      return downloadUrl;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Get videos by uploader
  Future<List<Video>> getVideosByUploader(String uploaderId) async {
    try {
      return await _videoService.getVideosByUploader(uploaderId);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Get video statistics
  Future<Map<String, dynamic>> getVideoStatistics(String videoId) async {
    try {
      return await _videoService.getVideoStatistics(videoId);
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  // Filter videos by category
  List<Video> getVideosByCategory(String category) {
    return _videos.where((video) => video.category == category).toList();
  }

  // Filter videos by level
  List<Video> getVideosByLevel(String level) {
    return _videos.where((video) => video.level == level).toList();
  }

  // Get video categories
  List<String> getVideoCategories() {
    return _videos.map((video) => video.category).toSet().toList();
  }

  // Get video levels
  List<String> getVideoLevels() {
    return _videos.map((video) => video.level).toSet().toList();
  }

  // Private helper methods
  void _updateVideoInLists(String videoId, Video updatedVideo) {
    // Update in main videos list
    final index = _videos.indexWhere((video) => video.id == videoId);
    if (index != -1) {
      _videos[index] = updatedVideo;
    }
    
    // Update in other lists
    _updateVideoInList(_popularVideos, videoId, updatedVideo);
    _updateVideoInList(_recentVideos, videoId, updatedVideo);
    _updateVideoInList(_topRatedVideos, videoId, updatedVideo);
    _updateVideoInList(_searchResults, videoId, updatedVideo);
  }

  void _updateVideoInList(List<Video> list, String videoId, Video updatedVideo) {
    final index = list.indexWhere((video) => video.id == videoId);
    if (index != -1) {
      list[index] = updatedVideo;
    }
  }

  void _removeVideoFromLists(String videoId) {
    _videos.removeWhere((video) => video.id == videoId);
    _popularVideos.removeWhere((video) => video.id == videoId);
    _recentVideos.removeWhere((video) => video.id == videoId);
    _topRatedVideos.removeWhere((video) => video.id == videoId);
    _searchResults.removeWhere((video) => video.id == videoId);
  }

  void _updateVideoViewCount(String videoId) {
    for (final list in [_videos, _popularVideos, _recentVideos, _topRatedVideos, _searchResults]) {
      final index = list.indexWhere((video) => video.id == videoId);
      if (index != -1) {
        list[index] = list[index].copyWith(viewCount: list[index].viewCount + 1);
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void clearSearchResults() {
    _searchResults.clear();
    notifyListeners();
  }
}
