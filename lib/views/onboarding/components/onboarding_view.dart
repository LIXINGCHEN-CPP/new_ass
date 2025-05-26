import 'package:flutter/material.dart';

import '../../../core/components/network_image.dart';
import '../../../core/constants/constants.dart';
import '../data/onboarding_model.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({
    super.key,
    required this.data,
  });

  final OnboardingModel data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 图片部分：分掉 6 份高度中的 4 份
        Flexible(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(AppDefaults.padding * 2),
            child: NetworkImageWithLoader(
              data.imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // 文本部分：分掉 6 份高度中的 2 份
        Flexible(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDefaults.padding,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.headline,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
