import 'package:json_annotation/json_annotation.dart';

part 'payment_success_vo.g.dart';

@JsonSerializable()
class PaymentSuccessVO {
  final String invoiceNo;
  final int pointAmount;
  final String processByName;
  final String paymentDate;

  PaymentSuccessVO({
    required this.invoiceNo,
    required this.pointAmount,
    required this.processByName,
    required this.paymentDate,
  });

  factory PaymentSuccessVO.fromJson(Map<String, dynamic> json) =>
      _$PaymentSuccessVOFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentSuccessVOToJson(this);
}
