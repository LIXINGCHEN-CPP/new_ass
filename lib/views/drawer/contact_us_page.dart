import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/network_image.dart';
import '../../core/constants/constants.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = AppDefaults.padding;
    final verticalPadding = AppDefaults.padding * 2;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Contact Us'),
      ),
      backgroundColor: AppColors.cardColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppDefaults.padding),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: AppDefaults.borderRadius,
            ),
            // Use SingleChildScrollView wrapper
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Contact Us',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDefaults.padding * 2),

                  // Phone row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(AppIcons.contactPhone),
                      const SizedBox(width: AppDefaults.padding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '+60142355625',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.black),
                            ),
                            const SizedBox(height: AppDefaults.padding / 2),
                            Text(
                              '+60132699546',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDefaults.padding),

                  // Email row
                  Row(
                    children: [
                      SvgPicture.asset(AppIcons.contactEmail),
                      const SizedBox(width: AppDefaults.padding),
                      Expanded(
                        child: Text(
                          'alena123456@gmail.com',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDefaults.padding),

                  // Address row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(AppIcons.contactMap),
                      const SizedBox(width: AppDefaults.padding),
                      Expanded(
                        child: Text(
                          '2, Jalan Hang Kasturi, City Centre, 50050 Kuala Lumpur',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDefaults.padding),

                  // Image
                  LayoutBuilder(
                    builder: (ctx, constraints) {
                      // Width should not exceed remaining space
                      final width = constraints.maxWidth;
                      return SizedBox(
                        width: width,
                        child: AspectRatio(
                          aspectRatio: 3 / 2,
                          child: NetworkImageWithLoader(
                            'https://i.imgur.com/lg6cLrQ.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}