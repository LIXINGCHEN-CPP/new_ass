import 'package:flutter/material.dart';

import '../../../core/components/title_and_action_button.dart';
import 'checkout_address_card.dart';

class AddressSelector extends StatefulWidget {
  const AddressSelector({super.key});

  @override
  State<AddressSelector> createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  int selectedIndex = 1; // default second address active

  final List<Map<String, String>> addresses = [
    {
      'label': 'Bell Suites',
      'phone': '(60) 123-627-496',
      'address': '10-02, Bell Suites, Kota Warisan',
    },
    {
      'label': 'Xiamen University Malaysia',
      'phone': '(60) 11-2423-4875',
      'address': 'Jalan Sunsuria, Bandar Sunsuria',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleAndActionButton(
          title: 'Select Delivery Address',
          actionLabel: 'Add New',
          onTap: () {
            // TODO: Navigate to add new address page
          },
          isHeadline: false,
        ),
        ...List.generate(addresses.length, (index) {
          final addr = addresses[index];
          return AddressCard(
            label: addr['label']!,
            phoneNumber: addr['phone']!,
            address: addr['address']!,
            isActive: selectedIndex == index,
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
          );
        }),
      ],
    );
  }
}
