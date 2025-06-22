import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/components/custom_toast.dart';

class LoginPageForm extends StatefulWidget {
  const LoginPageForm({
    super.key,
  });

  @override
  State<LoginPageForm> createState() => _LoginPageFormState();
}

class _LoginPageFormState extends State<LoginPageForm> {
  final _key = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isPasswordShown = false;
  
  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  onPassShowClicked() {
    isPasswordShown = !isPasswordShown;
    setState(() {});
  }

  onLogin() async {
    final bool isFormOkay = _key.currentState?.validate() ?? false;
    if (!isFormOkay) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    final success = await userProvider.login(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (success) {
      // Login successful, navigate to home
      Navigator.pushNamedAndRemoveUntil(
        context, 
        AppRoutes.entryPoint, 
        (route) => false,
      );
      
      context.showSuccessToast('Login successful! Welcome back!');
    } else {
      // Show error message
      context.showErrorToast(userProvider.error ?? 'Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.defaultTheme.copyWith(
        inputDecorationTheme: AppTheme.secondaryInputDecorationTheme,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phone Field
              const Text("Phone Number"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                validator: Validators.requiredWithFieldName('Phone').call,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDefaults.padding),

              // Password Field
              const Text("Password"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                validator: Validators.password.call,
                onFieldSubmitted: (v) => onLogin(),
                textInputAction: TextInputAction.done,
                obscureText: !isPasswordShown,
                decoration: InputDecoration(
                  suffixIcon: GestureDetector(
                    onTap: onPassShowClicked,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPasswordShown
                            ? Colors.green.withOpacity(0.1) // Background color when password is visible
                            : Colors.transparent,          // Transparent background when password is hidden
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.asset(
                        AppIcons.eye,
                        width: 24,
                        colorFilter: ColorFilter.mode(
                          isPasswordShown
                              ? Colors.green    // Icon color when password is visible
                              : Colors.grey,   // Icon color when password is hidden
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(),
                ),
              ),

              // Forget Password labelLarge
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.forgotPassword);
                  },
                  child: const Text('Forget Password?'),
                ),
              ),

              // Login Button
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: userProvider.isLoading ? null : onLogin,
                      child: userProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Login'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}