// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_success_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentSuccessVO _$PaymentSuccessVOFromJson(Map<String, dynamic> json) =>
    PaymentSuccessVO(
      invoiceNo: json['invoiceNo'] as String,
      pointAmount: (json['pointAmount'] as num).toInt(),
      processByName: json['processByName'] as String,
      paymentDate: json['paymentDate'] as String,
    );

Map<String, dynamic> _$PaymentSuccessVOToJson(PaymentSuccessVO instance) =>
    <String, dynamic>{
      'invoiceNo': instance.invoiceNo,
      'pointAmount': instance.pointAmount,
      'processByName': instance.processByName,
      'paymentDate': instance.paymentDate,
    };
