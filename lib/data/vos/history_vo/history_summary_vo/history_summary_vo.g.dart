// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_summary_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistorySummaryVO _$HistorySummaryVOFromJson(Map<String, dynamic> json) =>
    HistorySummaryVO(
      pointSpend: (json['pointSpend'] as num).toInt(),
      pointEarned: (json['pointEarned'] as num).toInt(),
    );

Map<String, dynamic> _$HistorySummaryVOToJson(HistorySummaryVO instance) =>
    <String, dynamic>{
      'pointSpend': instance.pointSpend,
      'pointEarned': instance.pointEarned,
    };
