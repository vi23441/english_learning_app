import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/video_card_widget.dart';

class VideoLibraryScreen extends StatefulWidget {
  const VideoLibraryScreen({Key? key}) : super(key: key);

  @override
  State<VideoLibraryScreen> createState() => _VideoLibraryScreenState();
}

class _VideoLibraryScreenState extends State<VideoLibraryScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  bool _isSearching = false;
  List<String> _activeFilters = ['All Videos'];
  String _searchQuery = '';

  // Mock video data
  final List<Map<String, dynamic>> _allVideos = [
    {
      "id": 1,
      "title": "Introduction to English Grammar",
      "thumbnail":
          "https://images.pexels.com/photos/4144923/pexels-photo-4144923.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "duration": "15:30",
      "difficulty": "Beginner",
      "category": "Grammar",
      "isCompleted": true,
      "isFavorite": false,
      "isDownloaded": false,
      "instructor": "Sarah Johnson",
      "views": "12.5K",
      "rating": 4.8,
      "description":
          "Learn the fundamentals of English grammar with practical examples and exercises.",
    },
    {
      "id": 2,
      "title": "Advanced Vocabulary Building",
      "thumbnail":
          "https://images.pixabay.com/photo/2016/03/26/13/09/workspace-1280538_1280.jpg",
      "duration": "22:45",
      "difficulty": "Advanced",
      "category": "Vocabulary",
      "isCompleted": false,
      "isFavorite": true,
      "isDownloaded": true,
      "instructor": "Michael Chen",
      "views": "8.2K",
      "rating": 4.9,
      "description":
          "Expand your vocabulary with advanced words and phrases for professional communication.",
    },
    {
      "id": 3,
      "title": "Pronunciation Mastery",
      "thumbnail":
          "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80",
      "duration": "18:20",
      "difficulty": "Intermediate",
      "category": "Speaking",
      "isCompleted": false,
      "isFavorite": false,
      "isDownloaded": false,
      "instructor": "Emma Wilson",
      "views": "15.7K",
      "rating": 4.7,
      "description":
          "Perfect your English pronunciation with phonetic exercises and speaking practice.",
    },
    {
      "id": 4,
      "title": "Business English Essentials",
      "thumbnail":
          "https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "duration": "25:10",
      "difficulty": "Intermediate",
      "category": "Business",
      "isCompleted": true,
      "isFavorite": true,
      "isDownloaded": false,
      "instructor": "David Rodriguez",
      "views": "9.8K",
      "rating": 4.6,
      "description":
          "Master professional English communication for workplace success.",
    },
    {
      "id": 5,
      "title": "Reading Comprehension Skills",
      "thumbnail":
          "https://images.pixabay.com/photo/2015/09/05/07/28/writing-923882_1280.jpg",
      "duration": "20:15",
      "difficulty": "Beginner",
      "category": "Reading",
      "isCompleted": false,
      "isFavorite": false,
      "isDownloaded": true,
      "instructor": "Lisa Thompson",
      "views": "11.3K",
      "rating": 4.5,
      "description":
          "Improve your reading skills with comprehension strategies and practice exercises.",
    },
    {
      "id": 6,
      "title": "Writing Techniques & Style",
      "thumbnail":
          "https://images.unsplash.com/photo-1455390582262-044cdead277a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1073&q=80",
      "duration": "28:30",
      "difficulty": "Advanced",
      "category": "Writing",
      "isCompleted": false,
      "isFavorite": false,
      "isDownloaded": false,
      "instructor": "Robert Kim",
      "views": "7.1K",
      "rating": 4.8,
      "description":
          "Develop advanced writing skills with professional techniques and style guides.",
    },
    {
      "id": 7,
      "title": "Listening Skills Development",
      "thumbnail":
          "https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "duration": "16:45",
      "difficulty": "Intermediate",
      "category": "Listening",
      "isCompleted": true,
      "isFavorite": false,
      "isDownloaded": false,
      "instructor": "Anna Martinez",
      "views": "13.2K",
      "rating": 4.7,
      "description":
          "Enhance your listening comprehension with audio exercises and practice sessions.",
    },
    {
      "id": 8,
      "title": "IELTS Preparation Course",
      "thumbnail":
          "https://images.pixabay.com/photo/2017/05/12/08/29/coffee-2306471_1280.jpg",
      "duration": "35:20",
      "difficulty": "Advanced",
      "category": "Test Prep",
      "isCompleted": false,
      "isFavorite": true,
      "isDownloaded": true,
      "instructor": "James Parker",
      "views": "18.9K",
      "rating": 4.9,
      "description":
          "Comprehensive IELTS preparation with practice tests and expert strategies.",
    },
  ];

  List<Map<String, dynamic>> _filteredVideos = [];

  final List<String> _categories = [
    'All Videos',
    'Grammar',
    'Vocabulary',
    'Speaking',
    'Business',
    'Reading',
    'Writing',
    'Listening',
    'Test Prep'
  ];

  @override
  void initState() {
    super.initState();
    _filteredVideos = List.from(_allVideos);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreVideos();
    }
  }

  void _loadMoreVideos() {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      // Simulate loading delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  void _filterVideos() {
    setState(() {
      _filteredVideos = _allVideos.where((video) {
        bool matchesSearch = _searchQuery.isEmpty ||
            (video['title'] as String)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (video['category'] as String)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (video['instructor'] as String)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());

        bool matchesFilter = _activeFilters.contains('All Videos') ||
            _activeFilters.contains(video['category'] as String);

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (filter == 'All Videos') {
        _activeFilters = ['All Videos'];
      } else {
        _activeFilters.remove('All Videos');
        if (_activeFilters.contains(filter)) {
          _activeFilters.remove(filter);
        } else {
          _activeFilters.add(filter);
        }
        if (_activeFilters.isEmpty) {
          _activeFilters = ['All Videos'];
        }
      }
    });
    _filterVideos();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterVideos();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        categories: _categories,
        activeFilters: _activeFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _activeFilters = filters;
          });
          _filterVideos();
        },
      ),
    );
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _filteredVideos = List.from(_allVideos);
    });
  }

  void _onVideoTap(Map<String, dynamic> video) {
    Navigator.pushNamed(
      context,
      '/video-player-screen',
      arguments: video,
    );
  }

  void _onVideoLongPress(Map<String, dynamic> video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              video['title'] as String,
              style: AppTheme.lightTheme.textTheme.titleMedium,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            _buildQuickActionTile(
              icon: 'favorite',
              title: video['isFavorite'] == true
                  ? 'Remove from Favorites'
                  : 'Add to Favorites',
              onTap: () {
                Navigator.pop(context);
                // Handle favorite toggle
              },
            ),
            _buildQuickActionTile(
              icon: 'download',
              title: video['isDownloaded'] == true
                  ? 'Remove Download'
                  : 'Download for Offline',
              onTap: () {
                Navigator.pop(context);
                // Handle download toggle
              },
            ),
            _buildQuickActionTile(
              icon: 'share',
              title: 'Share Video',
              onTap: () {
                Navigator.pop(context);
                // Handle share
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search videos...',
                  border: InputBorder.none,
                  hintStyle: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                style: AppTheme.lightTheme.textTheme.bodyLarge,
                onChanged: _onSearchChanged,
              )
            : Text(
                'Video Library',
                style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
              ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                  _filterVideos();
                }
              });
            },
            icon: CustomIconWidget(
              iconName: _isSearching ? 'close' : 'search',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter chips
            if (_activeFilters.isNotEmpty &&
                !_activeFilters.contains('All Videos'))
              Container(
                height: 6.h,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _activeFilters.length,
                  itemBuilder: (context, index) {
                    final filter = _activeFilters[index];
                    if (filter == 'All Videos') return const SizedBox.shrink();

                    return Padding(
                      padding: EdgeInsets.only(right: 2.w),
                      child: FilterChipWidget(
                        label: filter,
                        isSelected: true,
                        count: _allVideos
                            .where((video) => video['category'] == filter)
                            .length,
                        onTap: () => _toggleFilter(filter),
                      ),
                    );
                  },
                ),
              ),

            // Video grid
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.lightTheme.colorScheme.primary,
                child: _filteredVideos.isEmpty
                    ? _buildEmptyState()
                    : GridView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(4.w),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? 2
                              : 1,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 3.w,
                          mainAxisSpacing: 3.w,
                        ),
                        itemCount:
                            _filteredVideos.length + (_isLoading ? 2 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _filteredVideos.length) {
                            return _buildSkeletonCard();
                          }

                          final video = _filteredVideos[index];
                          return VideoCardWidget(
                            video: video,
                            onTap: () => _onVideoTap(video),
                            onLongPress: () => _onVideoLongPress(video),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Videos tab active
        backgroundColor:
            AppTheme.lightTheme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor:
            AppTheme.lightTheme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
            AppTheme.lightTheme.bottomNavigationBarTheme.unselectedItemColor,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: AppTheme
                  .lightTheme.bottomNavigationBarTheme.unselectedItemColor!,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'home',
              color: AppTheme
                  .lightTheme.bottomNavigationBarTheme.selectedItemColor!,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'play_circle_filled',
              color: AppTheme
                  .lightTheme.bottomNavigationBarTheme.selectedItemColor!,
              size: 24,
            ),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'quiz',
              color: AppTheme
                  .lightTheme.bottomNavigationBarTheme.unselectedItemColor!,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'quiz',
              color: AppTheme
                  .lightTheme.bottomNavigationBarTheme.selectedItemColor!,
              size: 24,
            ),
            label: 'Tests',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: AppTheme
                  .lightTheme.bottomNavigationBarTheme.unselectedItemColor!,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'person',
              color: AppTheme
                  .lightTheme.bottomNavigationBarTheme.selectedItemColor!,
              size: 24,
            ),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/dashboard-home-screen');
              break;
            case 1:
              // Already on Videos screen
              break;
            case 2:
              // Navigate to Tests screen (not implemented)
              break;
            case 3:
              // Navigate to Profile screen (not implemented)
              break;
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'video_library',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'No videos found',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Try adjusting your search or filters',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _activeFilters = ['All Videos'];
                _searchQuery = '';
                _searchController.clear();
                _isSearching = false;
              });
              _filterVideos();
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.getElevationShadow(isLight: true, elevation: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1.5.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                      color: AppTheme
                          .lightTheme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Container(
                    height: 1.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: AppTheme
                          .lightTheme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
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
