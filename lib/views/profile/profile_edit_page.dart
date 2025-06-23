import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/user_provider.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Get user data in next frame to avoid calling Provider in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user =
          Provider.of<UserProvider>(context, listen: false).currentUser;
      if (user != null) {
        nameController.text = user.name;
        phoneController.text = user.phone;
        genderController.text = user.gender ?? '';
        birthdayController.text = user.birthday ?? '';
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    genderController.dispose();
    birthdayController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text(
          'Profile',
        ),
      ),
      body: SingleChildScrollView(
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
              /* <---- Name -----> */
              const Text("Name"),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: "Enter your name",
                ),
              ),
              const SizedBox(height: AppDefaults.padding),

              /* <---- Phone Number -----> */
              const Text("Phone Number"),
              const SizedBox(height: 8),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                readOnly: true, // Phone number is read-only
                decoration: const InputDecoration(
                  hintText: "Your phone number",
                ),
              ),
              const SizedBox(height: AppDefaults.padding),

              /* <---- Gender -----> */
              const Text("Gender"),
              const SizedBox(height: 8),
              TextFormField(
                controller: genderController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: "Enter your gender",
                ),
              ),
              const SizedBox(height: AppDefaults.padding),

              /* <---- Birthday -----> */
              const Text("Birthday"),
              const SizedBox(height: 8),
              TextFormField(
                controller: birthdayController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: "Enter your birthday",
                ),
              ),
              const SizedBox(height: AppDefaults.padding),

              /* <---- Submit -----> */
              const SizedBox(height: AppDefaults.padding),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_validateForm()) {
                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              final userProvider = Provider.of<UserProvider>(
                                  context,
                                  listen: false);

                              final currentUser = userProvider.currentUser;
                              if (currentUser != null) {
                                final updatedUser = currentUser.copyWith(
                                  name: nameController.text,
                                  gender: genderController.text.isEmpty
                                      ? null
                                      : genderController.text,
                                  birthday: birthdayController.text.isEmpty
                                      ? null
                                      : birthdayController.text,
                                );

                                final success =
                                    await userProvider.updateUser(updatedUser);

                                if (mounted) {
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Profile updated successfully')),
                                    );
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Failed to update profile')),
                                    );
                                  }
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Failed to update profile: ${e.toString()}')),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
