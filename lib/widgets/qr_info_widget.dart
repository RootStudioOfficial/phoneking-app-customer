import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrInfoWidget extends StatelessWidget {
  const QrInfoWidget({super.key, required this.qrData});

  final String qrData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      children: [
        // QR card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECECEC)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: QrImageView(
                data: qrData.isEmpty ? '—' : qrData,
                version: QrVersions.auto,
                // size is driven by FittedBox + AspectRatio
                gapless: true,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Caption
        Center(
          child: Text(
            'Show this QR code to customer to scan to claim',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ),
        const SizedBox(height: 14),

        // Scanning Tips card
        Container(
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
              _Bullet('Use the flashlight for better visibility in low light'),
            ],
          ),
        ),
      ],
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
