import 'package:phonekingcustomer/data/model/reward/phone_king_reward_model.dart';
import 'package:phonekingcustomer/data/vos/reward_vo/reward_claim_success_vo/reward_claim_success_vo.dart';
import 'package:phonekingcustomer/data/vos/reward_vo/reward_details_vo/reward_details_vo.dart';
import 'package:phonekingcustomer/data/vos/reward_vo/reward_vo.dart';
import 'package:phonekingcustomer/network/api/phone_king_api.dart';
import 'package:phonekingcustomer/network/response/base_response.dart';

class PhoneKingRewardModelImpl implements PhoneKingRewardModel {
  final PhoneKingCustomerAPI _api = PhoneKingCustomerAPI();

  @override
  Future<BaseResponse<RewardDetailsVO>> getRewardDetails(String rewardId) {
    return _api.rewardDetails(rewardId);
  }

  @override
  Future<BaseResponse<List<RewardVO>>> getUsedRewards() {
    return _api.getUsedReward();
  }

  @override
  Future<BaseResponse<List<RewardVO>>> redeemReward() {
    return _api.getRedeemReward();
  }

  @override
  Future<BaseResponse<void>> rewardRedeem(String rewardId) {
    return _api.rewardRedeem(rewardId);
  }

  @override
  Future<BaseResponse<List<RewardVO>>> getAllReward(
    String storeID,
    String ?rewardType,
  ) => _api.getAllReward(storeID, rewardType);

  @override
  Future<BaseResponse<RewardClaimSuccessVO>> claimReward(
    String paymentKey,
    String password,
    String redemptionId,
  ) => _api.claimReward(paymentKey, password, redemptionId);
}
