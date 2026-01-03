import 'package:json_annotation/json_annotation.dart';

part 'reward_vo.g.dart';

@JsonSerializable()
class RewardVO {
  final String? id;
  final String? name;
  final String? description;
  final String? imageUrl;
  final String? rewardType;
  final int? requiredPoints;
  final int? availableQuantity;
  final String? redemptionId;

  RewardVO({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.rewardType,
    required this.requiredPoints,
    required this.availableQuantity,
    this.redemptionId,
  });

  factory RewardVO.fromJson(Map<String, dynamic> json) => _$RewardVOFromJson(json);

  Map<String, dynamic> toJson() => _$RewardVOToJson(this);

  RewardVO copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? rewardType,
    int? requiredPoints,
    int? availableQuantity,
  }) {
    return RewardVO(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rewardType: rewardType ?? this.rewardType,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      availableQuantity: availableQuantity ?? this.availableQuantity,
    );
  }
}
