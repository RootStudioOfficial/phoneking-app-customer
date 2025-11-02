import 'package:json_annotation/json_annotation.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_vo.dart';

part 'store_vo.g.dart';

@JsonSerializable(explicitToJson: true)
class StoreVO {
  final String? id;
  final String? name;
  final String? logoUrl;
  final String? bannerUrl;
  final List<RewardVO>? rewards;

  StoreVO({
    required this.id,
    required this.name,
    this.logoUrl,
    this.bannerUrl,
    this.rewards,
  });

  factory StoreVO.fromJson(Map<String, dynamic> json) =>
      _$StoreVOFromJson(json);

  Map<String, dynamic> toJson() => _$StoreVOToJson(this);

  StoreVO copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? bannerUrl,
    List<RewardVO>? rewards,
  }) {
    return StoreVO(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      rewards: rewards ?? this.rewards,
    );
  }
}