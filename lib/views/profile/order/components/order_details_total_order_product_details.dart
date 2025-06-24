import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' show min;

import '../../../../core/constants/constants.dart';
import '../../../../core/providers/order_provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/models/cart_item_model.dart';
import 'order_details_product_tile.dart';

class TotalOrderProductDetails extends StatelessWidget {
  const TotalOrderProductDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final order = orderProvider.currentOrder;
        if (order == null || order.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(AppDefaults.padding),
            child: Text('No products found'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Product Details',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                itemBuilder: (context, index) {
                  final cartItem = order.items[index];
                  return _OrderItemCard(
                    cartItem: cartItem,
                    onTap: () => _navigateToItemDetails(context, cartItem),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemCount: order.items.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToItemDetails(BuildContext context, dynamic cartItem) {
    // Determine if it's a bundle or product and navigate accordingly
    if (cartItem.type == CartItemType.bundle) {
      // Navigate to bundle product details page (more detailed than bundleDetailsPage)
      if (cartItem.bundleDetails != null) {
        Navigator.pushNamed(
          context,
          AppRoutes.bundleProduct,
          arguments: cartItem.bundleDetails, // Pass full bundle model
        );
      } else {
        // If no bundle details, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bundle details not available')),
        );
      }
    } else if (cartItem.type == CartItemType.product) {
      // Navigate to product details
      if (cartItem.productDetails != null) {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetails,
          arguments: cartItem.productDetails, // Pass full product model
        );
      } else {
        // If no product details, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product details not available')),
        );
      }
    }
  }
}

// New widget for fancy list item card
class _OrderItemCard extends StatefulWidget {
  const _OrderItemCard({required this.cartItem, required this.onTap});

  final dynamic cartItem;
  final VoidCallback onTap;

  @override
  State<_OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends State<_OrderItemCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 1.03 : 1.0,
        child: Material(
          elevation: 2,
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              leading: _buildImage(),
              title: Text(widget.cartItem.name),
              subtitle: Text('${widget.cartItem.weight} • ${widget.cartItem.quantity}x'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('\$${widget.cartItem.totalPrice.toStringAsFixed(2)}'),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.cartItem.coverImage.isNotEmpty
          ? Image.network(
              widget.cartItem.coverImage,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
            )
          : const Icon(Icons.shopping_basket, color: Colors.grey),
    );
  }
}
