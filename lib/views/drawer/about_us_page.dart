import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('About Us'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Us',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDefaults.padding),
            const Text(
              'eGrocery is our online one-stop destination for fresh produce '
                  'and everyday essentials, delivering the trusted shopping experience '
                  'you love from our shop directly to your door.\n\n'
                  'Our Mission is to empower everyone with the confidence and convenience '
                  'of premium ingredients, while using technology to simplify every step of the shopping journey.\n\n'
                  'Our vision is to become one trusted online marketplace, seamlessly '
                  'blending quality and convenience for every family. We follow quality first '
                  'and maintain strict sourcing standards and full traceability across our supply chain.',
            ),
          ],
        ),
      ),
    );
  }
}
