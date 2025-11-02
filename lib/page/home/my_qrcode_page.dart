import 'package:flutter/material.dart';
import 'package:phone_king_customer/widgets/qr_info_widget.dart';

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
        title: const Text(
          'My QR  Code',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: QrInfoWidget(qrData: "qrData"),
    );
  }
}
