import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/components/app_settings_tile.dart';
import '../../../core/constants/constants.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // 状态变量来控制每个开关的状态
  bool appNotification = true;
  bool phoneNumberNotification = true;
  bool offerNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text(
          'Change Notificaiton Settings',
        ),
      ),
      backgroundColor: AppColors.cardColor,
      body: Container(
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
                    value: appNotification,
                    onChanged: (value) {
                      setState(() {
                        appNotification = value;
                      });
                    },
                  ),
                ),
              ),
              AppSettingsListTile(
                label: 'Phone Number Notification',
                trailing: Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    value: phoneNumberNotification,
                    onChanged: (value) {
                      setState(() {
                        phoneNumberNotification = value;
                      });
                    },
                  ),
                ),
              ),
              AppSettingsListTile(
                label: 'Offer Notification',
                trailing: Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    value: offerNotification,
                    onChanged: (value) {
                      setState(() {
                        offerNotification = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}