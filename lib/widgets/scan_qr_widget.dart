import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:phone_king_customer/data/vos/qr_payload_vo/qr_payload_vo.dart';
import 'package:phone_king_customer/utils/encrypt_utils.dart';
import 'package:phone_king_customer/utils/extensions/dialog_extensions.dart';

class ScanQrWidget extends StatefulWidget {
  const ScanQrWidget({super.key, required this.onDetect, required this.title});

  final Function(QrPayloadVO) onDetect;
  final String title;

  @override
  State<ScanQrWidget> createState() => _ScanQrWidgetState();
}

class _ScanQrWidgetState extends State<ScanQrWidget> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BuildContext context, BarcodeCapture capture) async {
    if (!isScanning) return;

    final raw = capture.barcodes
        .where((b) => b.format == BarcodeFormat.qrCode)
        .map((b) => b.rawValue)
        .firstWhere(
          (v) => v != null && v.trim().isNotEmpty,
          orElse: () => null,
        );

    if (raw == null) return;
    isScanning = false;

    try {
      final decrypted = EncryptUtils.decryptText(raw);

      final Map<String, dynamic> jsonMap = jsonDecode(decrypted);
      final payload = QrPayloadVO.fromJson(jsonMap);

      if (!payload.isValidApp) {
        throw Exception('Invalid app source');
      }
      if (payload.isExpired) {
        throw Exception('QR expired');
      }

      widget.onDetect(payload);
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar("Invalid QR: ${e.toString()}");
      }
    } finally {
      isScanning = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Camera/Scanner Area
          Container(
            height: 400,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.deepOrange, width: 3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Stack(
                children: [
                  // Camera Preview
                  MobileScanner(
                    controller: cameraController,
                    onDetect: (data) {
                      _onDetect(context, data);
                    },
                  ),

                  // Scanning Frame Overlay
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          // Top-left corner
                          Positioned(
                            top: 0,
                            left: 0,
                            child: _buildCorner(topLeft: true),
                          ),
                          // Top-right corner
                          Positioned(
                            top: 0,
                            right: 0,
                            child: _buildCorner(topRight: true),
                          ),
                          // Bottom-left corner
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: _buildCorner(bottomLeft: true),
                          ),
                          // Bottom-right corner
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: _buildCorner(bottomRight: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scanning Tips Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFECECEC)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scanning Tips',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _Bullet('Hold your phone steady and ensure good lighting'),
                _Bullet('Keep the QR code within scanning frame'),
                _Bullet(
                  'Use the flashlight for better visibility in low light',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border(
          top: (topLeft || topRight)
              ? BorderSide(color: Colors.deepOrange, width: 4)
              : BorderSide.none,
          bottom: (bottomLeft || bottomRight)
              ? BorderSide(color: Colors.deepOrange, width: 4)
              : BorderSide.none,
          left: (topLeft || bottomLeft)
              ? BorderSide(color: Colors.deepOrange, width: 4)
              : BorderSide.none,
          right: (topRight || bottomRight)
              ? BorderSide(color: Colors.deepOrange, width: 4)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: topLeft ? const Radius.circular(8) : Radius.zero,
          topRight: topRight ? const Radius.circular(8) : Radius.zero,
          bottomLeft: bottomLeft ? const Radius.circular(8) : Radius.zero,
          bottomRight: bottomRight ? const Radius.circular(8) : Radius.zero,
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).hintColor,
      height: 1.4,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 14, height: 1.5)),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}
