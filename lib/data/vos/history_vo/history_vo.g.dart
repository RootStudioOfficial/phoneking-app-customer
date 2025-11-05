// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoryVO _$HistoryVOFromJson(Map<String, dynamic> json) => HistoryVO(
  transactionType: json['transactionType'] as String,
  description: json['description'] as String,
  txnDate: json['txnDate'] as String,
  totalPoints: (json['totalPoints'] as num).toInt(),
);

Map<String, dynamic> _$HistoryVOToJson(HistoryVO instance) => <String, dynamic>{
  'transactionType': instance.transactionType,
  'description': instance.description,
  'txnDate': instance.txnDate,
  'totalPoints': instance.totalPoints,
};
