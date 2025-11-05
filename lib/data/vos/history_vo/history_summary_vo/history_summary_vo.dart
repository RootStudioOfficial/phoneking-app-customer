import 'package:json_annotation/json_annotation.dart';

part 'history_summary_vo.g.dart';

@JsonSerializable()
class HistorySummaryVO {
  final int pointSpend;
  final int pointEarned;

  HistorySummaryVO({required this.pointSpend, required this.pointEarned});

  factory HistorySummaryVO.fromJson(Map<String, dynamic> json) =>
      _$HistorySummaryVOFromJson(json);

  Map<String, dynamic> toJson() => _$HistorySummaryVOToJson(this);
}
