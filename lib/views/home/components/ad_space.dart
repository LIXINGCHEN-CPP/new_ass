import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../core/components/network_image.dart';
import '../../../core/constants/constants.dart';

class AdSpace extends StatelessWidget {
  const AdSpace({super.key});

  // Your advertisement image list
  final List<String> adImageUrls = const [
    'https://i.imgur.com/8hBIsS5.png',
    'https://i.imgur.com/BuVEdyX.png',
    'https://i.imgur.com/lu7VPJj.png',
  ];

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
          child: CarouselSlider.builder(
            itemCount: adImageUrls.length,
            itemBuilder: (context, index, realIdx) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: NetworkImageWithLoader(
                  adImageUrls[index],
                  fit: BoxFit.contain,
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
              // No longer use aspectRatio parameter, outer AspectRatio has fixed size
              // aspectRatio: 16/9,

              // Switch every 5 seconds
              autoPlayInterval: const Duration(seconds: 3),
              // Sliding animation lasts 800 milliseconds
              autoPlayAnimationDuration: const Duration(milliseconds: 600),
              // Animation curve (optional)
              autoPlayCurve: Curves.easeInOut,

              // Outer AspectRatio has fixed size, no need to set again here
            ),
          ),
        ),
      ),
    );
  }
}
