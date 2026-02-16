import 'package:phonekingcustomer/data/vos/banner_vo/banner_vo.dart';
import 'package:phonekingcustomer/network/response/base_response.dart';

abstract class PhoneKingBannerModel {
  Future<BaseResponse<List<BannerVO>>> getBanners({required String bannerType});
}
