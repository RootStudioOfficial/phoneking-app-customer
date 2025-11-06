import 'dart:io';

import 'package:phone_king_customer/data/vos/member_tier_vo/member_tier_vo.dart';
import 'package:phone_king_customer/data/vos/user_vo/user_vo.dart';
import 'package:phone_king_customer/network/response/base_response.dart';

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
      String phoneNumber,
  );

  Future<BaseResponse<String>> uploadFile(File file, String folder);
}
