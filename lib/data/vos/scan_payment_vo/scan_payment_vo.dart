import 'package:json_annotation/json_annotation.dart';

part 'scan_payment_vo.g.dart';

@JsonSerializable()
class ScanPaymentVO {
  final String invoiceNo;
  final int pointAmount;
  final int currentBalance;
  final String qrType;
  final String processByName;

  ScanPaymentVO({
    required this.invoiceNo,
    required this.pointAmount,
    required this.currentBalance,
    required this.qrType,
    required this.processByName,
  });

  factory ScanPaymentVO.fromJson(Map<String, dynamic> json) =>
      _$ScanPaymentVOFromJson(json);

  Map<String, dynamic> toJson() => _$ScanPaymentVOToJson(this);
}
