// lib/views/help/help_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../core/components/app_back_button.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';

class HelpItem {
  final String question;
  final String answer;
  HelpItem({required this.question, required this.answer});
}

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  final List<HelpItem> _allItems = [
    HelpItem(
      question: 'How can I add new delivery address?',
      answer:
      'Go to Profile → Delivery Addresses → Add New Address. Fill in the details and Save.',
    ),
    HelpItem(
      question: 'How can I get the order status?',
      answer:
      'Open My Orders, tap the order you want, and you will see its current status and history.',
    ),
    HelpItem(
      question: 'How to apply a voucher?',
      answer:
      'On the Checkout screen enter your voucher code under "Apply Voucher" and tap Apply.',
    ),
    HelpItem(
      question: 'What payment methods are supported?',
      answer:
      'We support credit/debit cards, mobile wallets, and net banking. Manage in Settings → Payments.',
    ),
    HelpItem(
      question: 'How do I reset my password?',
      answer:
      'On the Login screen tap "Forgot Password", enter your email/phone and follow the steps.',
    ),
    HelpItem(
      question: 'How can I contact customer support?',
      answer:
      'Go to Help → Contact Us, or email us at support@example.com for further assistance.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchText = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HelpItem> get _filtered {
    if (_searchText.isEmpty) return _allItems;
    final q = _searchText.toLowerCase();
    return _allItems.where((i) {
      return i.question.toLowerCase().contains(q) ||
          i.answer.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: const AppBackButton(),
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        title: const Text('Help & FAQs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          children: [
            // Search box
            Material(
              color: Colors.white,
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search help topics',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      AppIcons.search,
                      colorFilter: const ColorFilter.mode(
                          AppColors.primary, BlendMode.srcIn),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                textInputAction: TextInputAction.search,
              ),
            ),

            const SizedBox(height: AppDefaults.padding),

            // Results list
            Expanded(
              child: results.isEmpty
                  ? Center(
                child: Text(
                  'No topics found.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, idx) {
                  final item = results[idx];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDefaults.padding),
                    child: Material(
                      color: const Color(0xFFF5F5F5),
                      elevation: 1,
                      borderRadius: BorderRadius.circular(8),
                      child: ListTile(
                        title: Text(item.question),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HelpDetailPage(item: item),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpDetailPage extends StatelessWidget {
  final HelpItem item;
  const HelpDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Answer'),
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.question,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppDefaults.padding),
            Text(item.answer, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
