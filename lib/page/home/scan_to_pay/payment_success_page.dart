import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/vos/payment_success_vo/payment_success_vo.dart';
import 'package:phone_king_customer/page/index_page.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';

class PaymentSuccessPage extends StatelessWidget {
  final PaymentSuccessVO paymentData;

  const PaymentSuccessPage({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Success Payment',
          style: _PaymentSuccessTextStyles.appBarTitle,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Success Icon
                  Image.asset(
                    AssetImageUtils.paymentSuccessfulIcon,
                    width: 180,
                    height: 180,
                  ),

                  const SizedBox(height: 32),

                  // Success Message
                  const Text(
                    'Payment Completed Successfully.',
                    style: _PaymentSuccessTextStyles.successTitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Payment Preview Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Payment Preview',
                            style: _PaymentSuccessTextStyles.cardTitle,
                          ),
                        ),

                        // Divider
                        Divider(height: 1, color: Colors.grey[200]),

                        // Payment Details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                label: 'Payment at',
                                value: paymentData.processByName,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                label: 'Payment Date',
                                value: paymentData.paymentDate,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                label: 'Used Points',
                                value: paymentData.pointAmount.toString(),
                                valueColor: Colors.deepOrange,
                                highlight: true,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                label: 'Invoice No',
                                value: paymentData.invoiceNo,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Go Back Home Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.navigateToNextPageWithRemoveUntil(IndexPage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Go Back Home',
                  style: _PaymentSuccessTextStyles.buttonText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
    bool highlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _PaymentSuccessTextStyles.detailLabel,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: (highlight
                ? _PaymentSuccessTextStyles.detailValueHighlight
                : _PaymentSuccessTextStyles.detailValue)
                .copyWith(color: valueColor ?? Colors.black),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ========= Typography helper =========

class _PaymentSuccessTextStyles {
  static const appBarTitle = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static const successTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: Colors.black,
  );

  static const cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  static const detailLabel = TextStyle(
    fontSize: 14,
    color: Color(0xFF6B7280),
    fontWeight: FontWeight.w500,
  );

  static const detailValue = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const detailValueHighlight = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.deepOrange,
  );

  static const buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
}
