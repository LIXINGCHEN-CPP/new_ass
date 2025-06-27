// components/card_carousel.dart
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import '../../../../core/constants/app_defaults.dart';
import '../../../../core/models/card_model.dart';
import '../../../../core/services/selected_card_service.dart';

class CardCarousel extends StatefulWidget {
  final List<CardModel> cards;
  final Function(int)? onCardDeleted;
  final Function(CardModel)? onCardSelected;

  const CardCarousel({
    super.key,
    required this.cards,
    this.onCardDeleted,
    this.onCardSelected,
  });

  @override
  State<CardCarousel> createState() => _CardCarouselState();
}

class _CardCarouselState extends State<CardCarousel> {
  late PageController _pageController;
  int currentIndex = 0;
  CardModel? selectedCard;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _loadSelectedCard();
  }

  Future<void> _loadSelectedCard() async {
    final card = await SelectedCardService.getSelectedCard();
    if (mounted) {
      setState(() {
        selectedCard = card;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemCount: widget.cards.length,
            itemBuilder: (context, index) {
              final card = widget.cards[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: Stack(
                  children: [
                    CreditCardWidget(
                      cardNumber: card.cardNumber,
                      expiryDate: card.expiryDate,
                      cardHolderName: card.cardHolderName,
                      isHolderNameVisible: true,
                      backgroundNetworkImage: card.backgroundImage,
                      cvvCode: card.cvvCode,
                      showBackView: false,
                      cardType: CardType.visa,
                      onCreditCardWidgetChange: (v) {},
                      isChipVisible: false,
                    ),
                
                    if (_isCardSelected(card))
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                 
                    if (widget.cards.length > 1) 
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => _showDeleteDialog(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),

        
        if (widget.cards.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.cards.length,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: currentIndex == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

      
        Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.cards[currentIndex].cardHolderName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.cards[currentIndex].maskedCardNumber,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _selectCard(widget.cards[currentIndex]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCardSelected(widget.cards[currentIndex])
                        ? Colors.grey[300]
                        : Theme.of(context).primaryColor,
                    foregroundColor: _isCardSelected(widget.cards[currentIndex])
                        ? Colors.grey[600]
                        : Colors.white,
                  ),
                  child: Text(
                    _isCardSelected(widget.cards[currentIndex])
                        ? 'Selected'
                        : 'Select Card',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isCardSelected(CardModel card) {
    if (selectedCard == null) return false;
    return selectedCard!.cardNumber == card.cardNumber;
  }

  Future<void> _selectCard(CardModel card) async {
    await SelectedCardService.setSelectedCard(card);
    setState(() {
      selectedCard = card;
    });
    widget.onCardSelected?.call(card);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Card ending in ${card.cardNumber.substring(card.cardNumber.length - 4)} selected'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Card'),
          content: Text(
              'Are you sure you want to delete the card ending in ${widget.cards[index].cardNumber.substring(widget.cards[index].cardNumber.length - 4)}?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onCardDeleted?.call(index);
                
                if (currentIndex >= widget.cards.length - 1 && currentIndex > 0) {
                  setState(() {
                    currentIndex = currentIndex - 1;
                  });
                  _pageController.animateToPage(
                    currentIndex,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}