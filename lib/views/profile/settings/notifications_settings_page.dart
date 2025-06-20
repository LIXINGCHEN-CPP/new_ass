import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/components/app_settings_tile.dart';
import '../../../core/constants/constants.dart';
import '../../../core/providers/notification_provider.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text(
          'Change Notification Settings',
        ),
      ),
      backgroundColor: AppColors.cardColor,
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          return Container(
            margin: const EdgeInsets.all(AppDefaults.padding),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDefaults.padding,
              vertical: AppDefaults.padding * 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: AppDefaults.borderRadius,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  const SizedBox(height: AppDefaults.padding),
                  AppSettingsListTile(
                    label: 'App Notification',
                    trailing: Transform.scale(
                      scale: 0.7,
                      child: CupertinoSwitch(
                        value: notificationProvider.appNotification,
                        onChanged: (value) async {
                          await notificationProvider.updateAppNotification(value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value 
                                    ? 'App notifications enabled' 
                                    : 'App notifications disabled'
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  AppSettingsListTile(
                    label: 'Phone Number Notification',
                    trailing: Transform.scale(
                      scale: 0.7,
                      child: CupertinoSwitch(
                        value: notificationProvider.phoneNumberNotification,
                        onChanged: (value) async {
                          await notificationProvider.updatePhoneNumberNotification(value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value 
                                    ? 'Phone notifications enabled' 
                                    : 'Phone notifications disabled'
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  AppSettingsListTile(
                    label: 'Offer Notification',
                    trailing: Transform.scale(
                      scale: 0.7,
                      child: CupertinoSwitch(
                        value: notificationProvider.offerNotification,
                        onChanged: (value) async {
                          await notificationProvider.updateOfferNotification(value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value 
                                    ? 'Offer notifications enabled' 
                                    : 'Offer notifications disabled'
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}