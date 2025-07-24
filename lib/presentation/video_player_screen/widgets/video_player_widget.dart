import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import '../../../core/app_export.dart';
import '../../../models/video.dart';

class VideoPlayerWidget extends StatefulWidget {
  final Video video;
  final bool isFullScreen;
  final VoidCallback onFullScreenToggle;
  final bool showControls;

  const VideoPlayerWidget({
    Key? key,
    required this.video,
    required this.isFullScreen,
    required this.onFullScreenToggle,
    required this.showControls,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;
  double _volume = 0.7;
  bool _showVolumeSlider = false;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl));
      await _controller!.initialize();
      
      _controller!.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller!.value.isPlaying;
            _isBuffering = _controller!.value.isBuffering;
          });
        }
      });
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing video player: $e');
    }
  }

  void _togglePlayPause() {
    if (_controller != null && _isInitialized) {
      setState(() {
        if (_isPlaying) {
          _controller!.pause();
        } else {
          _controller!.play();
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.isFullScreen ? 100.w : 100.w,
      height: widget.isFullScreen ? 100.h : 56.25.w, // 16:9 aspect ratio
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: widget.isFullScreen ? null : BorderRadius.circular(12),
      ),
      child: _isInitialized && _controller != null
          ? Stack(
              children: [
                // Video Player
                ClipRRect(
                  borderRadius: widget.isFullScreen ? BorderRadius.zero : BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                ),

                // Loading/Buffering Indicator
                if (_isBuffering)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),

                // Play/Pause Overlay
                if (widget.showControls)
                  Center(
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        padding: EdgeInsets.all(widget.isFullScreen ? 4.w : 3.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: _isPlaying ? 'pause' : 'play_arrow',
                          color: Colors.white,
                          size: widget.isFullScreen ? 12.w : 8.w,
                        ),
                      ),
                    ),
                  ),

                // Bottom Controls
                if (widget.showControls)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(widget.isFullScreen ? 3.w : 2.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: widget.isFullScreen 
                            ? null 
                            : const BorderRadius.vertical(bottom: Radius.circular(12)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Progress Slider
                          VideoProgressIndicator(
                            _controller!,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: AppTheme.lightTheme.colorScheme.primary,
                              backgroundColor: Colors.white.withValues(alpha: 0.3),
                              bufferedColor: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          
                          SizedBox(height: 1.h),
                          
                          // Control Buttons Row
                          Row(
                            children: [
                              // Current Time
                              Text(
                                _formatDuration(_controller!.value.position),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: widget.isFullScreen ? 14.sp : 12.sp,
                                ),
                              ),
                              
                              const Spacer(),
                              
                              // Volume Control
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showVolumeSlider = !_showVolumeSlider;
                                  });
                                },
                                child: CustomIconWidget(
                                  iconName: _volume > 0 ? 'volume_up' : 'volume_off',
                                  color: Colors.white,
                                  size: widget.isFullScreen ? 6.w : 5.w,
                                ),
                              ),
                              
                              SizedBox(width: 3.w),
                              
                              // Fullscreen Toggle
                              GestureDetector(
                                onTap: widget.onFullScreenToggle,
                                child: CustomIconWidget(
                                  iconName: widget.isFullScreen ? 'fullscreen_exit' : 'fullscreen',
                                  color: Colors.white,
                                  size: widget.isFullScreen ? 6.w : 5.w,
                                ),
                              ),
                              
                              SizedBox(width: 2.w),
                              
                              // Total Duration
                              Text(
                                _formatDuration(_controller!.value.duration),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: widget.isFullScreen ? 14.sp : 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Volume Slider
                if (_showVolumeSlider && widget.showControls)
                  Positioned(
                    right: widget.isFullScreen ? 15.w : 12.w,
                    bottom: widget.isFullScreen ? 15.h : 12.h,
                    child: Container(
                      height: 30.h,
                      width: 8.w,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: Slider(
                          value: _volume,
                          onChanged: (value) {
                            setState(() {
                              _volume = value;
                              _controller?.setVolume(value);
                            });
                          },
                          activeColor: AppTheme.lightTheme.colorScheme.primary,
                          inactiveColor: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : Stack(
              children: [
                // Thumbnail while loading
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: widget.isFullScreen ? null : BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(widget.video.thumbnailUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                // Loading indicator
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
    );
  }
}
