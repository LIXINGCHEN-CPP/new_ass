import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/constants.dart';
import '../../../core/utils/validators.dart';
import 'already_have_accout.dart';
import 'sign_up_button.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  // Used to control whether password is hidden
  bool _obscureText = true;

  // Method to toggle _obscureText
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Name"),
          const SizedBox(height: 8),
          TextFormField(
            validator: Validators.requiredWithFieldName('Name').call,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppDefaults.padding),
          const Text("Phone Number"),
          const SizedBox(height: 8),
          TextFormField(
            textInputAction: TextInputAction.next,
            validator: Validators.required.call,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: AppDefaults.padding),
          const Text("Password"),
          const SizedBox(height: 8),
          TextFormField(
            validator: Validators.required.call,
            textInputAction: TextInputAction.next,
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
                        ? Colors.green.withOpacity(0.1) // Background color when password is visible
                        : Colors.transparent,          // Transparent background when password is hidden
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    AppIcons.eye,
                    width: 24,
                    colorFilter: ColorFilter.mode(
                      !_obscureText
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
          const SizedBox(height: AppDefaults.padding),
          const SignUpButton(),
          const AlreadyHaveAnAccount(),
          const SizedBox(height: AppDefaults.padding),
        ],
      ),
    );
  }
}