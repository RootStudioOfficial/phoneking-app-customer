import 'package:phone_king_customer/data/vos/store_vo/store_vo.dart';
import 'package:phone_king_customer/network/response/base_response.dart';

abstract class PhoneKingStoreModel {
  Future<BaseResponse<List<StoreVO>>> getStores();
}
