import 'package:json_annotation/json_annotation.dart';

part 'history_vo.g.dart';

@JsonSerializable()
class HistoryVO {
  final String transactionType;
  final String description;
  final String txnDate;
  final int totalPoints;

  HistoryVO({
    required this.transactionType,
    required this.description,
    required this.txnDate,
    required this.totalPoints,
  });

  factory HistoryVO.fromJson(Map<String, dynamic> json) =>
      _$HistoryVOFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryVOToJson(this);
}
