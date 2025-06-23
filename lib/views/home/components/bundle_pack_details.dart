import 'package:flutter/material.dart';

import '../../../core/components/network_image.dart';
import '../../../core/constants/constants.dart';
import '../../../core/models/bundle_model.dart';

class PackDetails extends StatelessWidget {
  const PackDetails({
    super.key,
    required this.bundle,
  });

  final BundleModel bundle;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.25),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pack Details',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
            ),
          ),
          /* <---- Items here -----> */
          // If there are specific product details, show product details
          if (bundle.items.isNotEmpty) ...[
            ...bundle.items.map((item) => ListTile(
              leading: AspectRatio(
                aspectRatio: 1 / 1,
                child: NetworkImageWithLoader(
                  item.productDetails?.coverImage ?? 'https://i.imgur.com/Y0IFT2g.png',
                ),
              ),
              title: Text(item.productDetails?.name ?? 'Unknown Product'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Qty: ${item.quantity}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black),
                  ),
                  if (item.productDetails?.weight != null)
                    Text(
                      item.productDetails!.weight,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                ],
              ),
            )),
          ] else ...[
            // If there's no detailed product information, show mock data
            ...List.generate(
              bundle.itemNames.length.clamp(1, 5),
              (index) => ListTile(
                leading: const AspectRatio(
                  aspectRatio: 1 / 1,
                  child: NetworkImageWithLoader('https://i.imgur.com/Y0IFT2g.png'),
                ),
                title: Text(
                  index < bundle.itemNames.length 
                      ? bundle.itemNames[index].split('(')[0].trim()
                      : 'Cabbage'
                ),
                trailing: Text(
                  '2 Kg',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.black),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppDefaults.padding),
        ],
      ),
    );
  }
}
