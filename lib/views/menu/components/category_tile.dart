import 'package:flutter/material.dart';

import '../../../core/components/network_image.dart';
import '../../../core/constants/constants.dart';

class CategoryTile extends StatefulWidget {
  const CategoryTile({
    super.key,
    required this.imageLink,
    required this.label,
    this.backgroundColor,
    required this.onTap,
  });

  final String imageLink;
  final String label;
  final Color? backgroundColor;
  final void Function() onTap;

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        _controller.forward();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: AppDefaults.borderRadius,
                splashColor: Colors.blue.withOpacity(0.3),
                highlightColor: Colors.blue.withOpacity(0.1),
                onTap: () {
                  // Add click animation
                  _controller.forward().then((_) {
                    _controller.reverse().then((_) {
                      widget.onTap();
                    });
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(AppDefaults.padding * 1),
                      decoration: BoxDecoration(
                        color: _isHovered
                            ? (widget.backgroundColor ??
                                    AppColors.textInputBackground)
                                .withOpacity(0.8)
                            : widget.backgroundColor ??
                                AppColors.textInputBackground,
                        shape: BoxShape.circle,
                        boxShadow: _isHovered
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: SizedBox(
                        width: 36,
                        child: AspectRatio(
                          aspectRatio: 1 / 1,
                          child: NetworkImageWithLoader(
                            widget.imageLink,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: _isHovered
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: _isHovered ? Colors.blue : null,
                              ) ??
                          const TextStyle(),
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
