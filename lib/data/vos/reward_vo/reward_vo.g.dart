// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RewardVO _$RewardVOFromJson(Map<String, dynamic> json) => RewardVO(
  id: json['id'] as String?,
  name: json['name'] as String?,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  rewardType: json['rewardType'] as String?,
  requiredPoints: (json['requiredPoints'] as num?)?.toInt(),
  availableQuantity: (json['availableQuantity'] as num?)?.toInt(),
  redemptionId: json['redemptionId'] as String?,
);

Map<String, dynamic> _$RewardVOToJson(RewardVO instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'rewardType': instance.rewardType,
  'requiredPoints': instance.requiredPoints,
  'availableQuantity': instance.availableQuantity,
  'redemptionId': instance.redemptionId,
};
