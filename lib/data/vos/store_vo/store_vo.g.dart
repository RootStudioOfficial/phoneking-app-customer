// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreVO _$StoreVOFromJson(Map<String, dynamic> json) => StoreVO(
  id: json['id'] as String?,
  name: json['name'] as String?,
  logoUrl: json['logoUrl'] as String?,
  bannerUrl: json['bannerUrl'] as String?,
  rewards: (json['rewards'] as List<dynamic>?)
      ?.map((e) => RewardVO.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$StoreVOToJson(StoreVO instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'logoUrl': instance.logoUrl,
  'bannerUrl': instance.bannerUrl,
  'rewards': instance.rewards?.map((e) => e.toJson()).toList(),
};
