import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import 'components/faq_item.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Terms And Condition'),
      ),
      body: const Column(
        children: [
          TitleAndParagraph(
              isTitleHeadline: false,
              title: 'General site usage last revised\n 23-05-2025.',
              paragraph:
                  '''Welcome to eGrocery. By accessing or using our app and services, you agree to be bound by these Terms & Conditions. Please read them carefully before placing any orders.'''),
          TitleAndParagraph(
              isTitleHeadline: false,
              title: '1. Agreement',
              paragraph:
                  '''By creating an account or placing an order, you confirm that you are at least 18 years old and legally capable of entering into binding contracts. You agree to comply with all applicable laws and regulations in connection with your use of eGrocery.'''),
          TitleAndParagraph(
              isTitleHeadline: false,
              title: '2. Account',
              paragraph:
                  '''To place orders, you must register with accurate and up-to-date information. You are responsible for maintaining the confidentiality of your login credentials and for all activities under your account. Notify us immediately if you suspect any unauthorized use.'''),
          TitleAndParagraph(
              isTitleHeadline: false,
              title: '3. Changes to Terms',
              paragraph:
                  '''We may update these Terms & Conditions from time to time. The last revised date above reflects the most recent update. Continued use of eGrocery after changes constitutes your acceptance of the new terms.

'''),
        ],
      ),
    );
  }
}
