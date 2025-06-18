import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/constants.dart';

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
    this.minQuantity = 1,
    this.maxQuantity = 99,
  });

  final int quantity;
  final Function(int) onQuantityChanged;
  final int minQuantity;
  final int maxQuantity;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: quantity > minQuantity 
              ? () => onQuantityChanged(quantity - 1)
              : null,
          icon: SvgPicture.asset(AppIcons.removeQuantity),
          constraints: const BoxConstraints(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$quantity',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
        ),
        IconButton(
          onPressed: quantity < maxQuantity 
              ? () => onQuantityChanged(quantity + 1)
              : null,
          icon: SvgPicture.asset(AppIcons.addQuantity),
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
} 