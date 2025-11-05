// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faq_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FaqVO _$FaqVOFromJson(Map<String, dynamic> json) => FaqVO(
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  version: (json['version'] as num?)?.toInt(),
  id: json['id'] as String?,
  question: json['question'] as String?,
  answer: json['answer'] as String?,
);

Map<String, dynamic> _$FaqVOToJson(FaqVO instance) => <String, dynamic>{
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
  'version': instance.version,
  'id': instance.id,
  'question': instance.question,
  'answer': instance.answer,
};
