import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/network_image.dart';
import '../../core/constants/app_defaults.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text(
          'Notification',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: AppDefaults.padding),
        children: const [

          NotificationTile(
            imageLink: 'https://i.imgur.com/XYbd8Tj.png',
            title: 'eGrocery Message',
            subtitle: 'Your order #232425627 Beef is out of stock. You can request a refund.',
            time: 'Now',
          ),
          NotificationTile(
            imageLink: 'https://i.imgur.com/MFO1R5K.png',
            title: 'Gifts Offer',
            subtitle: 'Buy one gift and get one free! Limited time deal...',
            time: 'Now',
          ),
          NotificationTile(
            imageLink: 'https://i.imgur.com/cl19m4w.png',
            title: 'Coupon Offer',
            subtitle: 'Apply this coupon at checkout to save more...',
            time: '10 Minutes Ago',
          ),
          NotificationTile(
            imageLink: 'https://i.imgur.com/KKWqqrP.png',
            title: 'Congratulations',
            subtitle: 'Your order has been successfully placed！',
            time: '15 Minutes Ago',
          ),
          NotificationTile(
            imageLink: 'https://i.imgur.com/jsDEdkz.png',
            title: 'Your Order Cancelled',
            subtitle: 'Your recent order has been cancelled. Need help?',
            time: '15 Minutes Ago',
          ),
          NotificationTile(
            imageLink: 'https://i.imgur.com/hmUnrRE.png',
            title: 'Great Winter Discounts',
            subtitle: 'Enjoy special winter savings on selected items...',
            time: '15 Minutes Ago',
          ),
          NotificationTile(
            imageLink: 'https://i.imgur.com/VSwGkZg.png',
            title: '20% off Vegetables',
            subtitle: 'Get fresh vegetables at 20% off today only!',
            time: '15 Minutes Ago',
          ),
          
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    this.imageLink,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final String? imageLink;
  final String title;
  final String subtitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: imageLink != null
                  ? AspectRatio(
                      aspectRatio: 1 / 1,
                      child: NetworkImageWithLoader(imageLink!),
                    )
                  : null,
              title: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  Text(subtitle),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 86),
              child: Divider(thickness: 0.1),
            ),
          ],
        ),
      ),
    );
  }
}
