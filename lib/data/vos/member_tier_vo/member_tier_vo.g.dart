// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_tier_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberTierVO _$MemberTierVOFromJson(Map<String, dynamic> json) => MemberTierVO(
  tier: TierVO.fromJson(json['tier'] as Map<String, dynamic>),
  currentBalance: (json['currentBalance'] as num).toDouble(),
  totalClaimRewards: (json['totalClaimRewards'] as num).toInt(),
);

Map<String, dynamic> _$MemberTierVOToJson(MemberTierVO instance) =>
    <String, dynamic>{
      'tier': instance.tier,
      'currentBalance': instance.currentBalance,
      'totalClaimRewards': instance.totalClaimRewards,
    };

TierVO _$TierVOFromJson(Map<String, dynamic> json) => TierVO(
  id: json['id'] as String,
  name: json['name'] as String,
  iconType: json['iconType'] as String?,
  minPoint: (json['minPoint'] as num).toDouble(),
  maxPoint: (json['maxPoint'] as num).toDouble(),
  colorCode: json['colorCode'] as String,
);

Map<String, dynamic> _$TierVOToJson(TierVO instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'iconType': instance.iconType,
  'minPoint': instance.minPoint,
  'maxPoint': instance.maxPoint,
  'colorCode': instance.colorCode,
};
