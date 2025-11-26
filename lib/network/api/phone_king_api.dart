import 'dart:io';

import 'package:dio/dio.dart';
import 'package:phone_king_customer/data/vos/banner_vo/banner_vo.dart';
import 'package:phone_king_customer/data/vos/branches_vo/branches_vo.dart';
import 'package:phone_king_customer/data/vos/contact_us_vo/contact_us_vo.dart';
import 'package:phone_king_customer/data/vos/faq_vo/faq_vo.dart';
import 'package:phone_king_customer/data/vos/get_balance_vo/get_balance_vo.dart';
import 'package:phone_king_customer/data/vos/history_vo/history_summary_vo/history_summary_vo.dart';
import 'package:phone_king_customer/data/vos/history_vo/history_vo.dart';
import 'package:phone_king_customer/data/vos/login_vo/login_vo.dart';
import 'package:phone_king_customer/data/vos/member_tier_vo/member_tier_vo.dart';
import 'package:phone_king_customer/data/vos/notification_vo/notification_vo.dart';
import 'package:phone_king_customer/data/vos/payment_success_vo/payment_success_vo.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_claim_success_vo/reward_claim_success_vo.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_details_vo/reward_details_vo.dart';
import 'package:phone_king_customer/data/vos/reward_vo/reward_vo.dart';
import 'package:phone_king_customer/data/vos/scan_payment_vo/scan_payment_vo.dart';
import 'package:phone_king_customer/data/vos/store_vo/store_vo.dart';
import 'package:phone_king_customer/data/vos/terms_and_condition_vo/terms_and_condition_vo.dart';
import 'package:phone_king_customer/data/vos/user_vo/user_vo.dart';
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

  Future<BaseResponse<HistorySummaryVO>> getSummary(
    String fromDate,
    String toDate,
  ) async {
    try {
      final response = await _dio.get(
        PhoneKingCustomerApi.getSummary,
        queryParameters: {"fromDate": fromDate, "toDate": toDate},
      );

      return BaseResponse.fromJson(
        response.data,
        (json) => HistorySummaryVO.fromJson(json as Map<String, dynamic>),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<List<HistoryVO>>> getHistory(
    String fromDate,
    String toDate,
  ) async {
    try {
      final response = await _dio.get(
        PhoneKingCustomerApi.getHistory,
        queryParameters: {"fromDate": fromDate, "toDate": toDate},
      );

      return BaseResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => HistoryVO.fromJson(e as Map<String, dynamic>))
            .toList(),
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
    String paymentKey,
    String password,
    String redemptionId,
  ) async {
    try {
      final response = await _dio.post(
        PhoneKingCustomerApi.claimReward(redemptionId, paymentKey),
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

  Future<BaseResponse<List<FaqVO>>> getSupportFaqs() async {
    try {
      final response = await _dio.get(PhoneKingCustomerApi.supportFaq);

      return BaseResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => FaqVO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<List<ContactUsVO>>> getContactUs() async {
    try {
      final response = await _dio.get(PhoneKingCustomerApi.contactInfo);

      return BaseResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => ContactUsVO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<List<BranchesVO>>> getSupportBranches() async {
    try {
      final response = await _dio.get(PhoneKingCustomerApi.supportBranches);

      return BaseResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => BranchesVO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<List<TermsAndConditionVO>>>
  getSupportTermsAndConditions() async {
    try {
      final response = await _dio.get(
        PhoneKingCustomerApi.supportTermsAndCondition,
      );

      return BaseResponse.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => TermsAndConditionVO.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<UserVO>> getProfile() async {
    try {
      final response = await _dio.get(PhoneKingCustomerApi.getProfile);

      return BaseResponse.fromJson(
        response.data,
        (json) => UserVO.fromJson(json as Map<String, dynamic>),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<MemberTierVO>> getMemberTier() async {
    try {
      final response = await _dio.get(PhoneKingCustomerApi.getMemberTier);

      return BaseResponse.fromJson(
        response.data,
        (json) => MemberTierVO.fromJson(json as Map<String, dynamic>),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<void>> changePassword(
    String newPassword,
    String oldPassword,
  ) async {
    try {
      final response = await _dio.put(
        PhoneKingCustomerApi.changePassword,
        data: {"newPassword": newPassword, "oldPassword": oldPassword},
      );

      return BaseResponse.fromJson(response.data, (_) => {});
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<void>> updateProfile(
    String profileImageUrl,
    String displayName,
  ) async {
    try {
      final response = await _dio.put(
        PhoneKingCustomerApi.updateProfile,
        data: {"profileImageUrl": profileImageUrl, "displayName": displayName},
      );

      return BaseResponse.fromJson(response.data, (_) => {});
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<String>> uploadFile(File file, String folder) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'folder': folder,
      });
      final response = await _dio.post(
        PhoneKingCustomerApi.fileUpload,
        data: formData,
      );
      final baseResponse = BaseResponse<String>.fromJson(
        response.data,
        (json) => json['url'] as String,
      );
      return baseResponse;
    } catch (e, s) {
      throw _throwException(e, s);
    }
  }

  Future<BaseResponse<ScanPaymentVO>> scanPaymentQrInfo(String key) async {
    try {
      final response = await _dio.get(
        PhoneKingCustomerApi.scanQrInfo,
        queryParameters: {"key": key},
      );

      return BaseResponse.fromJson(
        response.data,
        (json) => ScanPaymentVO.fromJson(json as Map<String, dynamic>),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<PaymentSuccessVO>> makePayment(
    String key,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        PhoneKingCustomerApi.makePayment,
        data: {"key": key, "password": password},
      );

      return BaseResponse.fromJson(
        response.data,
        (json) => PaymentSuccessVO.fromJson(json as Map<String, dynamic>),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<NotificationVO>> getAllNotification(
    String size,
    String page,
  ) async {
    try {
      final response = await _dio.get(
        PhoneKingCustomerApi.getAllNotification,
        data: {"size": size, "page": page},
      );

      return BaseResponse.fromJson(
        response.data,
        (json) => NotificationVO.fromJson(json as Map<String, dynamic>),
      );
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<void>> readNotificationByID(String notificationID) async {
    try {
      final response = await _dio.patch(
        PhoneKingCustomerApi.readNotification(notificationID),
      );

      return BaseResponse.fromJson(response.data, (_) => {});
    } catch (e, stack) {
      throw Exception(_throwException(e, stack));
    }
  }

  Future<BaseResponse<void>> readAllNotification() async {
    try {
      final response = await _dio.patch(
        PhoneKingCustomerApi.readAllNotification,
      );

      return BaseResponse.fromJson(response.data, (_) => {});
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
