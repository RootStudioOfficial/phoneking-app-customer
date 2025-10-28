import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:phone_king_customer/network/response/error_response.dart';
import 'package:phone_king_customer/persistent/login_persistent.dart';

class PhoneKingInterceptor extends Interceptor {
  const PhoneKingInterceptor();

  bool _isMultipart(RequestOptions o) =>
      o.contentType?.toLowerCase().contains('multipart/form-data') == true ||
          o.data is FormData;

  bool _isLogin(RequestOptions o) {
    return o.path.endsWith('/login') || o.path.contains('/auth/login');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    debugPrint('============ Request URL    => ${options.uri}');
    debugPrint('============ Request Data   => ${options.data}');

    options.headers['Accept'] = Headers.jsonContentType;

    if (!_isMultipart(options)) {
      options.contentType = Headers.jsonContentType;
    }

    if (_isLogin(options)) {
      return handler.next(options);
    }

    final loginStore = LoginPersistent();
    final token = await loginStore.getTokenByValue(isToken: true);
    if (token.isNotEmpty) {
      debugPrint('============ Using Token    => $token');
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    debugPrint('============ Response Start ===================');
    debugPrint('============ Request URL    => ${response.requestOptions.uri}');
    debugPrint('============ Status Code    => ${response.statusCode}');
    debugPrint('============ Response Data  => ${response.data}');
    debugPrint('============ Headers        => ${response.headers.map}');
    debugPrint('============ Response End   ===================');

    final headerToken = response.headers.value('Jwt-Token');
    if (headerToken != null && headerToken.isNotEmpty) {
      try {
        final loginStore = LoginPersistent();
        await loginStore.saveToken(headerToken);
        debugPrint('============ Saved Jwt-Token from response');
      } catch (e) {
        debugPrint('!!!! Failed saving Jwt-Token: $e');
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('============ API Error Start ===================');
    debugPrint('============ Error URL       => ${err.requestOptions.uri}');
    debugPrint('============ Error Status    => ${err.response?.statusCode}');
    debugPrint('============ Error Response  => ${err.response?.data}');
    debugPrint('============ Error Message   => ${err.message}');
    debugPrint('============ Sent Headers    => ${err.requestOptions.headers}');
    debugPrint('============ API Error End   ===================');

    final res = err.response;
    if (res?.data is Map<String, dynamic>) {
      try {
        final parsed = ErrorResponse.fromJson(res!.data);
        final msg = parsed.errorMessage;

        if ((res.statusCode == 401) || (msg.toLowerCase() == 'expired jwt')) {
          await LoginPersistent().clearTokenOnly();
          debugPrint('============ Cleared expired JWT ============');
        }
      } catch (_) {

      }
    }

    handler.reject(err);
  }
}
