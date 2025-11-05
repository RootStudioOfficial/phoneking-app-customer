import 'package:json_annotation/json_annotation.dart';

part 'branches_vo.g.dart';

@JsonSerializable()
class BranchesVO {
  final String? id;
  final String? name;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final String? openingTime;

  BranchesVO({
    this.id,
    this.name,
    this.location,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.openingTime,
  });

  factory BranchesVO.fromJson(Map<String, dynamic> json) =>
      _$BranchesVOFromJson(json);

  Map<String, dynamic> toJson() => _$BranchesVOToJson(this);

  BranchesVO copyWith({
    String? id,
    String? name,
    String? location,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? openingTime,
  }) {
    return BranchesVO(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      openingTime: openingTime ?? this.openingTime,
    );
  }
}
