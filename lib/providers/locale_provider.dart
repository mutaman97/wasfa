import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en'); // Default language

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return;
    _locale = locale;
    notifyListeners(); // This rebuilds the app with the new language
  }

  void clearLocale() {
    _locale = const Locale('en');
    notifyListeners();
  }
}

// Helper class to list supported locales
class L10n {
  static final all = [
    const Locale('en'),
    const Locale('ar'),
  ];
}