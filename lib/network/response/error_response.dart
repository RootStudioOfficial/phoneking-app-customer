class ErrorResponse {
  final String timestamp;
  final String errorCode;
  final String errorMessage;

  ErrorResponse(this.timestamp, this.errorCode, this.errorMessage);

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(json['timestamp'] as String, json['errorCode'] as String, json['errorMessage'] as String);
  }
}
