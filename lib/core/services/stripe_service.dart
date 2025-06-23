import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../constants/api_constants.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  static StripeService get instance => _instance;
  
  StripeService._internal();

  /// Create payment link
  Future<StripePaymentLinkResponse?> createPaymentLink({
    required List items,
    required double totalAmount,
    String? userId,
    String currency = 'usd',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/payment/stripe/create-payment-link'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'items': items,
          'amount': (totalAmount * 100).round(), // Stripe uses cents
          'currency': currency,
          'userId': userId,
          'locale': 'en', // Set to English
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return StripePaymentLinkResponse.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error creating payment link: $e');
      return null;
    }
  }

  /// Simple redirect to payment page
  Future<bool> launchPaymentUrl(String paymentUrl) async {
    try {
      final Uri url = Uri.parse(paymentUrl);
      return await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Error launching payment URL: $e');
      return false;
    }
  }

  /// Show payment confirmation dialog
  Future<bool> showPaymentDialog(BuildContext context, double amount) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Confirm Open Stripe?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.network(
                      'https://img.picui.cn/free/2025/06/24/6859892f74afc.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.payment, color: Colors.blue, size: 48);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ) ?? false;
  }
}

/// Stripe payment link response
class StripePaymentLinkResponse {
  final String paymentUrl;
  final String sessionId;
  final String status;

  StripePaymentLinkResponse({
    required this.paymentUrl,
    required this.sessionId,
    required this.status,
  });

  factory StripePaymentLinkResponse.fromJson(Map<String, dynamic> json) {
    return StripePaymentLinkResponse(
      paymentUrl: json['paymentUrl'] ?? '',
      sessionId: json['sessionId'] ?? '',
      status: json['status'] ?? '',
    );
  }
} 