// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_details_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RewardDetailsVO _$RewardDetailsVOFromJson(Map<String, dynamic> json) =>
    RewardDetailsVO(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      rewardType: json['rewardType'] as String,
      requiredPoints: (json['requiredPoints'] as num).toInt(),
      availableQuantity: (json['availableQuantity'] as num).toInt(),
      store: json['store'] == null
          ? null
          : StoreVO.fromJson(json['store'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RewardDetailsVOToJson(RewardDetailsVO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'rewardType': instance.rewardType,
      'requiredPoints': instance.requiredPoints,
      'availableQuantity': instance.availableQuantity,
      'store': instance.store?.toJson(),
    };

