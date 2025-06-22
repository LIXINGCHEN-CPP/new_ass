import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

class CustomToast {
  static OverlayEntry? _currentToast;
  static bool _isShowing = false;

  // Show toast notification at the top center of screen
  static void show({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    bool hapticFeedback = true,
  }) {
    // Don't show if already showing
    if (_isShowing) return;

    // Provide haptic feedback
    if (hapticFeedback) {
      switch (type) {
        case ToastType.success:
          HapticFeedback.lightImpact();
          break;
        case ToastType.error:
          HapticFeedback.heavyImpact();
          break;
        case ToastType.warning:
          HapticFeedback.mediumImpact();
          break;
        case ToastType.info:
          HapticFeedback.selectionClick();
          break;
      }
    }

    _isShowing = true;

    // Get overlay
    final overlay = Overlay.of(context);
    
    // Create overlay entry
    _currentToast = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        onDismissed: () {
          _dismiss();
        },
      ),
    );

    // Insert overlay
    overlay.insert(_currentToast!);

    // Auto dismiss after duration
    Future.delayed(duration, () {
      _dismiss();
    });
  }

  // Dismiss current toast
  static void _dismiss() {
    if (_currentToast != null && _isShowing) {
      _currentToast!.remove();
      _currentToast = null;
      _isShowing = false;
    }
  }

  // Force dismiss
  static void dismiss() {
    _dismiss();
  }

  // Show success toast
  static void showSuccess(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.success);
  }

  // Show error toast
  static void showError(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.error);
  }

  // Show warning toast
  static void showWarning(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.warning);
  }

  // Show info toast
  static void showInfo(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.info);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismissed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Slide animation from top
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    ));

    // Opacity animation
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFF4CAF50);
      case ToastType.error:
        return const Color(0xFFE53E3E);
      case ToastType.warning:
        return const Color(0xFFFF9800);
      case ToastType.info:
        return const Color(0xFF2196F3);
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16, // Below status bar + padding
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 320, // Fixed max width
                  minHeight: 56, // Fixed min height
                ),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(),
                  borderRadius: BorderRadius.circular(28), // Pill shape (height/2)
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: _getBackgroundColor().withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIcon(),
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Extension to make it easier to use with context
extension ToastExtension on BuildContext {
  void showToast(String message, {ToastType type = ToastType.info}) {
    CustomToast.show(context: this, message: message, type: type);
  }

  void showSuccessToast(String message) {
    CustomToast.showSuccess(this, message);
  }

  void showErrorToast(String message) {
    CustomToast.showError(this, message);
  }

  void showWarningToast(String message) {
    CustomToast.showWarning(this, message);
  }

  void showInfoToast(String message) {
    CustomToast.showInfo(this, message);
  }
} 