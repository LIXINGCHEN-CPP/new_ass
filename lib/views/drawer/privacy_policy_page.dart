import 'package:flutter/material.dart';
import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';

/// A simple Privacy Policy page
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Privacy Policy'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding * 2),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // Text(
              //   'Privacy Policy',
              //   style: TextStyle(fontSize: 24, color: Colors.black),
              // ),
              SizedBox(height: 16),
              Text(
                'Last updated: May 1, 2025',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 24),
              Text(
                '1. Introduction\n'
                    'Welcome to eGrocery! We respect your privacy and are committed to protecting your personal data. '
                    'This policy explains how we collect, use, and safeguard your information when you use our app.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                '2. Data We Collect\n'
                    '- Personal Information: Name, email, phone number, delivery address.\n'
                    '- Payment Information: Credit/debit card details (handled via secure gateway).\n'
                    '- Usage Data: Pages visited, items viewed, search queries, device information.\n',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                '3. How We Use Your Data\n'
                    '- To process and fulfill your orders.\n'
                    '- To communicate order status and promotions.\n'
                    '- To improve our app and personalize your experience.\n',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                '4. Data Sharing\n'
                    'We do not sell your personal data. We may share information with:\n'
                    '- Delivery partners for order fulfillment.\n'
                    '- Payment processors for transactions.\n'
                    '- Legal authorities when required by law.\n',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                '5. Your Rights\n'
                    'You have the right to access, correct, or delete your personal data. '
                    'Contact us at privacy@egrocery.com to exercise these rights.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                '6. Changes to This Policy\n'
                    'We may update this policy from time to time. We will notify you of significant changes.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 32),
              Text(
                'If you have any questions, please contact us at 7Packanyet@gmail.com.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
