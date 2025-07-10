import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/video_info_widget.dart';
import './widgets/video_player_widget.dart';
import './widgets/video_tabs_widget.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({Key? key}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isFullScreen = false;
  bool _isControlsVisible = true;
  double _currentRating = 0.0;
  bool _hasRated = false;

  // Mock video data
  final Map<String, dynamic> videoData = {
    "id": 1,
    "title": "Advanced English Grammar: Mastering Complex Sentences",
    "description":
        """Learn the fundamentals of complex sentence structures in English. This comprehensive lesson covers subordinate clauses, relative pronouns, and advanced grammatical patterns that will elevate your writing and speaking skills.

In this detailed tutorial, you'll discover:
• How to construct complex sentences with multiple clauses
• Proper use of relative pronouns (who, which, that, whose)
• Advanced punctuation rules for complex structures
• Common mistakes to avoid in formal writing
• Practice exercises with real-world examples

Perfect for intermediate to advanced English learners preparing for academic writing, professional communication, or standardized tests like TOEFL and IELTS.""",
    "instructor": {
      "name": "Dr. Sarah Mitchell",
      "title": "Professor of Linguistics",
      "avatar":
          "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face",
      "experience": "15+ years teaching experience"
    },
    "duration": "24:35",
    "views": "12,847",
    "likes": 1247,
    "rating": 4.8,
    "totalRatings": 324,
    "uploadDate": "2025-01-05",
    "videoUrl":
        "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4",
    "thumbnail":
        "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&h=450&fit=crop"
  };

  final List<Map<String, dynamic>> comments = [
    {
      "id": 1,
      "user": {
        "name": "Alex Johnson",
        "avatar":
            "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=50&h=50&fit=crop&crop=face"
      },
      "content":
          "This lesson really helped me understand complex sentences! The examples were perfect.",
      "timestamp": "2 hours ago",
      "likes": 23,
      "replies": [
        {
          "id": 11,
          "user": {
            "name": "Maria Garcia",
            "avatar":
                "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=50&h=50&fit=crop&crop=face"
          },
          "content": "I agree! Dr. Mitchell explains everything so clearly.",
          "timestamp": "1 hour ago",
          "likes": 8
        }
      ]
    },
    {
      "id": 2,
      "user": {
        "name": "David Chen",
        "avatar":
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=50&h=50&fit=crop&crop=face"
      },
      "content":
          "Could you make a follow-up video about advanced punctuation rules?",
      "timestamp": "5 hours ago",
      "likes": 15,
      "replies": []
    },
    {
      "id": 3,
      "user": {
        "name": "Emma Wilson",
        "avatar":
            "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=50&h=50&fit=crop&crop=face"
      },
      "content":
          "Perfect timing! I have my IELTS exam next month and this is exactly what I needed to review.",
      "timestamp": "1 day ago",
      "likes": 31,
      "replies": []
    }
  ];

  final List<Map<String, dynamic>> relatedVideos = [
    {
      "id": 2,
      "title": "English Pronunciation: Mastering Difficult Sounds",
      "instructor": "Prof. James Rodriguez",
      "duration": "18:42",
      "views": "8,234",
      "rating": 4.7,
      "thumbnail":
          "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=300&h=200&fit=crop"
    },
    {
      "id": 3,
      "title": "Academic Writing: Essay Structure and Flow",
      "instructor": "Dr. Lisa Thompson",
      "duration": "32:15",
      "views": "15,692",
      "rating": 4.9,
      "thumbnail":
          "https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=300&h=200&fit=crop"
    },
    {
      "id": 4,
      "title": "Business English: Professional Communication",
      "instructor": "Michael Brown",
      "duration": "27:08",
      "views": "9,876",
      "rating": 4.6,
      "thumbnail":
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=200&fit=crop"
    }
  ];

  final List<Map<String, dynamic>> transcript = [
    {
      "timestamp": "00:00",
      "text":
          "Welcome to today's lesson on advanced English grammar. I'm Dr. Sarah Mitchell, and today we'll be exploring complex sentence structures."
    },
    {
      "timestamp": "00:15",
      "text":
          "Complex sentences are essential for academic writing and professional communication. They allow us to express sophisticated ideas clearly and concisely."
    },
    {
      "timestamp": "00:35",
      "text":
          "Let's start with the basic definition. A complex sentence contains one independent clause and at least one dependent clause."
    },
    {
      "timestamp": "00:52",
      "text":
          "The independent clause can stand alone as a complete sentence, while the dependent clause cannot."
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  void _submitRating(double rating) {
    setState(() {
      _currentRating = rating;
      _hasRated = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for rating this video!'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: _isFullScreen ? _buildFullScreenPlayer() : _buildPortraitLayout(),
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
                videoData: videoData,
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
                      color: Colors.black.withValues(alpha: 0.5),
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
                    'Video Player',
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
                    videoData: videoData,
                    isFullScreen: false,
                    onFullScreenToggle: _toggleFullScreen,
                    showControls: true,
                  ),

                  // Video Info
                  VideoInfoWidget(
                    videoData: videoData,
                    currentRating: _currentRating,
                    hasRated: _hasRated,
                    onRatingSubmit: _submitRating,
                  ),

                  // Tabs Section
                  VideoTabsWidget(
                    tabController: _tabController,
                    comments: comments,
                    relatedVideos: relatedVideos,
                    transcript: transcript,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
