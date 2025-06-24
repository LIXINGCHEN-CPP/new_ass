import 'package:flutter/material.dart';
import '../../../core/components/app_radio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';

import '../../../core/components/app_back_button.dart';

class NewAddressPage extends StatefulWidget {
  const NewAddressPage({super.key});

  @override
  State<NewAddressPage> createState() => _NewAddressPageState();
}

class _NewAddressPageState extends State<NewAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  bool _isDefaultAddress = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      // Combine address lines
      String fullAddress = _addressLine1Controller.text.trim();
      if (_addressLine2Controller.text.trim().isNotEmpty) {
        fullAddress += ', ${_addressLine2Controller.text.trim()}';
      }
      if (_cityController.text.trim().isNotEmpty) {
        fullAddress += ', ${_cityController.text.trim()}';
      }
      if (_stateController.text.trim().isNotEmpty) {
        fullAddress += ', ${_stateController.text.trim()}';
      }
      if (_zipCodeController.text.trim().isNotEmpty) {
        fullAddress += ' ${_zipCodeController.text.trim()}';
      }

      // Create address data to return
      final addressData = {
        'label': _fullNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': fullAddress,
      };

      // Return the address data to the previous page
      Navigator.pop(context, addressData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text(
          'New Address',
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(AppDefaults.padding),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDefaults.padding,
            vertical: AppDefaults.padding * 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: AppDefaults.borderRadius,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* <----  Full Name -----> */
                const Text("Full Name"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDefaults.padding),

                /* <---- Phone Number -----> */
                const Text("Phone Number"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDefaults.padding),

                /* <---- Address Line 1 -----> */
                const Text("Address Line 1"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressLine1Controller,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter address line 1';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDefaults.padding),

                /* <---- Address Line 2 -----> */
                const Text("Address Line 2 (Optional)"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressLine2Controller,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppDefaults.padding),

                /* <---- City -----> */
                const Text("City"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cityController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDefaults.padding),

                /* <---- State and Zip Code -----> */
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("State"),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _stateController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your state';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDefaults.padding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Zip Code"),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _zipCodeController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter zip code';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDefaults.padding),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isDefaultAddress = !_isDefaultAddress;
                      });
                    },
                    child: Row(
                      children: [
                        AppRadio(isActive: _isDefaultAddress),
                        const SizedBox(width: AppDefaults.padding),
                        const Text('Make Default Shipping Address'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDefaults.padding),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveAddress,
                    child: const Text('Save Address'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}