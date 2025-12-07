import 'package:json_annotation/json_annotation.dart';

part 'app_update_config_vo.g.dart';

@JsonSerializable()
class AppUpdateConfigVO {
  final bool mandatoryUpdate;
  final bool optionalUpdateAvailable;
  final int minimumVersionCode;
  final int recommendedVersionCode;
  final String storeUrl;
  final String updateMessage;

  AppUpdateConfigVO({
    required this.mandatoryUpdate,
    required this.optionalUpdateAvailable,
    required this.minimumVersionCode,
    required this.recommendedVersionCode,
    required this.storeUrl,
    required this.updateMessage,
  });

  factory AppUpdateConfigVO.fromJson(Map<String, dynamic> json) =>
      _$AppUpdateConfigVOFromJson(json);

  Map<String, dynamic> toJson() => _$AppUpdateConfigVOToJson(this);
}
