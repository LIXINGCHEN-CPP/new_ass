import 'package:flutter/material.dart';

import '../../core/components/network_image.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/routes/app_routes.dart';

class EmptySavePage extends StatelessWidget {
  const EmptySavePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),

          // Demo image
          SizedBox(
            width: width * 0.7,
            child: Padding(
              padding: const EdgeInsets.all(AppDefaults.padding * 2),
              child: AspectRatio(
                aspectRatio: 1,
                child: const NetworkImageWithLoader(
                  'https://i.imgur.com/mbjap7k.png',
                ),
              ),
            ),
          ),

          // Title
          Text(
            'Oppss!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Sorry, you have no product in your wishlist',
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(),

          // "Start Browsing" button
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(AppDefaults.padding * 2),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.entryPoint,
                    (route) => false,
                  );
                },
                child: const Text('Start Browsing'),
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
