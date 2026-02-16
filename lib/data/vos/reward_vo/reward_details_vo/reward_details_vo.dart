import 'package:json_annotation/json_annotation.dart';
import 'package:phonekingcustomer/data/vos/store_vo/store_vo.dart';

part 'reward_details_vo.g.dart';

@JsonSerializable(explicitToJson: true)
class RewardDetailsVO {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String rewardType;
  final int requiredPoints;
  final int ?availableQuantity;
  final StoreVO? store;

  RewardDetailsVO({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.rewardType,
    required this.requiredPoints,
    required this.availableQuantity,
    this.store,
  });

  factory RewardDetailsVO.fromJson(Map<String, dynamic> json) =>
      _$RewardDetailsVOFromJson(json);

  Map<String, dynamic> toJson() => _$RewardDetailsVOToJson(this);

  RewardDetailsVO copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? rewardType,
    int? requiredPoints,
    int? availableQuantity,
    StoreVO? store,
  }) {
    return RewardDetailsVO(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rewardType: rewardType ?? this.rewardType,
      requiredPoints: requiredPoints ?? this.requiredPoints,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      store: store ?? this.store,
    );
  }
}
