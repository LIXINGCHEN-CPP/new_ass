import 'package:flutter/material.dart';

import '../../core/components/network_image.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/utils/ui_util.dart';
import '../cart/dialogs/delivered_successfull.dart';
import '../../core/routes/app_routes.dart';

class OrderSuccessfullPage extends StatelessWidget {
  const OrderSuccessfullPage({super.key});

  String? _getOrderId(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) return args;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(flex: 2),
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: const AspectRatio(
                aspectRatio: 1 / 1,
                child: NetworkImageWithLoader(
                  'https://i.imgur.com/Fj9gVGy.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Column(
              children: [
                Text(
                  'Order Placed Successfully',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppDefaults.padding),
                  child: Text(
                    'Thanks for your order. Your order has placed successfully. Please continue your order.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final orderId = _getOrderId(context);
                        UiUtil.openDialog(
                          context: context,
                          widget: DeliverySuccessfullDialog(orderId: orderId),
                        );
                      },
                      child: const Text('Continue'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDefaults.padding,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.myOrder);
                      },
                      child: const Text('Track Order'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
