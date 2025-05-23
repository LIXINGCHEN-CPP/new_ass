import 'package:flutter/material.dart';

import '../../../core/components/title_and_action_button.dart';
import 'checkout_address_card.dart';

class AddressSelector extends StatelessWidget {
  const AddressSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleAndActionButton(
          title: 'Select Delivery Address',
          actionLabel: 'Add New',
          onTap: () {},
          isHeadline: false,
        ),
        AddressCard(
          label: 'Bell Suites',
          phoneNumber: '(60) 123-627-496',
          address: '10-02, Bell Suites, Kota Warisan',
          isActive: false,
          onTap: () {},
        ),
        AddressCard(
          label: 'Xiamen University Malaysia',
          phoneNumber: '(60) 11-2423-4875',
          address: 'Jalan Sunsuria, Bandar Sunsuria',
          isActive: true,
          onTap: () {},
        )
      ],
    );
  }
}
