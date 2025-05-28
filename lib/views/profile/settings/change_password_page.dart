import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/constants/constants.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  // 控制每个密码字段的可见性
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text(
          'Change Password Page',
        ),
      ),
      backgroundColor: AppColors.cardColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(AppDefaults.padding),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDefaults.padding,
              vertical: AppDefaults.padding * 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: AppDefaults.borderRadius,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* <----  Current Password -----> */
                const Text("Current Password"),
                const SizedBox(height: 8),
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  obscureText: !_isCurrentPasswordVisible, // 控制密码可见性
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isCurrentPasswordVisible
                              ? Colors.green.withOpacity(0.1) // 显示密码时的背景色
                              : Colors.transparent,          // 隐藏密码时透明背景
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          AppIcons.eye,
                          colorFilter: ColorFilter.mode(
                            _isCurrentPasswordVisible
                                ? Colors.green    // 显示密码时的图标颜色
                                : Colors.grey,   // 隐藏密码时的图标颜色
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(height: AppDefaults.padding),

                /* <---- New Password -----> */
                const Text("New Password"),
                const SizedBox(height: 8),
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  obscureText: !_isNewPasswordVisible, // 控制密码可见性
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isNewPasswordVisible
                              ? Colors.green.withOpacity(0.1) // 显示密码时的背景色
                              : Colors.transparent,          // 隐藏密码时透明背景
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          AppIcons.eye,
                          colorFilter: ColorFilter.mode(
                            _isNewPasswordVisible
                                ? Colors.green    // 显示密码时的图标颜色
                                : Colors.grey,   // 隐藏密码时的图标颜色
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(height: AppDefaults.padding),

                /* <---- Confirm Password-----> */
                const Text("Confirm Password"),
                const SizedBox(height: 8),
                TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  obscureText: !_isConfirmPasswordVisible, // 控制密码可见性
                  decoration: InputDecoration(
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isConfirmPasswordVisible
                              ? Colors.green.withOpacity(0.1) // 显示密码时的背景色
                              : Colors.transparent,          // 隐藏密码时透明背景
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          AppIcons.eye,
                          colorFilter: ColorFilter.mode(
                            _isConfirmPasswordVisible
                                ? Colors.green    // 显示密码时的图标颜色
                                : Colors.grey,   // 隐藏密码时的图标颜色
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(height: AppDefaults.padding),

                /* <---- Submit -----> */
                const SizedBox(height: AppDefaults.padding),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text('Update Password'),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}