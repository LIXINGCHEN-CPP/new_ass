import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/components/app_back_button.dart';
import '../../../../core/models/card_model.dart';
import '../../../../core/services/card_service.dart';

class AddNewCardPage extends StatefulWidget {
  const AddNewCardPage({super.key});

  @override
  State<AddNewCardPage> createState() => _AddNewCardPageState();
}

class _AddNewCardPageState extends State<AddNewCardPage> {
  late TextEditingController cardNumber;
  late TextEditingController expireDate;
  late TextEditingController cvv;
  late TextEditingController holderName;

  bool rememberMyCard = false;
  bool isLoading = false;

  // 可选择的背景图片
  final List<String> backgroundImages = [
    'https://i.imgur.com/AMA5llS.png',
    'https://i.imgur.com/uUDkwQx.png',
    // 'https://i.imgur.com/KkOQFYb.png',
    // 'https://i.imgur.com/7qF8Qzx.png',
  ];

  int selectedBackgroundIndex = 0;

  onTextChanged(v) {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    cardNumber = TextEditingController();
    expireDate = TextEditingController();
    holderName = TextEditingController();
    cvv = TextEditingController();
  }

  @override
  void dispose() {
    cardNumber.dispose();
    expireDate.dispose();
    holderName.dispose();
    cvv.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    // 验证输入
    if (holderName.text.trim().isEmpty) {
      _showError('Please enter card holder name');
      return;
    }
    if (cardNumber.text.trim().isEmpty || cardNumber.text.length < 16) {
      _showError('Please enter a valid card number');
      return;
    }
    if (expireDate.text.trim().isEmpty) {
      _showError('Please enter expiry date');
      return;
    }
    if (cvv.text.trim().isEmpty || cvv.text.length < 3) {
      _showError('Please enter a valid CVV');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final card = CardModel(
        cardNumber: cardNumber.text.trim(),
        expiryDate: expireDate.text.trim(),
        cardHolderName: holderName.text.trim(),
        cvvCode: cvv.text.trim(),
        backgroundImage: backgroundImages[selectedBackgroundIndex],
      );

      await CardService.saveCard(card);

      if (mounted) {
        Navigator.of(context).pop(true); // 返回true表示成功添加
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to save card. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Add New Card'),
      ),
      backgroundColor: AppColors.cardColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppDefaults.padding / 2),
            CreditCardWidget(
              cardNumber: cardNumber.text,
              expiryDate: expireDate.text,
              cardHolderName: holderName.text,
              isHolderNameVisible: true,
              backgroundNetworkImage: backgroundImages[selectedBackgroundIndex],
              cvvCode: cvv.text,
              showBackView: false,
              cardType: CardType.visa,
              onCreditCardWidgetChange: (v) {},
              isChipVisible: false,
            ),
            CreditCardForm(
              cardNumber: cardNumber,
              expireDate: expireDate,
              cvv: cvv,
              holderName: holderName,
              rememberMyCard: rememberMyCard,
              backgroundImages: backgroundImages,
              selectedBackgroundIndex: selectedBackgroundIndex,
              onTextChanged: onTextChanged,
              onRememberMyCardChanged: (v) {
                rememberMyCard = !rememberMyCard;
                if (mounted) setState(() {});
              },
              onBackgroundChanged: (index) {
                setState(() {
                  selectedBackgroundIndex = index;
                });
              },
              onSaveCard: _saveCard,
              isLoading: isLoading,
            )
          ],
        ),
      ),
    );
  }
}

class CreditCardForm extends StatelessWidget {
  const CreditCardForm({
    super.key,
    required this.cardNumber,
    required this.expireDate,
    required this.cvv,
    required this.holderName,
    required this.rememberMyCard,
    required this.backgroundImages,
    required this.selectedBackgroundIndex,
    required this.onTextChanged,
    required this.onRememberMyCardChanged,
    required this.onBackgroundChanged,
    required this.onSaveCard,
    required this.isLoading,
  });

  final TextEditingController cardNumber;
  final TextEditingController expireDate;
  final TextEditingController cvv;
  final TextEditingController holderName;
  final bool rememberMyCard;
  final List<String> backgroundImages;
  final int selectedBackgroundIndex;
  final void Function(String?) onTextChanged;
  final void Function(bool v) onRememberMyCardChanged;
  final void Function(int) onBackgroundChanged;
  final VoidCallback onSaveCard;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDefaults.padding),
      margin: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: AppDefaults.borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Card Name"),
          const SizedBox(height: 8),
          TextFormField(
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            controller: holderName,
            onChanged: onTextChanged,
            decoration: const InputDecoration(
              hintText: 'Enter card holder name',
            ),
          ),
          const SizedBox(height: AppDefaults.padding),
          const Text("Card Number"),
          const SizedBox(height: 8),
          TextFormField(
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            controller: cardNumber,
            onChanged: onTextChanged,
            maxLength: 19,
            decoration: const InputDecoration(
              hintText: '1234 5678 9012 3456',
              counterText: '',
            ),
          ),
          const SizedBox(height: AppDefaults.padding),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Expire Date"),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      controller: expireDate,
                      onChanged: onTextChanged,
                      decoration: const InputDecoration(
                        hintText: 'MM/YY',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDefaults.padding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("CVV"),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      controller: cvv,
                      onChanged: onTextChanged,
                      maxLength: 4,
                      decoration: const InputDecoration(
                        hintText: '123',
                        counterText: '',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDefaults.padding),

          // 卡片背景选择
          const Text("Card Design"),
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: backgroundImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => onBackgroundChanged(index),
                  child: Container(
                    width: 80,
                    height: 50,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedBackgroundIndex == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: selectedBackgroundIndex == index ? 2 : 1,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(backgroundImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppDefaults.padding),
          Row(
            children: [
              Text(
                'Remember My Card Details',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Transform.scale(
                scale: 0.8,
                child: CupertinoSwitch(
                  value: rememberMyCard,
                  onChanged: onRememberMyCardChanged,
                ),
              )
            ],
          ),
          const SizedBox(height: AppDefaults.padding),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSaveCard,
              child: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text('Add Card'),
            ),
          ),
          const SizedBox(height: AppDefaults.padding),
        ],
      ),
    );
  }
}