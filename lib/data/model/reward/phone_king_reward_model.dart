import 'package:phone_king_customer/data/vos/reward_vo/reward_claim_success_vo/reward_claim_success_vo.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_details_vo/reward_details_vo.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_vo.dart';
import 'package:phone_king_customer/network/response/base_response.dart';

abstract class PhoneKingRewardModel {
  Future<BaseResponse<RewardDetailsVO>> getRewardDetails(String rewardId);

  Future<BaseResponse<List<RewardVO>>> getAllReward(
    String storeID,
    String rewardType,
  );

  Future<BaseResponse<List<RewardVO>>> getUsedRewards();

  Future<BaseResponse<List<RewardVO>>> redeemReward();

  Future<BaseResponse<void>> rewardRedeem(String rewardId);

  Future<BaseResponse<RewardClaimSuccessVO>> claimReward(
      String paymentKey,
      String password,
      String redemptionId,
      );
}
