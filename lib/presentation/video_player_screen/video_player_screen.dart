import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../core/app_export.dart';
import '../../models/feedback.dart';
import '../../models/video.dart';
import '../../services/video_service.dart';
import './widgets/video_player_widget.dart';
import './widgets/video_tabs_widget.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const VideoPlayerScreen({
    Key? key,
    required this.videoId,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isFullScreen = false;
  bool _isControlsVisible = true;

  // Updated state for feedback
  double _currentRating = 0.0;
  String _currentComment = '';
  final _commentController = TextEditingController();
  bool _hasRated = false;

  Video? _video;
  bool _isLoading = true;
  String? _error;

  final VideoService _videoService = VideoService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final video = await _videoService.getVideoById(widget.videoId);
      if (video != null) {
        // Increment view count
        _videoService.incrementViewCount(widget.videoId);

        // Check if user has rated this video
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final feedback = await _videoService.getUserFeedback(widget.videoId, user.uid);
          if (mounted) {
            setState(() {
              if (feedback != null) {
                _hasRated = true;
                _currentRating = feedback.rating ?? 0.0;
                _currentComment = feedback.comment;
                _commentController.text = feedback.comment;
              } else {
                _hasRated = false;
                _currentRating = 0.0;
                _currentComment = '';
              }
            });
          }
        }

        if (mounted) {
          setState(() {
            _video = video;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Video not found';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load video: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose(); // Dispose controller
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  void _showRatingDialog() {
    double dialogRating = _currentRating;
    _commentController.text = _currentComment;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_hasRated ? 'Edit Your Review' : 'Rate this Video'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Tell us what you think!'),
                    SizedBox(height: 2.h),
                    RatingBar.builder(
                      initialRating: dialogRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          dialogRating = rating;
                        });
                      },
                    ),
                    SizedBox(height: 3.h),
                    TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Write a review',
                        hintText: 'Describe your experience (optional)',
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitFeedback(dialogRating, _commentController.text);
              },
              child: Text('SUBMIT'),
            ),
          ],
        );
      },
    );
  }

  void _submitFeedback(double rating, String comment) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a review.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submitting review...')),
    );

    try {
      await _videoService.submitFeedback(
        videoId: widget.videoId,
        userId: user.uid,
        rating: rating,
        comment: comment,
      );

      await _loadVideo();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thank you for your review!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 20.w,
                        color: AppTheme.lightTheme.colorScheme.error,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _error!,
                        style: AppTheme.lightTheme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.h),
                      ElevatedButton(
                        onPressed: _loadVideo,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _video == null
                  ? const Center(child: Text('Video not found'))
                  : _isFullScreen
                      ? _buildFullScreenPlayer()
                      : _buildPortraitLayout(),
    );
  }

  Widget _buildFullScreenPlayer() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isControlsVisible = !_isControlsVisible;
        });
      },
      child: Container(
        width: 100.w,
        height: 100.h,
        color: Colors.black,
        child: Stack(
          children: [
            Center(
              child: VideoPlayerWidget(
                video: _video!,
                isFullScreen: true,
                onFullScreenToggle: _toggleFullScreen,
                showControls: _isControlsVisible,
              ),
            ),
            if (_isControlsVisible)
              Positioned(
                top: 4.h,
                left: 4.w,
                child: GestureDetector(
                  onTap: _toggleFullScreen,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'fullscreen_exit',
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return SafeArea(
      child: Column(
        children: [
          // App Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              boxShadow:
                  AppTheme.getElevationShadow(isLight: true, elevation: 1),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    _video?.title ?? 'Loading...',
                    style: AppTheme.lightTheme.textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Share functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Share functionality coming soon!')),
                    );
                  },
                  child: CustomIconWidget(
                    iconName: 'share',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 6.w,
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Player
                  VideoPlayerWidget(
                    video: _video!,
                    isFullScreen: false,
                    onFullScreenToggle: _toggleFullScreen,
                    showControls: true,
                  ),

                  // --- REPLACEMENT for VideoInfoWidget ---
                  _buildVideoInfoSection(),

                  // Tabs Section
                  VideoTabsWidget(
                    tabController: _tabController,
                    video: _video!,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInfoSection() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _video!.title,
            style: AppTheme.lightTheme.textTheme.headlineSmall,
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Text(
                '${_video!.viewCount} views',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(width: 4.w),
              Icon(Icons.star, color: Colors.amber, size: 4.w),
              SizedBox(width: 1.w),
              Text(
                _video!.averageRating.toStringAsFixed(1),
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            _video!.description,
            style: AppTheme.lightTheme.textTheme.bodyLarge,
          ),
          SizedBox(height: 3.h),
          Divider(),
          SizedBox(height: 2.h),
          // Rating section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasRated ? 'Your Review' : 'Rate this video',
                      style: AppTheme.lightTheme.textTheme.titleMedium,
                    ),
                    if (_hasRated) ...[
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: _currentRating,
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 5.w,
                            direction: Axis.horizontal,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            _currentRating.toStringAsFixed(1),
                            style: AppTheme.lightTheme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      if (_currentComment.isNotEmpty) ...[
                        SizedBox(height: 1.h),
                        Text(
                          _currentComment,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ]
                    ]
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showRatingDialog,
                icon:
                    Icon(_hasRated ? Icons.edit : Icons.star_border, size: 4.w),
                label: Text(_hasRated ? 'Edit' : 'Rate'),
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Divider(),
        ],
      ),
    );
  }
}
