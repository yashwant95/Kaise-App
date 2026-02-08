import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _prefKey = 'localeCode';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCode = prefs.getString(_prefKey);

    if (storedCode != null && _isSupported(storedCode)) {
      _locale = Locale(storedCode);
      return;
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale.languageCode)) {
      return;
    }

    if (_locale == locale) {
      return;
    }

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }

  bool _isSupported(String languageCode) {
    return languageCode == 'en' || languageCode == 'hi';
  }
}
