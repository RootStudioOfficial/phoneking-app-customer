// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_payment_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScanPaymentVO _$ScanPaymentVOFromJson(Map<String, dynamic> json) =>
    ScanPaymentVO(
      invoiceNo: json['invoiceNo'] as String,
      pointAmount: (json['pointAmount'] as num).toInt(),
      currentBalance: (json['currentBalance'] as num).toInt(),
      qrType: json['qrType'] as String,
      processByName: json['processByName'] as String,
    );

Map<String, dynamic> _$ScanPaymentVOToJson(ScanPaymentVO instance) =>
    <String, dynamic>{
      'invoiceNo': instance.invoiceNo,
      'pointAmount': instance.pointAmount,
      'currentBalance': instance.currentBalance,
      'qrType': instance.qrType,
      'processByName': instance.processByName,
    };
