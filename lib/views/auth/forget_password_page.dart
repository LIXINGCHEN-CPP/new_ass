import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/custom_toast.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/services/database_service.dart';
import '../../core/routes/app_routes.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await DatabaseService.instance.requestPasswordReset(_emailController.text.trim());
      
      if (result['success']) {
        if (mounted) {
          context.showSuccessToast('Verification code sent to your email');
          
          Navigator.pushNamed(
            context, 
            AppRoutes.passwordReset,
            arguments: {
              'email': _emailController.text.trim(),
              'debug': result['debug'],
            },
          );
        }
      } else {
        if (mounted) {
          context.showErrorToast(result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('An error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldWithBoxBackground,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Forget Password'),
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
                      Text(
                        'Reset your password',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppDefaults.padding),
                      const Text(
                        'Please enter your email address. We will send a verification code to your email to reset your password.',
                      ),
                      const SizedBox(height: AppDefaults.padding * 3),
                      const Text("Email Address"),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _sendResetCode(),
                      ),
                      const SizedBox(height: AppDefaults.padding * 2),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendResetCode,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Send Verification Code'),
                        ),
                      ),
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
