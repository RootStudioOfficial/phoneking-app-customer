import 'dart:convert';
import 'package:phone_king_customer/data/vos/login_vo/login_vo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPersistent {
  static const String _keyLoginData = 'login_data';
  static const String _keyAccessToken = 'admin_access_token';
  static const String _keyRefreshToken = 'admin_refresh_token';

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<void> saveLoginData(LoginVO loginData) async {
    final p = await _prefs();
    final jsonString = jsonEncode(loginData.toJson());
    await p.setString(_keyLoginData, jsonString);
  }

  Future<LoginVO?> getLoginData() async {
    final p = await _prefs();
    final jsonString = p.getString(_keyLoginData);
    if (jsonString == null) return null;
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return LoginVO.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final p = await _prefs();
    final voExists = p.containsKey(_keyLoginData);
    final tokenExists = (p.getString(_keyAccessToken) ?? '').isNotEmpty;
    return voExists || tokenExists;
  }

  /// ----- Token-only storage (since VO no longer contains tokens) -----

  Future<void> saveToken(String token) async {
    final p = await _prefs();
    await p.setString(_keyAccessToken, token);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    final p = await _prefs();
    await p.setString(_keyRefreshToken, refreshToken);
  }

  Future<String> getAccessToken() async {
    final p = await _prefs();
    return p.getString(_keyAccessToken) ?? '';
  }

  Future<String> getRefreshToken() async {
    final p = await _prefs();
    return p.getString(_keyRefreshToken) ?? '';
  }

  Future<void> clearTokenOnly() async {
    final p = await _prefs();
    await p.remove(_keyAccessToken);
    await p.remove(_keyRefreshToken);
  }

  Future<void> clearLoginData() async {
    final p = await _prefs();
    await p.remove(_keyLoginData);
    await p.remove(_keyAccessToken);
    await p.remove(_keyRefreshToken);
  }

  Future<String> getTokenByValue({
    bool isToken = false,
    bool isRefreshToken = false,
  }) async {
    if (isToken) return getAccessToken();
    if (isRefreshToken) return getRefreshToken();
    return '';
  }
}
