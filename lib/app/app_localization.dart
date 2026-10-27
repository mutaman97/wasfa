import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalization(final Locale locale) {
  late Map<String, String> _localizedValues;

  static AppLocalization? of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  Future<void> loadJson() async {
    String jsonStringValues =
        await rootBundle.loadString('assets/languages/language.json');
    
    // 1. Explicitly cast to Map<String, dynamic> to fix the error
    final Map<String, dynamic> mappedJson = 
        json.decode(jsonStringValues) as Map<String, dynamic>;

    // 2. Safely extract the language map
    final dynamic langData = mappedJson[locale.languageCode] ?? mappedJson['en'];
    
    // 3. Ensure it's a valid map and convert values to Strings
    if (langData is Map<String, dynamic>) {
      _localizedValues = langData.map(
        (key, value) => MapEntry(key, value.toString()),
      );
    } else {
      _localizedValues = {}; // Fallback if data is missing or malformed
    }
  }

  String? getTranslatedValues(String? key) {
    if (key == null) return null;
    return _localizedValues[key];
  }

  static const LocalizationsDelegate<AppLocalization> delegate =
      _AppLocalizationDelegate();
}

class const _AppLocalizationDelegate() extends LocalizationsDelegate<AppLocalization> {
  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    final AppLocalization localization = AppLocalization(locale);
    await localization.loadJson();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) {
    return false;
  }
}
