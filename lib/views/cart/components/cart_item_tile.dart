import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/components/network_image.dart';
import '../../../core/components/quantity_selector.dart';
import '../../../core/constants/constants.dart';
import '../../../core/models/cart_item_model.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final CartItemModel cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDefaults.padding,
        vertical: AppDefaults.padding / 2,
      ),
      child: Row(
        children: [
          /// Product thumbnail
          SizedBox(
            width: 70,
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: NetworkImageWithLoader(
                cartItem.coverImage,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 16),

          /// Product information and quantity control
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name and weight
                Text(
                  cartItem.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.black),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  cartItem.weight,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                
                // Quantity selector
                QuantitySelector(
                  quantity: cartItem.quantity,
                  onQuantityChanged: onQuantityChanged,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),

          /// Price and delete button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                constraints: const BoxConstraints(),
                onPressed: onRemove,
                icon: SvgPicture.asset(AppIcons.delete),
              ),
              const SizedBox(height: 16),
              
              // Display price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (cartItem.originalPrice > cartItem.currentPrice) ...[
                    Text(
                      '\$${cartItem.originalPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                  Text(
                    '\$${cartItem.currentPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (cartItem.quantity > 1) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Total: \$${cartItem.totalPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
} 