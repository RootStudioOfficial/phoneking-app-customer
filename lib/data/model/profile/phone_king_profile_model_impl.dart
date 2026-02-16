import 'dart:io';

import 'package:phonekingcustomer/data/model/profile/phone_king_profile_model.dart';
import 'package:phonekingcustomer/data/vos/member_tier_vo/member_tier_vo.dart';
import 'package:phonekingcustomer/data/vos/user_vo/user_vo.dart';
import 'package:phonekingcustomer/network/api/phone_king_api.dart';
import 'package:phonekingcustomer/network/response/base_response.dart';

class PhoneKingProfileModelImpl implements PhoneKingProfileModel {
  final PhoneKingCustomerAPI _api = PhoneKingCustomerAPI();

  @override
  Future<BaseResponse<void>> changePassword(
    String newPassword,
    String oldPassword,
  ) {
    return _api.changePassword(newPassword, oldPassword);
  }

  @override
  Future<BaseResponse<MemberTierVO>> getMemberTier() {
    return _api.getMemberTier();
  }

  @override
  Future<BaseResponse<UserVO>> getProfile() {
    return _api.getProfile();
  }

  @override
  Future<BaseResponse<void>> updateProfile(
    String profileImageUrl,
    String displayName,
  ) {
    return _api.updateProfile(profileImageUrl, displayName);
  }

  @override
  Future<BaseResponse<String>> uploadFile(File file, String folder) {
    return _api.uploadFile(file, folder);
  }

  @override
  Future<BaseResponse<void>> deleteProfile() {
    return _api.deleteProfile();
  }
}
