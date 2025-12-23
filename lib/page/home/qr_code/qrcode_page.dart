import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:phone_king_customer/data/vos/qr_payload_vo/qr_payload_vo.dart';
import 'package:phone_king_customer/persistent/login_persistent.dart';
import 'package:phone_king_customer/utils/localization_strings.dart';
import 'package:phone_king_customer/widgets/qr_info_widget.dart';

class QrCodePage extends StatefulWidget {
  const QrCodePage({super.key});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  final LoginPersistent loginPersistent = LoginPersistent();
  QrPayloadVO? _qrPayloadVO;

  @override
  void initState() {
    super.initState();
    loginPersistent.getLoginData().then((data) {
      if (!mounted) return;
      setState(() {
        _qrPayloadVO = QrPayloadVO.create(
          data: QrDataVO(
            userId: data?.id ?? '',
            userName: data?.displayName ?? '',
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationString.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          l10n.homeQrCode,
          style: _QrTextStyles.appBarTitle,
        ),
      ),
      body: _qrPayloadVO == null
          ? const Center(child: CircularProgressIndicator())
          : QrInfoWidget(qrData: jsonEncode(_qrPayloadVO!.toJson())),
    );
  }
}

// ========= Typography =========

class _QrTextStyles {
  static const appBarTitle = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 18,
    color: Color(0xFF0F172A),
  );
}
