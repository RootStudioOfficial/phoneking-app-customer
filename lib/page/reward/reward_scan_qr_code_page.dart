import 'package:flutter/material.dart';
import 'package:phonekingcustomer/page/reward/reward_enter_pin_page.dart';
import 'package:phonekingcustomer/utils/extensions/navigation_extensions.dart';
import 'package:phonekingcustomer/widgets/scan_qr_widget.dart';

class RewardScanQrCodePage extends StatefulWidget {
  const RewardScanQrCodePage({super.key, required this.redemptionId});

  final String redemptionId;

  @override
  State<RewardScanQrCodePage> createState() => _RewardScanQrCodePageState();
}

class _RewardScanQrCodePageState extends State<RewardScanQrCodePage> {
  @override
  Widget build(BuildContext context) {
    return ScanQrWidget(
      title: 'Scan QR Code',
      onDetect: (payload) {
        context.navigateToNextPage(
          RewardEnterPinPage(
            paymentKey: payload.data.paymentKey ?? '',
            redemptionId: widget.redemptionId,
          ),
        );
      },
    );
  }
}
