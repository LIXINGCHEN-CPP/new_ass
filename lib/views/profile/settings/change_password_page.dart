import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/constants/constants.dart';
import '../../../core/providers/user_provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // Control visibility of each password field
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final result = await context.read<UserProvider>().changePassword(
              currentPassword: _currentPasswordController.text,
              newPassword: _newPasswordController.text,
            );

        if (result) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password changed successfully.')),
            );
            Navigator.pop(context);
          }
        } else {
          final error = context.read<UserProvider>().error;
          setState(() {
            _errorMessage =
                error ?? 'Password change failed, please try again.';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error has occurred. $e';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  String? _validatePassword(String? value, {bool isConfirm = false}) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }

    // Length requirement changed to 8 digits, consistent with the back end.
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Special character verification, consistent with the back end
    final specialCharPattern = RegExp(r'[#?!@$%^&*-]');
    if (!specialCharPattern.hasMatch(value)) {
      return 'Password must contain at least one special character (#?!@\$%^&*-)';
    }

    if (isConfirm && value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /* <----  Current Password -----> */
                  const Text("Current Password"),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _currentPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    obscureText: !_isCurrentPasswordVisible,
                    validator: (value) => _validatePassword(value),
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCurrentPasswordVisible =
                                !_isCurrentPasswordVisible;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isCurrentPasswordVisible
                                ? Colors.green.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SvgPicture.asset(
                            AppIcons.eye,
                            colorFilter: ColorFilter.mode(
                              _isCurrentPasswordVisible
                                  ? Colors.green
                                  : Colors.grey,
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
                    controller: _newPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    obscureText: !_isNewPasswordVisible,
                    validator: (value) => _validatePassword(value),
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
                                ? Colors.green.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SvgPicture.asset(
                            AppIcons.eye,
                            colorFilter: ColorFilter.mode(
                              _isNewPasswordVisible
                                  ? Colors.green
                                  : Colors.grey,
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
                    controller: _confirmPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    obscureText: !_isConfirmPasswordVisible,
                    validator: (value) =>
                        _validatePassword(value, isConfirm: true),
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isConfirmPasswordVisible
                                ? Colors.green.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SvgPicture.asset(
                            AppIcons.eye,
                            colorFilter: ColorFilter.mode(
                              _isConfirmPasswordVisible
                                  ? Colors.green
                                  : Colors.grey,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(height: AppDefaults.padding),

                  /* <---- Error Message -----> */
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  /* <---- Submit -----> */
                  const SizedBox(height: AppDefaults.padding),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _changePassword,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Update Password'),
                    ),
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
