import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/custom_toast.dart';
import '../../core/constants/constants.dart';
import '../../core/services/database_service.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/validators.dart';

class PasswordResetPage extends StatefulWidget {
  final String? email;
  final Map<String, dynamic>? debugInfo;
  
  const PasswordResetPage({
    super.key,
    this.email,
    this.debugInfo,
  });

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isCodeVerified = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  String? _email;
  Map<String, dynamic>? _debugInfo;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      setState(() {
        _email = widget.email ?? args?['email'];
        _debugInfo = widget.debugInfo ?? args?['debug'];
      });
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (_email == null || _codeController.text.isEmpty) {
      context.showErrorToast('Please enter a valid verification code');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await DatabaseService.instance.verifyResetCode(_email!, _codeController.text.trim());
      
      if (result['success'] == true) {
        setState(() {
          _isCodeVerified = true;
        });
        context.showSuccessToast('Code verified! Please set your new password.');
      } else {
        context.showErrorToast(result['message'] ?? 'Invalid verification code');
      }
    } catch (e) {
      context.showErrorToast('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await DatabaseService.instance.resetPassword(
        email: _email!,
        code: _codeController.text.trim(),
        newPassword: _passwordController.text,
      );
      
      if (result['success']) {
        context.showSuccessToast('Password reset successfully!');
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      } else {
        context.showErrorToast(result['message']);
      }
    } catch (e) {
      context.showErrorToast('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldWithBoxBackground,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(_isCodeVerified ? 'New Password' : 'Verify Code'),
        backgroundColor: AppColors.scaffoldBackground,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(AppDefaults.margin),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDefaults.padding,
                  vertical: AppDefaults.padding * 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppDefaults.borderRadius,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isCodeVerified) ...[
                        Text(
                          'Enter Verification Code',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppDefaults.padding),
                        Text(
                          'Please enter the 4-digit verification code sent to ${_email ?? 'your email'}',
                        ),
                        
                        const SizedBox(height: AppDefaults.padding * 3),
                        const Text("Verification Code"),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _codeController,
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the verification code';
                            }
                            if (value.length != 4) {
                              return 'Verification code must be 4 digits';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            // Removed auto-verification to avoid conflicts
                            // User should click the verify button manually
                          },
                          onFieldSubmitted: (_) => _verifyCode(),
                        ),
                        const SizedBox(height: AppDefaults.padding),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyCode,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Verify Code'),
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Set New Password',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppDefaults.padding * 3),
                        const Text("New Password"),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          obscureText: _obscurePassword,
                          validator: Validators.password.call,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDefaults.padding),
                        const Text("Confirm Password"),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          textInputAction: TextInputAction.done,
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          onFieldSubmitted: (_) => _resetPassword(),
                        ),
                        const SizedBox(height: AppDefaults.padding * 2),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _resetPassword,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Reset Password'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
