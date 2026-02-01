import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages app locale and language preferences
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale _locale = const Locale('en');
  bool _isInitialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;

  /// Supported languages
  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(code: 'en', name: 'English', nativeName: 'English'),
    LanguageOption(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
    LanguageOption(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം'),
    LanguageOption(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    LanguageOption(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
    LanguageOption(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    LanguageOption(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
  ];

  /// Initialize locale from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);

    if (savedLocale != null) {
      _locale = Locale(savedLocale);
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Set app locale
  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;

    _locale = Locale(languageCode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);

    notifyListeners();
  }

  /// Check if language has been set by user
  Future<bool> hasLanguageBeenSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_localeKey);
  }
}

/// Language option model
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}
