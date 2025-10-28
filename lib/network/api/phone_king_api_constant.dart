class PhoneKingCustomerApi {
  static const String baseUrl = 'https://api-phoneking.up.railway.app/api/v1';

  // Auth
  static const String login = '$baseUrl/user/auth/login';
  static const String register = '$baseUrl/user/auth/register';
  static const String sendRegisterVerification = '$baseUrl/user/auth/register/verification/send';
  static const String confirmRegisterVerification = '$baseUrl/user/auth/register/verification/confirm';

  // Banner
  static const String banner = '$baseUrl/user/banner';
}
