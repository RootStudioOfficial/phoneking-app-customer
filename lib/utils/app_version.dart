import 'package:package_info_plus/package_info_plus.dart';

/// Provides a single version code derived from the app version name (e.g. 1.0.0),
/// consistent across iOS and Android (unlike build number).
class AppVersionHelper {
  AppVersionHelper._();

  /// Version code formula: major * 100 + minor * 10 + patch (e.g. 1.0.0 -> 100, 1.2.3 -> 123).
  static Future<int> getCurrentVersionCode() async {
    final info = await PackageInfo.fromPlatform();
    return _versionNameToCode(info.version);
  }

  static int _versionNameToCode(String version) {
    final parts = version.split('.');
    final major = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minor = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final patch = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
    return major * 1000 + minor * 100 + patch;
  }
}
