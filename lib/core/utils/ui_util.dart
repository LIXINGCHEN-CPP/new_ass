import 'package:flutter/material.dart';

import '../constants/app_defaults.dart';

class UiUtil {
  /// OPENS BOTTOM SHEET WITH THE GIVEN WIDGET
  /// Opens a bottom sheet with the given widget and returns the result when the
  /// sheet is closed. This is a thin wrapper around [showModalBottomSheet] so it
  /// can be awaited for a value.
  static Future<T?> openBottomSheet<T>({
    required BuildContext context,
    required Widget widget,
  }) async {
    return await showModalBottomSheet<T>(
      context: context,
      builder: (ctx) => widget,
      isScrollControlled: true,
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: AppDefaults.bottomSheetRadius,
      ),
    );
  }

  /// Opens dialog with background blur enabled
  static Future openDialog({
    required BuildContext context,
    required Widget widget,
    bool isDismissable = true,
  }) async {
    return await showGeneralDialog(
      barrierLabel: 'Dialog',
      barrierDismissible: isDismissable,
      context: context,
      pageBuilder: (ctx, anim1, anim2) => widget,
      transitionBuilder: (ctx, anim1, anim2, child) => ScaleTransition(
        scale: anim1,
        child: child,
      ),
    );
  }
}
