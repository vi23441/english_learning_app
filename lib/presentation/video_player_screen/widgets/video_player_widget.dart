import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VideoPlayerWidget extends StatefulWidget {
  final Map<String, dynamic> videoData;
  final bool isFullScreen;
  final VoidCallback onFullScreenToggle;
  final bool showControls;

  const VideoPlayerWidget({
    Key? key,
    required this.videoData,
    required this.isFullScreen,
    required this.onFullScreenToggle,
    required this.showControls,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  double _volume = 0.7;
  bool _showVolumeSlider = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.isFullScreen ? 100.w : 100.w,
      height: widget.isFullScreen ? 100.h : 56.25.w, // 16:9 aspect ratio
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: widget.isFullScreen ? null : BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Video Thumbnail/Player Area
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius:
                  widget.isFullScreen ? null : BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(widget.videoData["thumbnail"] ?? ""),
                fit: BoxFit.cover,
              ),
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
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: widget.isFullScreen
                      ? null
                      : BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress Bar
                    Row(
                      children: [
                        Text(
                          _formatDuration(_currentPosition),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: widget.isFullScreen ? 12.sp : 10.sp,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor:
                                  AppTheme.lightTheme.colorScheme.primary,
                              inactiveTrackColor:
                                  Colors.white.withValues(alpha: 0.3),
                              thumbColor:
                                  AppTheme.lightTheme.colorScheme.primary,
                              overlayColor: AppTheme
                                  .lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.2),
                              trackHeight: 2.0,
                              thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 6.0),
                            ),
                            child: Slider(
                              value: _currentPosition,
                              max: 100.0,
                              onChanged: (value) {
                                setState(() {
                                  _currentPosition = value;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          widget.videoData["duration"] ?? "00:00",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: widget.isFullScreen ? 12.sp : 10.sp,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 1.h),

                    // Control Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _togglePlayPause,
                              child: CustomIconWidget(
                                iconName: _isPlaying ? 'pause' : 'play_arrow',
                                color: Colors.white,
                                size: widget.isFullScreen ? 7.w : 6.w,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showVolumeSlider = !_showVolumeSlider;
                                });
                              },
                              child: CustomIconWidget(
                                iconName:
                                    _volume > 0 ? 'volume_up' : 'volume_off',
                                color: Colors.white,
                                size: widget.isFullScreen ? 6.w : 5.w,
                              ),
                            ),
                            if (_showVolumeSlider) ...[
                              SizedBox(width: 2.w),
                              Container(
                                width: 20.w,
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Colors.white,
                                    inactiveTrackColor:
                                        Colors.white.withValues(alpha: 0.3),
                                    thumbColor: Colors.white,
                                    trackHeight: 2.0,
                                    thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius: 4.0),
                                  ),
                                  child: Slider(
                                    value: _volume,
                                    onChanged: (value) {
                                      setState(() {
                                        _volume = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Settings functionality
                              },
                              child: CustomIconWidget(
                                iconName: 'settings',
                                color: Colors.white,
                                size: widget.isFullScreen ? 6.w : 5.w,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            GestureDetector(
                              onTap: widget.onFullScreenToggle,
                              child: CustomIconWidget(
                                iconName: widget.isFullScreen
                                    ? 'fullscreen_exit'
                                    : 'fullscreen',
                                color: Colors.white,
                                size: widget.isFullScreen ? 6.w : 5.w,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  String _formatDuration(double position) {
    final minutes = (position / 60).floor();
    final seconds = (position % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
