import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class PhoneKingInterceptor extends Interceptor {
  const PhoneKingInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint("============ API Error Start ===================");
    debugPrint("============ Error URL       => ${err.requestOptions.uri}");
    debugPrint("============ Error Status    => ${err.response?.statusCode}");
    debugPrint("============ Error Response   => ${err.response}");
    debugPrint("============ Error Message   => ${err.message}");
    debugPrint("============ Error Headers   => ${err.requestOptions.headers}");
    debugPrint("============ API Error End   ===================");
  }


  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    debugPrint("============ Response Start ===================");
    debugPrint("============ Request URL    => ${response.requestOptions.uri}");
    debugPrint("============ Response Data  => ${response.data}");
    debugPrint("============ Response End   ===================");
    return handler.next(response);
  }
}
