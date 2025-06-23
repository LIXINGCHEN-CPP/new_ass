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
  // Video URLs list with descriptions
  final List<Map<String, String>> videoItems = const [
    {'url': 'https://files.catbox.moe/39nvvn.mp4', 'title': 'Apple'},
    {'url': 'https://files.catbox.moe/40gmxv.mp4', 'title': 'Vegetables'},
    {'url': 'https://files.catbox.moe/e0epvt.mp4', 'title': 'Fruit'},
    {'url': 'https://files.catbox.moe/ns75a4.mp4', 'title': 'Fruit bowl'},
    {'url': 'https://files.catbox.moe/m27wrv.mp4', 'title': 'Hodgepodge'},
  ];

  int _currentIndex = 0;
  final List<VideoPlayerController> _controllers = [];
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAllControllers();
  }

  Future<void> _initializeAllControllers() async {
    // Create controllers for all videos
    for (var item in videoItems) {
      final controller = VideoPlayerController.network(item['url']!);
      _controllers.add(controller);
    }

    // Initialize all controllers in parallel
    await Future.wait(
        _controllers.map((controller) => controller.initialize()));

    // Set looping for all videos
    for (var controller in _controllers) {
      await controller.setLooping(true);
    }

    // Start playing the first video
    if (_controllers.isNotEmpty) {
      _controllers[0].play();
    }

    if (mounted) {
      setState(() {
        _controllersInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Available screen width
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
      child: SizedBox(
        width: screenWidth,
        // Ensure aspect ratio 16:9
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: _controllersInitialized
              ? CarouselSlider.builder(
                  itemCount: videoItems.length,
                  itemBuilder: (context, index, realIdx) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Video player with black background
                          Container(
                            color: Colors.black,
                            child: Chewie(
                              controller: ChewieController(
                                videoPlayerController: _controllers[index],
                                autoPlay: index == _currentIndex,
                                looping: true,
                                showControls: false,
                                aspectRatio: 16 / 9, // Force 16:9 aspect ratio
                                placeholder: Container(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          // Title overlay at bottom left
                          Positioned(
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
                                videoItems[index]['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  options: CarouselOptions(
                    // Viewport fills the entire AspectRatio area
                    viewportFraction: 1.0,
                    // Auto play
                    autoPlay: true,
                    // Center enlargement, optional, set as needed
                    enlargeCenterPage: true,
                    // Switch every 10 seconds to allow video to play
                    autoPlayInterval: const Duration(seconds: 10),
                    // Sliding animation lasts 800 milliseconds
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    // Animation curve
                    autoPlayCurve: Curves.easeInOut,
                    onPageChanged: (index, reason) {
                      setState(() {
                        // Pause the previous video
                        if (_currentIndex != index && _controllers.isNotEmpty) {
                          _controllers[_currentIndex].pause();
                        }

                        // Update current index
                        _currentIndex = index;

                        // Play the current video
                        if (_controllers.isNotEmpty) {
                          _controllers[index].play();
                        }
                      });
                    },
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}
