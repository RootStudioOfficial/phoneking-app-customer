import 'package:dio/dio.dart';
import 'package:phone_king_customer/data/vos/banner_vo/banner_vo.dart';
import 'package:phone_king_customer/data/vos/get_balance_vo/get_balance_vo.dart';
import 'package:phone_king_customer/data/vos/login_vo/login_vo.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_claim_success_vo/reward_claim_success_vo.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_details_vo/reward_details_vo.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_vo.dart';
import 'package:phone_king_customer/data/vos/store_vo/store_vo.dart';
import 'package:phone_king_customer/network/api/phone_king_api_constant.dart';
import 'package:phone_king_customer/network/api/phone_king_interceptor.dart';
import 'package:phone_king_customer/network/response/base_response.dart';
import 'package:phone_king_customer/network/response/error_response.dart';

class PhoneKingCustomerAPI {
  late Dio _dio;

  PhoneKingCustomerAPI._() {
    _dio = Dio();
    _dio.interceptors.add(PhoneKingInterceptor());
  }

  static final PhoneKingCustomerAPI _singleton = PhoneKingCustomerAPI._();

  factory PhoneKingCustomerAPI() => _singleton;

  /// ---------------- AUTH ----------------
  Future<BaseResponse<LoginVO>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        PhoneKingCustomerApi.login,
        data: {"username": username, "password": password},
      );

      return BaseResponse.fromJson(
        response.data,
        (json) => LoginVO.fromJson(json as Map<String, dynamic>),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<LoginVO>> register({
    required String displayName,
    required String password,
    required String phoneNumber,
    required String birthday,
    String? referralCode,
  }) async {
    try {
      final response = await _dio.post(
        PhoneKingCustomerApi.register,
        data: {
          "displayName": displayName,
          "password": password,
          "phoneNumber": phoneNumber,
          "birthday": birthday,
          if (referralCode?.isNotEmpty ?? false) "referralCode": referralCode,
        },
      );
      return BaseResponse.fromJson(
        response.data,
        (json) => LoginVO.fromJson(json as Map<String, dynamic>),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<void>> sendRegisterVerification({
    required String phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        PhoneKingCustomerApi.sendRegisterVerification,
        data: {"phoneNumber": phoneNumber},
      );
      return BaseResponse.fromJson(response.data, (_) => {});
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<void>> confirmRegisterVerification({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        PhoneKingCustomerApi.confirmRegisterVerification,
        data: {"phoneNumber": phoneNumber, "otp": otp},
      );
      return BaseResponse.fromJson(response.data, (_) => {});
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  /// ---------------- BANNER ----------------
  Future<BaseResponse<List<BannerVO>>> getBanners({
    required String bannerType,
  }) async {
    try {
      final response = await _dio.get(
        PhoneKingCustomerApi.banner,
        queryParameters: {"bannerType": bannerType},
      );

      return BaseResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => BannerVO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  /// ---------------- Balance ----------------
  Future<BaseResponse<GetBalanceVO>> getBalance() async {
    try {
      final response = await _dio.get(PhoneKingCustomerApi.getBalance);

      return BaseResponse.fromJson(
        response.data,
        (json) => GetBalanceVO.fromJson(json as Map<String, dynamic>),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  /// ---------------- Store ----------------
  Future<BaseResponse<List<StoreVO>>> getStore() async {
    try {
      final response = await _dio.get(PhoneKingCustomerApi.store);

      return BaseResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => StoreVO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  /// ---------------- Reward ----------------
  Future<BaseResponse<List<RewardVO>>> getRedeemReward() async {
    try {
      final response = await _dio.get(PhoneKingCustomerApi.redeemReward);

      return BaseResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => RewardVO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<List<RewardVO>>> getAllReward(
    String storeID,
    String rewardType,
  ) async {
    try {
      final response = await _dio.get(
        PhoneKingCustomerApi.rewardAll,
        queryParameters: {"storeId": storeID, "rewardType": rewardType},
      );

      return BaseResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => RewardVO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<List<RewardVO>>> getUsedReward() async {
    try {
      final response = await _dio.get(PhoneKingCustomerApi.usedReward);

      return BaseResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => RewardVO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<RewardDetailsVO>> rewardDetails(String rewardID) async {
    try {
      final response = await _dio.get(
        PhoneKingCustomerApi.rewardDetails(rewardID),
      );

      return BaseResponse.fromJson(
        response.data,
        (json) => RewardDetailsVO.fromJson(json as Map<String, dynamic>),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<void>> rewardRedeem(String rewardID) async {
    try {
      final response = await _dio.post(
        PhoneKingCustomerApi.rewardRedeem(rewardID),
      );

      return BaseResponse.fromJson(response.data, (_) => {});
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<RewardClaimSuccessVO>> claimReward(
    String redemptionConfirmId,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        PhoneKingCustomerApi.claimReward(redemptionConfirmId),
        data: {"password": password},
      );

      return BaseResponse.fromJson(
        response.data,
        (json) => RewardClaimSuccessVO.fromJson(json as Map<String, dynamic>),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  /// ---------------- ERROR HANDLING ----------------
  Object _throwException(dynamic error, [StackTrace? stack]) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return "Unable to connect to the server. Please check your internet connection and try again.";
      }
      if (error.response?.statusCode == 429) {
        return "Too many requests. Please wait a moment and try again.";
      }
      if (error.response?.data is Map<String, dynamic>) {
        try {
          final errorResponse = ErrorResponse.fromJson(error.response?.data);
          return errorResponse.errorMessage;
        } catch (err) {
          return err.toString();
        }
      }
      return error.response.toString();
    }
    return error.toString();
  }
}
