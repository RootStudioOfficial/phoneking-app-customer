import 'package:phone_king_customer/data/vos/login_vo/login_vo.dart';
import 'package:phone_king_customer/network/response/base_response.dart';

abstract class PhoneKingAuthModel {
  Future<BaseResponse<LoginVO>> login({
    required String username,
    required String password,
  });

  Future<BaseResponse<LoginVO>> register({
    required String displayName,
    required String password,
    required String phoneNumber,
    required String birthday,
    String? referralCode,
  });

  Future<BaseResponse<void>> sendRegisterVerification({
    required String phoneNumber,
  });

  Future<BaseResponse<void>> confirmRegisterVerification({
    required String phoneNumber,
    required String otp,
  });

  Future<void> logout();
}
