import 'package:phone_king_customer/data/model/point/phone_king_point_model.dart';
import 'package:phone_king_customer/data/vos/get_balance_vo/get_balance_vo.dart';
import 'package:phone_king_customer/network/api/phone_king_api.dart';
import 'package:phone_king_customer/network/response/base_response.dart';

class PhoneKingPointModelImpl implements PhoneKingPointModel {
  final PhoneKingCustomerAPI _api = PhoneKingCustomerAPI();

  @override
  Future<BaseResponse<GetBalanceVO>> getBalance() {
    return _api.getBalance();
  }
}
