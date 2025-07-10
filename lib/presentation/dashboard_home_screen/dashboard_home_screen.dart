import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/feature_tile_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/recent_activity_card_widget.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  int _currentIndex = 0;
  bool _isRefreshing = false;

  // Mock user data
  final Map<String, dynamic> userData = {
    "name": "Sarah Johnson",
    "streak": 7,
    "totalVideosWatched": 24,
    "wordsLearned": 156,
    "testsCompleted": 8,
    "currentLevel": "Intermediate"
  };

  // Mock recent activity data
  final List<Map<String, dynamic>> recentActivities = [
    {
      "type": "video",
      "title": "Advanced Grammar Structures",
      "thumbnail":
          "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "progress": 0.65,
      "duration": "12 min left"
    },
    {
      "type": "vocabulary",
      "title": "Business English Terms",
      "thumbnail":
          "https://images.pexels.com/photos/267507/pexels-photo-267507.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "progress": 0.80,
      "duration": "8 words to go"
    },
    {
      "type": "test",
      "title": "Listening Comprehension",
      "thumbnail":
          "https://images.pixabay.com/photo/2017/07/31/11/21/people-2557396_1280.jpg",
      "progress": 0.0,
      "duration": "Starts tomorrow"
    }
  ];

  // Mock feature tiles data
  final List<Map<String, dynamic>> featureTiles = [
    {
      "title": "Videos",
      "icon": "play_circle_filled",
      "route": "/video-library-screen",
      "stats": "24 watched",
      "progress": 0.75,
      "color": Color(0xFF2563EB)
    },
    {
      "title": "Vocabulary",
      "icon": "book",
      "route": "/vocabulary-screen",
      "stats": "156 learned",
      "progress": 0.60,
      "color": Color(0xFF7C3AED)
    },
    {
      "title": "Tests",
      "icon": "quiz",
      "route": "/tests-screen",
      "stats": "8 completed",
      "progress": 0.40,
      "color": Color(0xFF059669)
    },
    {
      "title": "Profile",
      "icon": "person",
      "route": "/profile-screen",
      "stats": "Level: Intermediate",
      "progress": 0.85,
      "color": Color(0xFFD97706)
    }
  ];

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/video-library-screen');
        break;
      case 2:
        Navigator.pushNamed(context, '/tests-screen');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile-screen');
        break;
    }
  }

  void _continueLearning() {
    // Navigate to last activity (mock: video player)
    Navigator.pushNamed(context, '/video-player-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: CustomIconWidget(
              iconName: 'menu',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to notifications
            },
            icon: CustomIconWidget(
              iconName: 'notifications_outlined',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.lightTheme.colorScheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),
              GreetingHeaderWidget(
                userName: userData["name"] as String,
                streak: userData["streak"] as int,
                currentLevel: userData["currentLevel"] as String,
              ),
              SizedBox(height: 3.h),
              _buildSectionHeader("Recent Activity"),
              SizedBox(height: 1.5.h),
              _buildRecentActivitySection(),
              SizedBox(height: 3.h),
              _buildSectionHeader("Learning Hub"),
              SizedBox(height: 1.5.h),
              _buildFeatureTilesGrid(),
              SizedBox(height: 3.h),
              _buildQuickStatsSection(),
              SizedBox(height: 10.h), // Bottom padding for FAB
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 8.w,
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    child: Text(
                      (userData["name"] as String)
                          .split(' ')
                          .map((e) => e[0])
                          .join(),
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    userData["name"] as String,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    userData["currentLevel"] as String,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                children: [
                  _buildDrawerItem('settings', 'Settings', () {}),
                  _buildDrawerItem('help_outline', 'Help & Support', () {}),
                  _buildDrawerItem('feedback', 'Send Feedback', () {}),
                  _buildDrawerItem('info_outline', 'About', () {}),
                  const Divider(),
                  _buildDrawerItem('logout', 'Logout', () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login-screen',
                      (route) => false,
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String iconName, String title, VoidCallback onTap) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: AppTheme.lightTheme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return SizedBox(
      height: 20.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentActivities.length,
        itemBuilder: (context, index) {
          final activity = recentActivities[index];
          return Padding(
            padding: EdgeInsets.only(right: 3.w),
            child: RecentActivityCardWidget(
              title: activity["title"] as String,
              thumbnail: activity["thumbnail"] as String,
              progress: activity["progress"] as double,
              duration: activity["duration"] as String,
              type: activity["type"] as String,
              onTap: () {
                if (activity["type"] == "video") {
                  Navigator.pushNamed(context, '/video-player-screen');
                } else if (activity["type"] == "vocabulary") {
                  Navigator.pushNamed(context, '/vocabulary-screen');
                } else if (activity["type"] == "test") {
                  Navigator.pushNamed(context, '/tests-screen');
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureTilesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 1.1,
      ),
      itemCount: featureTiles.length,
      itemBuilder: (context, index) {
        final tile = featureTiles[index];
        return FeatureTileWidget(
          title: tile["title"] as String,
          iconName: tile["icon"] as String,
          stats: tile["stats"] as String,
          progress: tile["progress"] as double,
          color: tile["color"] as Color,
          onTap: () {
            Navigator.pushNamed(context, tile["route"] as String);
          },
          onLongPress: () {
            _showQuickActions(tile["title"] as String);
          },
        );
      },
    );
  }

  Widget _buildQuickStatsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.getElevationShadow(isLight: true, elevation: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Progress",
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "Videos Watched",
                  userData["totalVideosWatched"].toString(),
                  'play_circle_filled',
                  AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildStatItem(
                  "Words Learned",
                  userData["wordsLearned"].toString(),
                  'book',
                  AppTheme.lightTheme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  "Tests Completed",
                  userData["testsCompleted"].toString(),
                  'quiz',
                  AppTheme.lightTheme.colorScheme.tertiary,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildStatItem(
                  "Current Streak",
                  "${userData["streak"]} days",
                  'local_fire_department',
                  AppTheme.warningLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, String iconName, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onBottomNavTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor:
          AppTheme.lightTheme.bottomNavigationBarTheme.backgroundColor,
      selectedItemColor:
          AppTheme.lightTheme.bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor:
          AppTheme.lightTheme.bottomNavigationBarTheme.unselectedItemColor,
      selectedLabelStyle:
          AppTheme.lightTheme.bottomNavigationBarTheme.selectedLabelStyle,
      unselectedLabelStyle:
          AppTheme.lightTheme.bottomNavigationBarTheme.unselectedLabelStyle,
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'home',
            color: _currentIndex == 0
                ? AppTheme
                    .lightTheme.bottomNavigationBarTheme.selectedItemColor!
                : AppTheme
                    .lightTheme.bottomNavigationBarTheme.unselectedItemColor!,
            size: 24,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'play_circle_filled',
            color: _currentIndex == 1
                ? AppTheme
                    .lightTheme.bottomNavigationBarTheme.selectedItemColor!
                : AppTheme
                    .lightTheme.bottomNavigationBarTheme.unselectedItemColor!,
            size: 24,
          ),
          label: 'Videos',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'quiz',
            color: _currentIndex == 2
                ? AppTheme
                    .lightTheme.bottomNavigationBarTheme.selectedItemColor!
                : AppTheme
                    .lightTheme.bottomNavigationBarTheme.unselectedItemColor!,
            size: 24,
          ),
          label: 'Tests',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'person',
            color: _currentIndex == 3
                ? AppTheme
                    .lightTheme.bottomNavigationBarTheme.selectedItemColor!
                : AppTheme
                    .lightTheme.bottomNavigationBarTheme.unselectedItemColor!,
            size: 24,
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: FloatingActionButton.extended(
        onPressed: _continueLearning,
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: CustomIconWidget(
          iconName: 'play_arrow',
          color: Colors.white,
          size: 24,
        ),
        label: Text(
          'Continue Learning',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showQuickActions(String featureTitle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$featureTitle Quick Actions',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'trending_up',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('View Progress'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to progress screen
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'bookmark',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 24,
              ),
              title: const Text('View Bookmarks'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to bookmarks
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'history',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 24,
              ),
              title: const Text('View History'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to history
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
