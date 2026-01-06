import 'package:json_annotation/json_annotation.dart';

part 'reward_claim_success_vo.g.dart';

@JsonSerializable()
class RewardClaimSuccessVO {
  final String? rewardName;
  final String? description;
  final String? imageUrl;
  final String? redeemDate;
  final String? collectedDate;

  RewardClaimSuccessVO({
    required this.rewardName,
    required this.description,
    required this.imageUrl,
    required this.redeemDate,
    required this.collectedDate,
  });

  factory RewardClaimSuccessVO.fromJson(Map<String,dynamic>json)=>_$RewardClaimSuccessVOFromJson(json);

  Map<String,dynamic>toJson()=>_$RewardClaimSuccessVOToJson(this);
}
