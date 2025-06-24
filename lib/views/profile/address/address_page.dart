import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/components/app_back_button.dart';
import '../../../core/components/app_radio.dart';
import '../../../core/constants/constants.dart';
import '../../../core/routes/app_routes.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  int selectedAddressIndex = 1; // Default selected address index

  // Updated to match checkout page addresses
  List<Map<String, String>> addresses = [
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

  void _selectAddress(int index) {
    setState(() {
      selectedAddressIndex = index;
    });
  }

  void _deleteAddress(int index) {
    setState(() {
      addresses.removeAt(index);
      // Adjust selected index if necessary
      if (selectedAddressIndex >= addresses.length && addresses.isNotEmpty) {
        selectedAddressIndex = addresses.length - 1;
      } else if (addresses.isEmpty) {
        selectedAddressIndex = -1;
      } else if (selectedAddressIndex == index && index > 0) {
        selectedAddressIndex = index - 1;
      }
    });
  }

  void _addNewAddress() async {
    final result = await Navigator.pushNamed(context, AppRoutes.newAddress);
    if (result != null && result is Map<String, String>) {
      setState(() {
        addresses.add(result);
        // Optionally select the newly added address
        selectedAddressIndex = addresses.length - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            if (addresses.isNotEmpty)
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
                    isActive: index == selectedAddressIndex,
                    onTap: () => _selectAddress(index),
                    onDelete: () => _deleteAddress(index),
                  );
                },
              )
            else
              Container(
                padding: const EdgeInsets.all(AppDefaults.padding * 2),
                child: Column(
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No addresses found',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first delivery address',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppDefaults.padding * 2),

            // Add new address button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addNewAddress,
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
    required this.onDelete,
  });

  final String label;
  final String phoneNumber;
  final String address;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

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
                        // Handle edit - you can implement edit functionality here
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
                                  onDelete();
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