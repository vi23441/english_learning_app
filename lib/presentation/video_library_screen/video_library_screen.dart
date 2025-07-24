import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';

import '../../core/app_export.dart';
import '../../providers/video_provider.dart';
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

  List<dynamic> _allVideos = [];
  List<dynamic> _filteredVideos = [];

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVideosFromProvider();
    });
    _scrollController.addListener(_onScroll);
  }

  void _loadVideosFromProvider() {
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    setState(() {
      _allVideos = videoProvider.videos;
      _filteredVideos = List.from(_allVideos);
    });
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
        // Handle both Map and object formats
        final title = video is Map ? (video['title'] ?? '') : (video.title ?? '');
        final category = video is Map ? (video['category'] ?? '') : (video.category ?? '');
        final instructor = video is Map ? (video['instructor'] ?? '') : (video.instructor ?? '');
        
        bool matchesSearch = _searchQuery.isEmpty ||
            title.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            category.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            instructor.toString().toLowerCase().contains(_searchQuery.toLowerCase());

        bool matchesFilter = _activeFilters.contains('All Videos') ||
            _activeFilters.contains(category.toString());

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
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);
    await videoProvider.loadVideos();
    setState(() {
      _allVideos = videoProvider.videos;
      _filteredVideos = List.from(_allVideos);
    });
  }

  void _onVideoTap(dynamic video) {
    String videoId;
    if (video is Map) {
      videoId = video['id'] ?? '';
    } else {
      videoId = video.id;
    }
    
    Navigator.pushNamed(
      context,
      '/video-player-screen',
      arguments: videoId,
    );
  }

  void _onVideoLongPress(dynamic video) {
    final title = video is Map ? (video['title'] ?? '') : (video.title ?? '');
    final isFavorite = video is Map ? (video['isFavorite'] ?? false) : (video.isFavorite ?? false);
    final isDownloaded = video is Map ? (video['isDownloaded'] ?? false) : (video.isDownloaded ?? false);
    
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
              title.toString(),
              style: AppTheme.lightTheme.textTheme.titleMedium,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            _buildQuickActionTile(
              icon: 'favorite',
              title: isFavorite == true
                  ? 'Remove from Favorites'
                  : 'Add to Favorites',
              onTap: () {
                Navigator.pop(context);
                // Handle favorite toggle
              },
            ),
            _buildQuickActionTile(
              icon: 'download',
              title: isDownloaded == true
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
    return Consumer<VideoProvider>(
      builder: (context, videoProvider, child) {
        if (videoProvider.isLoading && _allVideos.isEmpty) {
          return Scaffold(
            backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
              elevation: 0,
              title: Text(
                'Video Library',
                style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
              ),
            ),
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          );
        }

        // Update videos if provider has new data
        if (videoProvider.videos.isNotEmpty && _allVideos != videoProvider.videos) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _allVideos = videoProvider.videos;
              _filteredVideos = List.from(_allVideos);
            });
          });
        }

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
                                .where((video) {
                                  final category = video is Map ? 
                                    (video['category'] ?? '') : 
                                    (video.category ?? '');
                                  return category == filter;
                                })
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
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: MediaQuery.of(context).orientation ==
                                      Orientation.portrait
                                  ? 50.w  // Max width for each card in portrait
                                  : 80.w, // Max width for each card in landscape  
                              childAspectRatio: MediaQuery.of(context).orientation ==
                                      Orientation.portrait ? 0.6 : 1.5,
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
      },
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
