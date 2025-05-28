// lib/features/faq/faq_page.dart

import 'package:flutter/material.dart';
import '../../core/components/app_back_button.dart';
import '../../core/constants/app_defaults.dart';    // ← 一定要加这行
import 'components/faq_item.dart';                  // 你的 TitleAndParagraph 定义在这里

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('FAQs'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDefaults.padding),
        children: const [
          TitleAndParagraph(
            title: '1. What are the delivery hours?',
            paragraph: '''
We deliver every day from 8 AM to 10 PM. Orders placed before 8 PM usually arrive the same evening, while later orders are scheduled for the next available slot. During peak periods or public holidays, please allow an extra hour for delivery to ensure we meet quality and freshness standards.''',
          ),
          SizedBox(height: AppDefaults.padding),
          TitleAndParagraph(
            title: '2. How do we make sure product quality?',
            paragraph: '''
All items undergo strict quality checks at our central warehouse and partner stores. Fresh produce is inspected daily, and perishable goods are stored under temperature control. Any product failing to meet standards is immediately replaced at no extra cost.''',
          ),
          SizedBox(height: AppDefaults.padding),
          TitleAndParagraph(
            title: '3. How does the refund system work?',
            paragraph: '''
If there's an issue with any item, please contact us within 24 hours. Once confirmed, we will process a full refund to your original payment method within 3-5 business days. You can track your payment status during that period.''',
          ),
        ],
      ),
    );
  }
}
