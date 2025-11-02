import 'package:phone_king_customer/data/vos/get_balance_vo/get_balance_vo.dart';
import 'package:phone_king_customer/network/response/base_response.dart';

abstract class PhoneKingPointModel {
  Future<BaseResponse<GetBalanceVO>> getBalance();
}
