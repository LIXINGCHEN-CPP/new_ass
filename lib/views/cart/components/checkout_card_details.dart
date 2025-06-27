import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import '../../../core/constants/constants.dart';
import '../../../core/models/card_model.dart';
import '../../../core/services/selected_card_service.dart';
import '../../../core/routes/app_routes.dart';

class CardDetails extends StatefulWidget {
  const CardDetails({
    super.key,
  });

  @override
  State<CardDetails> createState() => _CardDetailsState();
}

class _CardDetailsState extends State<CardDetails> with WidgetsBindingObserver {
  CardModel? selectedCard;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSelectedCard();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 当应用恢复时刷新卡片信息
      _loadSelectedCard();
    }
  }

  Future<void> _loadSelectedCard() async {
    setState(() {
      isLoading = true;
    });
    
    final card = await SelectedCardService.getSelectedCard();
    
    if (mounted) {
      setState(() {
        selectedCard = card;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppDefaults.padding),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (selectedCard == null) {
      return Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          children: [
            const Icon(
              Icons.credit_card_off,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No card selected',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please select a card from payment options',
              style: TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await Navigator.pushNamed(context, AppRoutes.paymentMethod);
                // 从payment页面返回后刷新数据
                _loadSelectedCard();
              },
              child: const Text('Select Card'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Credit Card Display
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: CreditCardWidget(
              cardNumber: selectedCard!.cardNumber,
              expiryDate: selectedCard!.expiryDate,
              cardHolderName: selectedCard!.cardHolderName,
              isHolderNameVisible: true,
              backgroundNetworkImage: selectedCard!.backgroundImage,
              cvvCode: selectedCard!.cvvCode,
              showBackView: false,
              cardType: CardType.visa,
              onCreditCardWidgetChange: (v) {},
              isChipVisible: false,
            ),
          ),
          
          // Card Status
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Card selected and ready for payment',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.green),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await Navigator.pushNamed(context, AppRoutes.paymentMethod);
                  // 从payment页面返回后刷新数据
                  _loadSelectedCard();
                },
                child: const Text('Change'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
