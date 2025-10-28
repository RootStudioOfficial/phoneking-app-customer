import 'package:phone_king_customer/data/model/banner/phone_king_banner_model.dart';
import 'package:phone_king_customer/data/vos/banner_vo/banner_vo.dart';
import 'package:phone_king_customer/network/api/phone_king_api.dart';
import 'package:phone_king_customer/network/response/base_response.dart';

class PhoneKingBannerModelImpl implements PhoneKingBannerModel {
  final PhoneKingCustomerAPI _api = PhoneKingCustomerAPI();

  @override
  Future<BaseResponse<List<BannerVO>>> getBanners({
    required String bannerType,
  }) {
    return _api.getBanners(bannerType: bannerType);
  }
}
