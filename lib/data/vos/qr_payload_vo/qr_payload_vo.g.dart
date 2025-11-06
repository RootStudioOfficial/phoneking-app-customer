// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_payload_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QrPayloadVO _$QrPayloadVOFromJson(Map<String, dynamic> json) => QrPayloadVO(
  app: json['app'] as String,
  generatedAt: json['generatedAt'] as String,
  expiresAt: json['expiresAt'] as String,
  data: QrDataVO.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$QrPayloadVOToJson(QrPayloadVO instance) =>
    <String, dynamic>{
      'app': instance.app,
      'generatedAt': instance.generatedAt,
      'expiresAt': instance.expiresAt,
      'data': instance.data.toJson(),
    };

QrDataVO _$QrDataVOFromJson(Map<String, dynamic> json) => QrDataVO(
  redemptionConfirmId: json['redemptionConfirmId'] as String?,
  userId: json['userId'] as String?,
  userName: json['userName'] as String?,
  paymentKey: json['paymentKey'] as String?,
);

Map<String, dynamic> _$QrDataVOToJson(QrDataVO instance) => <String, dynamic>{
  'redemptionConfirmId': instance.redemptionConfirmId,
  'userId': instance.userId,
  'userName': instance.userName,
  'paymentKey': instance.paymentKey,
};
