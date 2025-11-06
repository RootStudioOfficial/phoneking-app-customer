import 'package:flutter/material.dart';
import 'package:phone_king_customer/page/home/scan_to_pay/payment_details_page.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/widgets/scan_qr_widget.dart';

class PaymentQrScanPage extends StatefulWidget {
  const PaymentQrScanPage({super.key});

  @override
  State<PaymentQrScanPage> createState() => _PaymentQrScanPageState();
}

class _PaymentQrScanPageState extends State<PaymentQrScanPage> {
  @override
  Widget build(BuildContext context) {
    return ScanQrWidget(
      title: 'Scan to Pay',
      onDetect: (payload) {
        context.navigateToNextPage(
          PaymentDetailsPage(keyQR: payload.data.paymentKey ?? ''),
        );
      },
    );
  }
}
