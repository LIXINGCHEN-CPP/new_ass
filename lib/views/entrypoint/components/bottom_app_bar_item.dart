import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// 自定义底部导航栏项，支持激活态背景和颜色自定义
class BottomAppBarItem extends StatelessWidget {
  const BottomAppBarItem({
    super.key,
    required this.iconLocation,
    required this.name,
    required this.isActive,
    required this.onTap,
  });

  /// 图标资源路径
  final String iconLocation;
  /// 按钮文字
  final String name;
  /// 是否处于激活态
  final bool isActive;
  /// 点击回调
  final VoidCallback onTap;

  // ===== 以下静态常量用于快速修改颜色值 =====
  /// 激活态主色，修改此值即可改变激活时的图标、文字和背景高亮颜色
  static const Color activeColor = Color(0xFF4CAF50);
  /// 未激活态颜色，修改此值即可改变未激活时的图标和文字颜色
  static const Color inactiveColor = Colors.grey;
  /// 激活态背景透明度（可根据需要调整）
  static const double backgroundOpacity = 0.05;
  /// 水波纹透明度
  static const double splashOpacity = 0.2;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? activeColor.withOpacity(backgroundOpacity)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: activeColor.withOpacity(splashOpacity),
        highlightColor: activeColor.withOpacity(backgroundOpacity),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 2,
            horizontal: 2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                iconLocation,
                colorFilter: ColorFilter.mode(
                  isActive ? activeColor : inactiveColor,
                  BlendMode.srcIn,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isActive
                    ? Text(
                  name,
                  key: const ValueKey('label'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: activeColor,
                  ),
                )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
