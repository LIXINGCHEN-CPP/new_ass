import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constants/constants.dart';
import 'add_to_cart_animation.dart';

class BuyNowRow extends StatefulWidget {
  const BuyNowRow({
    super.key,
    required this.quantity,
    required this.onAddToCart,
    required this.onCartButtonTap,
  });

  final int quantity;
  final Future<void> Function() onAddToCart;
  final VoidCallback onCartButtonTap;

  @override
  State<BuyNowRow> createState() => _BuyNowRowState();
}

class _BuyNowRowState extends State<BuyNowRow> {
  final GlobalKey _cartKey = GlobalKey();
  int _totalAdded = 0;

  Future<void> _handleAdd() async {
    await widget.onAddToCart();
    setState(() {
      _totalAdded += widget.quantity;
    });
    _runAnimation();
  }

  void _runAnimation() {
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    final size = MediaQuery.of(context).size;
    final start = Offset(size.width / 2, size.height / 2);
    final renderBox = _cartKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final end = renderBox.localToGlobal(renderBox.size.center(Offset.zero));

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => IgnorePointer(
        child: Stack(
          children: [
            AddToCartAnimation(
              start: start,
              end: end,
              count: widget.quantity,
              onComplete: () {
                entry.remove();
              },
            ),
          ],
        ),
      ),
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDefaults.padding,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              OutlinedButton(
                key: _cartKey,
                onPressed: widget.onCartButtonTap,
                child: SvgPicture.asset(AppIcons.shoppingCart),
              ),
              if (_totalAdded > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$_totalAdded',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppDefaults.padding),
          Expanded(
            child: ElevatedButton(
              onPressed: _handleAdd,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppDefaults.padding * 1.2),
              ),
              child: const Text('Add to Cart'),
            ),
          ),
        ],
      ),
    );
  }
}