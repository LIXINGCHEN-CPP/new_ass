import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/constants.dart';

class CardDetails extends StatelessWidget {
  const CardDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Field
          const Text("Card Name"),
          const SizedBox(height: 8),
          TextFormField(
            keyboardType: TextInputType.name,
            initialValue: "Shirley Hart",
            // validator: Validators.requiredWithFieldName('Card'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppDefaults.padding),

          // Number Field
          const Text("Card Number"),
          const SizedBox(height: 8),
          TextFormField(
            keyboardType: TextInputType.number,
            initialValue: "1464 *** 5456",
            // validator: Validators.requiredWithFieldName('Card Number'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppDefaults.padding),

          /* <---- Expiration Date And CVV -----> */
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expiration Date Field
                    const Text("Expiration Date"),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: "10/28",
                      // validator: Validators.requiredWithFieldName('Card'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppDefaults.padding),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CVV Field
                    const Text("CVV"),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: "542",
                      // validator: Validators.requiredWithFieldName('Card'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppDefaults.padding),
                  ],
                ),
              ),
            ],
          ),

          Row(
            children: [
              Text(
                'Remember My Card Details',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.black),
              ),
              const Spacer(),
              CupertinoSwitch(value: true, onChanged: (v) {})
            ],
          )
        ],
      ),
    );
  }
}
