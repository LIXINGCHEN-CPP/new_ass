import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/components/custom_toast.dart';
import 'already_have_accout.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  
  // Used to control whether password is hidden
  bool _obscureText = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Method to toggle _obscureText
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // Handle registration
  void _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    final success = await userProvider.register(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
    );

    if (success) {
      // Registration successful, navigate to home
      Navigator.pushNamedAndRemoveUntil(
        context, 
        AppRoutes.entryPoint, 
        (route) => false,
      );
      
      context.showSuccessToast('Registration successful! Welcome!');
    } else {
 
      context.showErrorToast(userProvider.error ?? 'Registration failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDefaults.margin),
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppDefaults.boxShadow,
        borderRadius: AppDefaults.borderRadius,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Name"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              validator: Validators.requiredWithFieldName('Name').call,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppDefaults.padding),
            const Text("Phone Number"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              textInputAction: TextInputAction.next,
              validator: Validators.requiredWithFieldName('Phone').call,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: AppDefaults.padding),
            const Text("Email"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return Validators.email.call(value);
                }
                return null;
              },
            ),
            const SizedBox(height: AppDefaults.padding),
            const Text("Password"),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              validator: Validators.password.call,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleRegistration(),
              // Decide whether to hide based on _obscureText
              obscureText: _obscureText,
              decoration: InputDecoration(
                suffixIcon: GestureDetector(
                  onTap: _togglePasswordVisibility,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: !_obscureText
                          ? Colors.green.withOpacity(0.1) 
                          : Colors.transparent,          
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset(
                      AppIcons.eye,
                      width: 24,
                      colorFilter: ColorFilter.mode(
                        !_obscureText
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
            
            // Register Button
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: userProvider.isLoading ? null : _handleRegistration,
                    child: userProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Sign Up'),
                  ),
                );
              },
            ),
            
            const AlreadyHaveAnAccount(),
            const SizedBox(height: AppDefaults.padding),
          ],
        ),
      ),
    );
  }
}