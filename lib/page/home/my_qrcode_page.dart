import 'package:flutter/material.dart';
import 'package:phone_king_customer/utils/asset_image_utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQrCodePage extends StatelessWidget {
  const MyQrCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text('My QR  Code', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // QR card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6E8F0)),
              ),
              child: AspectRatio(aspectRatio: 1, child: _QrBox(data: "PHONEKING_USER_123456")),
            ),
            const SizedBox(height: 16),
            const Text(
              "Show this QR code to earn points from\npurchases and services",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF737B8C), height: 1.4, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

            // Tips card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE6E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Scanning Tips",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF101828)),
                  ),
                  const SizedBox(height: 8),
                  _bullet("Hold your phone steady and ensure good lighting"),
                  _bullet("Keep the QR code within scanning frame"),
                  _bullet("Use the flashlight for better visibility in low light"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Color(0xFFB3BAC7)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: Color(0xFF6B7280), height: 1.4)),
          ),
        ],
      ),
    );
  }
}

/// Extracted so we can gracefully fall back to an asset if qr_flutter
/// is not included yet.
class _QrBox extends StatelessWidget {
  final String data;

  const _QrBox({required this.data});

  @override
  Widget build(BuildContext context) {
    try {

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: Colors.white,
          child: Center(
            child: Image.asset("assets/demo_qr.png"),

            // QrImageView(
            //   data: data,
            //   version: QrVersions.auto,
            //   eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square),
            //   dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square),
            //   // Quiet zone keeps spacing from the border
            //   gapless: false,
            //   padding: const EdgeInsets.all(16),
            //   backgroundColor: Colors.white,
            // ),
          ),
        ),
      );
    } catch (_) {
      // Fallback without the package → use your asset icon
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: Colors.white,
          child: Center(child: Image.asset(AssetImageUtils.qrIcon, width: 160, height: 160, fit: BoxFit.contain)),
        ),
      );
    }
  }
}
