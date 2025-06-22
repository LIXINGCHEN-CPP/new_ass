import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/constants/constants.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/components/network_image.dart';
import '../../../core/components/custom_toast.dart';
import 'profile_header_options.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Background
        Image.asset('assets/images/profile_background.png'),

        /// Content
        Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Profile'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const _UserData(),
            const ProfileHeaderOptions()
          ],
        ),
      ],
    );
  }
}

class _UserData extends StatefulWidget {
  const _UserData();

  @override
  State<_UserData> createState() => _UserDataState();
}

class _UserDataState extends State<_UserData> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.updateProfileImage(image.path);
        
        if (mounted) {
          context.showSuccessToast('Profile picture updated successfully!');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('Failed to update profile picture: $e');
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.updateProfileImage(image.path);
        
        if (mounted) {
          context.showSuccessToast('Profile picture updated successfully!');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('Failed to take photo: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        final userName = user?.name ?? 'Guest User';
        
        return Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Row(
            children: [
              const SizedBox(width: AppDefaults.padding),
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Stack(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: ClipOval(
                        child: AspectRatio(
                          aspectRatio: 1 / 1,
                          child: _buildProfileImage(user?.profileImage),
                        ),
                      ),
                    ),
                  
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDefaults.padding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    if (user?.email != null && user!.email!.isNotEmpty)
                      Text(
                        user.email!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.white.withOpacity(0.8)),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileImage(String? profileImagePath) {
    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      
      if (profileImagePath.startsWith('/') || profileImagePath.startsWith('file://')) {
        return Image.file(
          File(profileImagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        );
      } else if (profileImagePath.startsWith('http')) {
        
        return NetworkImageWithLoader(
          profileImagePath,
          fit: BoxFit.cover,
        );
      }
    }
    
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Image.asset(
      'assets/images/local_avatar.png',
      fit: BoxFit.cover,
    );
  }
}
