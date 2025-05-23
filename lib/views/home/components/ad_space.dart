import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../core/components/network_image.dart';
import '../../../core/constants/constants.dart';

class AdSpace extends StatelessWidget {
  const AdSpace({super.key});

  // 你的广告图列表
  final List<String> adImageUrls = const [
    'https://i.imgur.com/8hBIsS5.png',
    'https://i.imgur.com/BuVEdyX.png',
    'https://i.imgur.com/wORa2qS.png',
  ];

  @override
  Widget build(BuildContext context) {
    // 屏幕可用宽度
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
      child: SizedBox(
        width: screenWidth,
        // 保证宽高比 16:9
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
              // 视口占满整个 AspectRatio 区域
              viewportFraction: 1.0,
              // 自动播放
              autoPlay: true,
              // 中心放大，去掉也行，按需设
              enlargeCenterPage: true,
              // 不再使用 aspectRatio 参数，外层 AspectRatio 已固定大小
              // aspectRatio: 16/9,

              // 每隔 5 秒切换一次
              autoPlayInterval: const Duration(seconds: 3),
              // 滑动动画持续 800 毫秒
              autoPlayAnimationDuration: const Duration(milliseconds: 600),
              // 动画曲线（可选）
              autoPlayCurve: Curves.easeInOut,

              // 外层 AspectRatio 已固定大小，无需在此重复设置
            ),
          ),
        ),
      ),
    );
  }
}
