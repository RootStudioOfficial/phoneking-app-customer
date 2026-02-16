import 'package:phonekingcustomer/data/vos/store_vo/store_vo.dart';
import 'package:phonekingcustomer/network/response/base_response.dart';

abstract class PhoneKingStoreModel {
  Future<BaseResponse<List<StoreVO>>> getStores();
}
