import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePersistent {
  LanguagePersistent._internal();
  static final LanguagePersistent _instance = LanguagePersistent._internal();
  factory LanguagePersistent() => _instance;

  static const _keySelectedLocale = 'selected_locale_code';

  late SharedPreferences _prefs;
  final StreamController<Locale> _localeController =
  StreamController<Locale>.broadcast();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;

    _localeController.add(currentLocale);
  }

  Stream<Locale> get localeStream => _localeController.stream;

  Locale get currentLocale {
    if (!_initialized) {
      return const Locale('en');
    }

    final code = _prefs.getString(_keySelectedLocale) ?? 'en';
    return Locale(code);
  }

  /// Persist + emit new locale
  Future<void> setLocale(Locale locale) async {
    if (!_initialized) {
      await init();
    }
    await _prefs.setString(_keySelectedLocale, locale.languageCode);
    _localeController.add(locale);
  }

  void dispose() {
    _localeController.close();
  }
}
