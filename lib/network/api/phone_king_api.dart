import 'package:dio/dio.dart';
import 'package:phone_king_customer/network/response/error_response.dart';

class PhoneKingAPI {
  late Dio _dio;

  PhoneKingAPI._() {
    _dio = Dio();
  }

  static final PhoneKingAPI _singleton = PhoneKingAPI._();

  factory PhoneKingAPI() => _singleton;
}

Object _throwException(dynamic error, [StackTrace? stack]) {
  if (error is DioException) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return "Unable to connect to the server. Please check your internet connection and try again.";
    }
    if (error.response?.statusCode == 429) {
      return "Your request couldn't be processed due to too many requests. Please wait a moment and try again.";
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
