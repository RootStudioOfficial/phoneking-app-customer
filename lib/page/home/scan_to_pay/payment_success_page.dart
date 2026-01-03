import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/vos/payment_success_vo/payment_success_vo.dart';
import 'package:phone_king_customer/page/index_page.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/utils/localization_strings.dart';

class PaymentSuccessPage extends StatelessWidget {
  final PaymentSuccessVO paymentData;

  const PaymentSuccessPage({super.key, required this.paymentData});

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        // prevent accidental back
        title: Text(l10n.paymentSuccessTitle, style: _PaymentSuccessTextStyles.appBarTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  /// Success icon
                  Image.asset(AssetImageUtils.paymentSuccessfulIcon, width: 180, height: 180),

                  const SizedBox(height: 20),

                  /// Success message
                  Text(l10n.paymentSuccessPaymentCompletedSuccessfully, style: _PaymentSuccessTextStyles.successTitle, textAlign: TextAlign.center),

                  const SizedBox(height: 24),

                  /// Preview card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Header
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(l10n.paymentSuccessPreview, style: _PaymentSuccessTextStyles.cardTitle),
                        ),

                        Divider(height: 1, color: Colors.grey[200]),

                        /// Details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildDetailRow(label: l10n.paymentSuccessPaymentAt, value: paymentData.processByName),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                label: l10n.paymentSuccessPaymentDate,
                                value: DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.parse(paymentData.paymentDate).toUtc()),
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                label: l10n.paymentSuccessUsedPoints,
                                value: paymentData.pointAmount.toString(),
                                valueColor: Colors.deepOrange,
                                highlight: true,
                              ),
                              const SizedBox(height: 16),
                              _buildDetailRow(label: l10n.paymentSuccessInvoiceNo, value: paymentData.invoiceNo),
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

          /// Go home button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.navigateToNextPageWithRemoveUntil(const IndexPage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(l10n.paymentSuccessGoHome, style: _PaymentSuccessTextStyles.buttonText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value, Color? valueColor, bool highlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _PaymentSuccessTextStyles.detailLabel),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: (highlight ? _PaymentSuccessTextStyles.detailValueHighlight : _PaymentSuccessTextStyles.detailValue).copyWith(
              color: valueColor ?? Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

// ========= Typography helper =========

class _PaymentSuccessTextStyles {
  static const appBarTitle = TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800);

  static const successTitle = TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black);

  static const cardTitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black);

  static const detailLabel = TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w500);

  static const detailValue = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black);

  static const detailValueHighlight = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.deepOrange);

  static const buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white);
}
