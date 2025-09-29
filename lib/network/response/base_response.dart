class BaseResponse<T> {
  final String message;
  final T? data;

  BaseResponse({required this.message, this.data});

  factory BaseResponse.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) {
    return BaseResponse(message: json['message'] ?? '', data: json['data'] != null ? fromJsonT(json['data']) : null);
  }
  factory BaseResponse.fromJsonForRefreshToken(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) {
    return BaseResponse(message: json['message'] ?? '', data: json['token'] != null ? fromJsonT(json['token']) : null);
  }

  bool get isSuccess => message.toLowerCase().contains('success') || message.toLowerCase().contains('suc');

  @override
  String toString() {
    return 'BaseResponse{message: $message, data: $data}';
  }
}
