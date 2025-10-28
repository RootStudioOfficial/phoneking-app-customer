import 'package:phone_king_customer/data/vos/banner_vo/banner_vo.dart';
import 'package:phone_king_customer/network/response/base_response.dart';

abstract class PhoneKingBannerModel {
  Future<BaseResponse<List<BannerVO>>> getBanners({required String bannerType});
}
