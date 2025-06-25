import 'package:flutter/material.dart';

import '../../../core/constants/app_defaults.dart';
import '../../../core/components/app_back_button.dart';
import '../../../../core/models/card_model.dart';
import '../../../../core/services/card_service.dart';
import 'components/new_card_row.dart';
import 'components/card_carousel.dart';
import 'components/payment_option_tile.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  List<CardModel> cards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      final loadedCards = await CardService.getCards();
      if (mounted) {
        setState(() {
          cards = loadedCards;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshCards() async {
    await _loadCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Payment Option'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCards,
        child: Column(
          children: [
            const SizedBox(height: AppDefaults.padding),
            AddNewCardRow(onCardAdded: _refreshCards),

            // 卡片轮播区域
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDefaults.padding),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (cards.isNotEmpty)
              CardCarousel(
                cards: cards,
                onCardDeleted: (index) async {
                  await CardService.deleteCard(index);
                  _refreshCards();
                },
              )
            else
              Container(
                height: 200,
                margin: const EdgeInsets.all(AppDefaults.padding),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: AppDefaults.borderRadius,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Center(
                  child: Text(
                    'No cards added yet\nTap the + button to add your first card',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(AppDefaults.padding),
                child: Text(
                  'Other Payment Option',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            PaymentOptionTile(
              icon: 'https://img.picui.cn/free/2025/06/24/6859892f74afc.png',
              label: 'Stripe',
              accountName: 'Secure online payment with Stripe',
              onTap: () {},
            ),
            PaymentOptionTile(
              icon: 'https://i.imgur.com/aRJj3iU.png',
              label: 'Cash on Delivery',
              accountName: 'Pay in Cash',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}