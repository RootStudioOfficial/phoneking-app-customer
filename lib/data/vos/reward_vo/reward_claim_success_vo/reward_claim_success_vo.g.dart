// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_claim_success_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RewardClaimSuccessVO _$RewardClaimSuccessVOFromJson(
  Map<String, dynamic> json,
) => RewardClaimSuccessVO(
  rewardName: json['rewardName'] as String?,
  description: json['description'] as String?,
  imageUrl: json['imageUrl'] as String?,
  redeemDate: json['redeemDate'] as String?,
  collectedDate: json['collectedDate'] as String?,
);

Map<String, dynamic> _$RewardClaimSuccessVOToJson(
  RewardClaimSuccessVO instance,
) => <String, dynamic>{
  'rewardName': instance.rewardName,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'redeemDate': instance.redeemDate,
  'collectedDate': instance.collectedDate,
};
