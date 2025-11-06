import 'package:flutter/material.dart';
import 'package:phone_king_customer/page/reward/reward_enter_pin_page.dart';
import 'package:phone_king_customer/utils/extensions/navigation_extensions.dart';
import 'package:phone_king_customer/widgets/scan_qr_widget.dart';

class RewardScanQrCodePage extends StatefulWidget {
  const RewardScanQrCodePage({super.key});

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
            redemptionConfirmId: payload.data.redemptionConfirmId ?? '',
          ),
        );
      },
    );
  }
}
