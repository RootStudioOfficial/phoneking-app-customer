class PhoneKingCustomerApi {
  static const String baseUrl = 'https://api-phoneking.up.railway.app/api/v1';

  // Auth
  static const String login = '$baseUrl/user/auth/login';
  static const String register = '$baseUrl/user/auth/register';
  static const String sendRegisterVerification =
      '$baseUrl/user/auth/register/verification/send';
  static const String confirmRegisterVerification =
      '$baseUrl/user/auth/register/verification/confirm';

  // Banner
  static const String banner = '$baseUrl/user/banner';

  //Point
  static const String getBalance = '$baseUrl/user/point/balance';

  //Store
  static const String store = '$baseUrl/user/store';

  //Reward
  static const String rewardAll = '$baseUrl/user/reward';
  static const String redeemReward = '$baseUrl/user/reward/redeem';
  static const String usedReward = '$baseUrl/user/reward/used';

  static String rewardDetails(String rewardID) =>
      '$baseUrl/user/reward/$rewardID';

  static String rewardRedeem(String rewardID) =>
      '$baseUrl/user/reward/$rewardID/redeem';

  static String claimReward(String redemptionConfirmId) =>
      '$baseUrl/user/reward/claim/$redemptionConfirmId';
}
