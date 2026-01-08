import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:phone_king_customer/network/response/error_response.dart';
import 'package:phone_king_customer/persistent/login_persistent.dart';

class PhoneKingInterceptor extends Interceptor {
  const PhoneKingInterceptor();

  // Define public URLs that don't require authentication
  static const List<String> publicUrlPatterns = [
    '/api/v1/user/auth/',
    '/api/v1/geography/',
  ];

  bool _isMultipart(RequestOptions o) =>
      o.contentType?.toLowerCase().contains('multipart/form-data') == true ||
          o.data is FormData;

  bool _isLogin(RequestOptions o) {
    return o.path.endsWith('/auth') ||
        o.path.endsWith('/login') ||
        o.path.contains('/auth/login');
  }

  bool _isPublicUrl(RequestOptions o) {
    final path = o.path;

    // Check if the path matches any public URL pattern
    for (final pattern in publicUrlPatterns) {
      if (path.contains(pattern)) {
        return true;
      }
    }

    return false;
  }

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    debugPrint('============ Request URL    => ${options.uri}');
    debugPrint('============ Request Data   => ${options.data}');

    options.headers['Accept'] = Headers.jsonContentType;

    if (!_isMultipart(options)) {
      options.contentType = Headers.jsonContentType;
    }

    // Skip token for public URLs
    if (_isLogin(options) || _isPublicUrl(options)) {
      debugPrint('============ Public URL - No Token Required');
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

        if (parsed.errorCode == 'ERR_AUTH001') {
          throw Exception("session time out");
        }
      } catch (_) {}
    }

    handler.reject(err);
  }
}