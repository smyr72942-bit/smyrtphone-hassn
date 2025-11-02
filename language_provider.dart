import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {

  Locale _currentLocale = const Locale('ar');

  Locale get currentLocale => _currentLocale;

  LanguageProvider() {

    _loadSavedLanguage();

  }

  void _loadSavedLanguage() async {

    final prefs = await SharedPreferences.getInstance();

    final langCode = prefs.getString('language_code') ?? 'ar';

    _currentLocale = Locale(langCode);

    notifyListeners();

  }

  void toggleLanguage() async {

    final prefs = await SharedPreferences.getInstance();

    if (_currentLocale.languageCode == 'ar') {

      _currentLocale = const Locale('en');

      await prefs.setString('language_code', 'en');

    } else {

      _currentLocale = const Locale('ar');

      await prefs.setString('language_code', 'ar');

    }

    notifyListeners();

  }

}