import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import 'components/faq_item.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('FAQ'),
      ),
      body: const Column(
        children: [
          TitleAndParagraph(
              title: '1. What are the delivery hours?',
              paragraph:
                  '''We deliver every day from 8 AM to 10 PM. Orders placed before 8 PM usually arrive the same evening, while later orders are scheduled for the next available slot. During peak periods or public holidays, please allow an extra hour for delivery to ensure we meet quality and freshness standards.'''),
          TitleAndParagraph(
              title: '2. How do we make sure product quality?',
              paragraph:
                  '''All items undergo strict quality checks at our central warehouse and partner stores. Fresh produce is inspected daily, and perishable goods are stored under temperature control. Any product failing to meet standards is immediately replaced at no extra cost.'''),
          TitleAndParagraph(
              title: '3. How does the refund system work?',
              paragraph:
                  '''If there's an issue with any item, please contact us within 24 hours. Once confirmed, we will process a full refund to your original payment method within 3-5 business days. You can track the your payment account at that period.'''),
        ],
      ),
    );
  }
}
