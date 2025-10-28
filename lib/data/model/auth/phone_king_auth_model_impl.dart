import 'package:phone_king_customer/data/model/auth/phone_king_auth_model.dart';
import 'package:phone_king_customer/data/vos/login_vo/login_vo.dart';
import 'package:phone_king_customer/network/api/phone_king_api.dart';
import 'package:phone_king_customer/network/response/base_response.dart';
import 'package:phone_king_customer/persistent/login_persistent.dart';

class PhoneKingAuthModelImpl implements PhoneKingAuthModel {
  final PhoneKingCustomerAPI _api = PhoneKingCustomerAPI();

  @override
  Future<BaseResponse<LoginVO>> login({
    required String username,
    required String password,
  }) {
    return _api.login(username: username, password: password).then((res) {
      if (res.data != null) {
        LoginPersistent().saveLoginData(res.data!);
      }
      return res;
    });
  }

  @override
  Future<BaseResponse<void>> confirmRegisterVerification({
    required String phoneNumber,
    required String otp,
  }) => _api.confirmRegisterVerification(phoneNumber: phoneNumber, otp: otp);

  @override
  Future<BaseResponse<LoginVO>> register({
    required String displayName,
    required String password,
    required String phoneNumber,
    required String birthday,
    String? referralCode,
  }) => _api
      .register(
        displayName: displayName,
        password: password,
        phoneNumber: phoneNumber,
        birthday: birthday,
      )
      .then((res) {
        if (res.data != null) {
          LoginPersistent().saveLoginData(res.data!);
        }
        return res;
      });

  @override
  Future<BaseResponse<void>> sendRegisterVerification({
    required String phoneNumber,
  }) => _api.sendRegisterVerification(phoneNumber: phoneNumber);
}
