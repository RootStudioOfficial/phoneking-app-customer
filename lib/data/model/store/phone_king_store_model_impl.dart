import 'package:phonekingcustomer/data/model/store/phone_king_store_model.dart';
import 'package:phonekingcustomer/data/vos/store_vo/store_vo.dart';
import 'package:phonekingcustomer/network/api/phone_king_api.dart';
import 'package:phonekingcustomer/network/response/base_response.dart';

class PhoneKingStoreModelImpl implements PhoneKingStoreModel {
  final PhoneKingCustomerAPI _api = PhoneKingCustomerAPI();

  @override
  Future<BaseResponse<List<StoreVO>>> getStores() {
    return _api.getStore();
  }
}