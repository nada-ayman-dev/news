import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  bool get isArabic => _currentLocale.languageCode == 'ar';

  void setLanguage(String languageCode) {
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  void toggleLanguage() {
    _currentLocale = _currentLocale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    notifyListeners();
  }
}
