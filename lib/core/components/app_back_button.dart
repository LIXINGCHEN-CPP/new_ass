import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/constants.dart';
import '../routes/app_routes.dart';

class AppBackButton extends StatelessWidget {
  /// Custom Back button with a custom ICON for this app
  const AppBackButton({
    super.key,
    this.forceBackToHome = false,
  });

  final bool forceBackToHome;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: SvgPicture.asset(AppIcons.arrowBackward),
      onPressed: () async {
        // Try to pop; if it fails or forced, go to home
        final popped = !forceBackToHome && await Navigator.maybePop(context);
        if (!popped) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.entryPoint,
            (route) => false,
          );
        }
      },
    );
  }
}
