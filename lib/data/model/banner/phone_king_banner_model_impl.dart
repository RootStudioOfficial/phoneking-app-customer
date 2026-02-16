import 'package:phonekingcustomer/data/model/banner/phone_king_banner_model.dart';
import 'package:phonekingcustomer/data/vos/banner_vo/banner_vo.dart';
import 'package:phonekingcustomer/network/api/phone_king_api.dart';
import 'package:phonekingcustomer/network/response/base_response.dart';

class PhoneKingBannerModelImpl implements PhoneKingBannerModel {
  final PhoneKingCustomerAPI _api = PhoneKingCustomerAPI();

  @override
  Future<BaseResponse<List<BannerVO>>> getBanners({
    required String bannerType,
  }) {
    return _api.getBanners(bannerType: bannerType);
  }
}
