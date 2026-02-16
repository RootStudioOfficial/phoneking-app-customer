import 'dart:io';

import 'package:phonekingcustomer/data/vos/member_tier_vo/member_tier_vo.dart';
import 'package:phonekingcustomer/data/vos/user_vo/user_vo.dart';
import 'package:phonekingcustomer/network/response/base_response.dart';

abstract class PhoneKingProfileModel {
  Future<BaseResponse<UserVO>> getProfile();

  Future<BaseResponse<MemberTierVO>> getMemberTier();

  Future<BaseResponse<void>> changePassword(
    String newPassword,
    String oldPassword,
  );

  Future<BaseResponse<void>> updateProfile(
    String profileImageUrl,
    String displayName,
  );

  Future<BaseResponse<String>> uploadFile(File file, String folder);

  Future<BaseResponse<void>> deleteProfile();
}
