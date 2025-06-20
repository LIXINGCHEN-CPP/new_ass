import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/components/app_radio.dart';
import '../../../core/constants/constants.dart';
import '../../../core/routes/app_routes.dart';

class AddressPage extends StatelessWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Updated to match checkout page addresses
    final addresses = [
      {
        'label': 'Bell Suites',
        'phoneNumber': '(60) 123-627-496',
        'address': '10-02, Bell Suites, Kota Warisan',
      },
      {
        'label': 'Xiamen University Malaysia',
        'phoneNumber': '(60) 11-2423-4875',
        'address': 'Jalan Sunsuria, Bandar Sunsuria',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text(
          'Delivery Address',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          children: [
            // Address list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return AddressTile(
                  label: address['label']!,
                  phoneNumber: address['phoneNumber']!,
                  address: address['address']!,
                  isActive: index == 1, // Xiamen University Malaysia is active by default
                  onTap: () {
                    // Handle address selection
                  },
                );
              },
            ),
            
            const SizedBox(height: AppDefaults.padding * 2),
            
            // Add new address button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.newAddress);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Address'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddressTile extends StatelessWidget {
  const AddressTile({
    super.key,
    required this.label,
    required this.phoneNumber,
    required this.address,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String phoneNumber;
  final String address;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDefaults.padding / 2,
      ),
      child: Material(
        color: isActive
            ? AppColors.coloredBackground
            : AppColors.textInputBackground,
        borderRadius: AppDefaults.borderRadius,
        child: InkWell(
          borderRadius: AppDefaults.borderRadius,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppDefaults.padding),
            decoration: BoxDecoration(
              borderRadius: AppDefaults.borderRadius,
              border: Border.all(
                color: isActive ? AppColors.primary : Colors.grey,
                width: isActive ? 1 : 0.3,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppRadio(isActive: isActive),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        phoneNumber,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        // Handle edit
                        Navigator.pushNamed(context, AppRoutes.newAddress);
                      },
                      icon: SvgPicture.asset(AppIcons.edit),
                      constraints: const BoxConstraints(),
                      iconSize: 16,
                      tooltip: 'Edit Address',
                    ),
                    const SizedBox(height: AppDefaults.margin / 2),
                    IconButton(
                      onPressed: () {
                        // Handle delete with confirmation
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Address'),
                            content: Text('Are you sure you want to delete "$label" address?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('$label address deleted')),
                                  );
                                },
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: SvgPicture.asset(AppIcons.deleteOutline),
                      constraints: const BoxConstraints(),
                      iconSize: 16,
                      tooltip: 'Delete Address',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
