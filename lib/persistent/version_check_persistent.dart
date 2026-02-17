import 'package:shared_preferences/shared_preferences.dart';

/// Throttle for optional update dialog: show at most once per [throttleDuration].
class VersionCheckPersistent {
  VersionCheckPersistent._();

  static const _keyLastOptionalUpdateShownAt = 'last_optional_update_dialog_shown_at';
  static const throttleDuration = Duration(hours: 24);

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  static Future<bool> shouldShowOptionalUpdateDialog() async {
    final prefs = await _prefs();
    final lastAt = prefs.getInt(_keyLastOptionalUpdateShownAt);
    if (lastAt == null) return true;
    return DateTime.now().millisecondsSinceEpoch - lastAt > throttleDuration.inMilliseconds;
  }

  static Future<void> markOptionalUpdateDialogShown() async {
    final prefs = await _prefs();
    await prefs.setInt(_keyLastOptionalUpdateShownAt, DateTime.now().millisecondsSinceEpoch);
  }
}
