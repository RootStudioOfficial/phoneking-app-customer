import 'package:json_annotation/json_annotation.dart';

part 'banner_vo.g.dart';

@JsonSerializable()
class BannerVO {
  final String imageUrl;

  BannerVO({required this.imageUrl});

  factory BannerVO.fromJson(Map<String, dynamic> json) =>
      _$BannerVOFromJson(json);

  Map<String, dynamic> toJson() => _$BannerVOToJson(this);
}
