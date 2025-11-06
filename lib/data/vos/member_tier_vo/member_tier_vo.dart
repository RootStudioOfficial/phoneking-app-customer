import 'package:json_annotation/json_annotation.dart';

part 'member_tier_vo.g.dart';

@JsonSerializable()
class MemberTierVO {
  final TierVO tier;
  final double currentBalance;
  final int totalClaimRewards;

  MemberTierVO({
    required this.tier,
    required this.currentBalance,
    required this.totalClaimRewards,
  });

  factory MemberTierVO.fromJson(Map<String, dynamic> json) =>
      _$MemberTierVOFromJson(json);

  Map<String, dynamic> toJson() => _$MemberTierVOToJson(this);
}

@JsonSerializable()
class TierVO {
  final String id;
  final String name;
  final String? iconType;
  final double minPoint;
  final double maxPoint;
  final String colorCode;

  TierVO({
    required this.id,
    required this.name,
    this.iconType,
    required this.minPoint,
    required this.maxPoint,
    required this.colorCode,
  });

  factory TierVO.fromJson(Map<String, dynamic> json) =>
      _$TierVOFromJson(json);

  Map<String, dynamic> toJson() => _$TierVOToJson(this);
}
