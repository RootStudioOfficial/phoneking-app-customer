// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branches_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchesVO _$BranchesVOFromJson(Map<String, dynamic> json) => BranchesVO(
  id: json['id'] as String?,
  name: json['name'] as String?,
  location: json['location'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  phoneNumber: json['phoneNumber'] as String?,
  openingTime: json['openingTime'] as String?,
);

Map<String, dynamic> _$BranchesVOToJson(BranchesVO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location': instance.location,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phoneNumber': instance.phoneNumber,
      'openingTime': instance.openingTime,
    };
