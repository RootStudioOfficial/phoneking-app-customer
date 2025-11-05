// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_us_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactUsVO _$ContactUsVOFromJson(Map<String, dynamic> json) => ContactUsVO(
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  version: (json['version'] as num?)?.toInt(),
  id: json['id'] as String?,
  contactType: json['contactType'] as String?,
  contact: json['contact'] as String?,
);

Map<String, dynamic> _$ContactUsVOToJson(ContactUsVO instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'version': instance.version,
      'id': instance.id,
      'contactType': instance.contactType,
      'contact': instance.contact,
    };
