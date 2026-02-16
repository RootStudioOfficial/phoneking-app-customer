import 'package:json_annotation/json_annotation.dart';

part 'qr_payload_vo.g.dart';

const _expectedAppName = 'PhoneKing Plus';

@JsonSerializable(explicitToJson: true)
class QrPayloadVO {
  final String app;
  final String generatedAt;
  final String expiresAt;
  final QrDataVO data;

  QrPayloadVO({
    required this.app,
    required this.generatedAt,
    required this.expiresAt,
    required this.data,
  });

  factory QrPayloadVO.fromJson(Map<String, dynamic> json) =>
      _$QrPayloadVOFromJson(json);

  Map<String, dynamic> toJson() => _$QrPayloadVOToJson(this);

  static QrPayloadVO create({
    required QrDataVO data,
    Duration expiryDuration = const Duration(minutes: 5),
  }) {
    final now = DateTime.now().toUtc();
    final expires = now.add(expiryDuration);

    return QrPayloadVO(
      app: _expectedAppName,
      generatedAt: now.toIso8601String(),
      expiresAt: expires.toIso8601String(),
      data: data,
    );
  }

  bool get isExpired {
    final expireTime = DateTime.parse(expiresAt);
    return DateTime.now().toUtc().isAfter(expireTime);
  }

  bool get isValidApp => app == _expectedAppName;
}

@JsonSerializable(explicitToJson: true)
class QrDataVO {
  final String? redemptionConfirmId;
  final String? userId;
  final String? userName;
  final String? paymentKey;

  QrDataVO({
    this.redemptionConfirmId,
    this.userId,
    this.userName,
    this.paymentKey,
  });

  factory QrDataVO.fromJson(Map<String, dynamic> json) =>
      _$QrDataVOFromJson(json);

  Map<String, dynamic> toJson() => _$QrDataVOToJson(this);
}
