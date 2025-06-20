import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'components/profile_header.dart';
import 'components/profile_menu_options.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      body: SafeArea(
        // Use ListView instead of Column to allow scrolling when content overflows
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            ProfileHeader(),
            // SizedBox(height: 5),
            ProfileMenuOptions(),
          ],
        ),
      ),
    );
  }
}
