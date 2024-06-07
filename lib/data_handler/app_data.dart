

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppData extends ChangeNotifier {
  bool isEnglishSelected = true;
  ThemeMode _themeMode = ThemeMode.light;



  void toggleLanguage(bool value) {
    isEnglishSelected = value;
    notifyListeners();
  }


  ThemeMode getThemeMode() {
    return _themeMode;
  }

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }



}
