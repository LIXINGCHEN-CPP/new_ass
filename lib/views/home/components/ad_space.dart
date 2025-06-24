import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../../../core/constants/constants.dart';

class AdSpace extends StatefulWidget {
  const AdSpace({super.key});

  @override
  State<AdSpace> createState() => _AdSpaceState();
}

class _AdSpaceState extends State<AdSpace> {
  // Placeholder image + video list
  final List<Map<String, dynamic>> carouselItems = const [
    {
      'type': 'image',
      'url': 'https://img.picui.cn/free/2025/06/24/6859e09510a9f.png',
      'title': 'Welcome'
    },
    {
      'type': 'video',
      'url': 'https://files.catbox.moe/39nvvn.mp4',
      'title': 'Apple'
    },
    {
      'type': 'video',
      'url': 'https://files.catbox.moe/40gmxv.mp4',
      'title': 'Vegetables'
    },
    {
      'type': 'video',
      'url': 'https://files.catbox.moe/e0epvt.mp4',
      'title': 'Fruit'
    },
    {
      'type': 'video',
      'url': 'https://files.catbox.moe/ns75a4.mp4',
      'title': 'Fruit bowl'
    },
    {
      'type': 'video',
      'url': 'https://files.catbox.moe/m27wrv.mp4',
      'title': 'Hodgepodge'
    },
  ];

  int _currentIndex = 0;
  final List<VideoPlayerController> _videoControllers = [];
  bool _allVideosLoaded = false;
  CarouselSliderController _carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _initializeAllVideoControllers();
  }

  Future<void> _initializeAllVideoControllers() async {
    try {
      // Create controllers only for video items
      final videoItems =
          carouselItems.where((item) => item['type'] == 'video').toList();

      for (var item in videoItems) {
        final controller = VideoPlayerController.network(item['url']!);
        _videoControllers.add(controller);
      }

      // Initialize all video controllers in parallel
      await Future.wait(
          _videoControllers.map((controller) => controller.initialize()));

      // Set looping for all videos
      for (var controller in _videoControllers) {
        await controller.setLooping(true);
      }

      if (mounted) {
        setState(() {
          _allVideosLoaded = true;
        });

        // Auto switch to first video when loaded
        _carouselController.nextPage();
      }
    } catch (e) {
      // Handle loading error
      if (mounted) {
        setState(() {
          _allVideosLoaded = false;
        });
      }
    }
  }

  int _getVideoControllerIndex(int carouselIndex) {
    // Calculate video controller index from carousel index
    int videoIndex = 0;
    for (int i = 0; i < carouselIndex; i++) {
      if (carouselItems[i]['type'] == 'video') {
        videoIndex++;
      }
    }
    return videoIndex;
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
      child: SizedBox(
        width: screenWidth,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              // Carousel component
              CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: carouselItems.length,
                itemBuilder: (context, index, realIdx) {
                  final item = carouselItems[index];

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Display different content based on type
                        if (item['type'] == 'image')
                          _buildImageItem(item)
                        else if (item['type'] == 'video' && _allVideosLoaded)
                          _buildVideoItem(item, index)
                        else
                          _buildLoadingPlaceholder(),

                        // Title overlay
                        _buildTitleOverlay(item['title']!),
                      ],
                    ),
                  );
                },
                options: CarouselOptions(
                  viewportFraction: 1.0,
                  autoPlay:
                      _allVideosLoaded, // Auto play only when videos loaded
                  enlargeCenterPage: true,
                  autoPlayInterval:
                      const Duration(milliseconds: 2500), // 2.5s interval
                  autoPlayAnimationDuration: const Duration(milliseconds: 500),
                  autoPlayCurve: Curves.easeInOut,
                  onPageChanged: (index, reason) {
                    setState(() {
                      // Pause previous video
                      if (carouselItems[_currentIndex]['type'] == 'video' &&
                          _allVideosLoaded) {
                        final prevVideoIndex =
                            _getVideoControllerIndex(_currentIndex);
                        if (prevVideoIndex < _videoControllers.length) {
                          _videoControllers[prevVideoIndex].pause();
                        }
                      }

                      _currentIndex = index;

                      // Play current video
                      if (carouselItems[index]['type'] == 'video' &&
                          _allVideosLoaded) {
                        final currentVideoIndex =
                            _getVideoControllerIndex(index);
                        if (currentVideoIndex < _videoControllers.length) {
                          _videoControllers[currentVideoIndex].play();
                        }
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageItem(Map<String, dynamic> item) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover, // 强制填满整个容器
          child: Image.network(
            item['url']!,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 400, // 给一个默认宽度用于加载时显示
                height: 225, // 16:9比例
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 400,
                height: 225,
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVideoItem(Map<String, dynamic> item, int carouselIndex) {
    final videoIndex = _getVideoControllerIndex(carouselIndex);

    if (videoIndex >= _videoControllers.length) {
      return _buildLoadingPlaceholder();
    }

    return Container(
      color: Colors.black,
      child: Chewie(
        controller: ChewieController(
          videoPlayerController: _videoControllers[videoIndex],
          autoPlay: carouselIndex == _currentIndex,
          looping: true,
          showControls: false,
          aspectRatio: 16 / 9,
          placeholder: Container(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildTitleOverlay(String title) {
    return Positioned(
      left: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
