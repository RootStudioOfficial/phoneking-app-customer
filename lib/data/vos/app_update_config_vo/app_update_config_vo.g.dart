// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update_config_vo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUpdateConfigVO _$AppUpdateConfigVOFromJson(Map<String, dynamic> json) =>
    AppUpdateConfigVO(
      mandatoryUpdate: json['mandatoryUpdate'] as bool,
      optionalUpdateAvailable: json['optionalUpdateAvailable'] as bool,
      minimumVersionCode: (json['minimumVersionCode'] as num).toInt(),
      recommendedVersionCode: (json['recommendedVersionCode'] as num).toInt(),
      storeUrl: json['storeUrl'] as String,
      updateMessage: json['updateMessage'] as String,
    );

Map<String, dynamic> _$AppUpdateConfigVOToJson(AppUpdateConfigVO instance) =>
    <String, dynamic>{
      'mandatoryUpdate': instance.mandatoryUpdate,
      'optionalUpdateAvailable': instance.optionalUpdateAvailable,
      'minimumVersionCode': instance.minimumVersionCode,
      'recommendedVersionCode': instance.recommendedVersionCode,
      'storeUrl': instance.storeUrl,
      'updateMessage': instance.updateMessage,
    };
