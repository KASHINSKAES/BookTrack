
import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  double _brightness = 0.0;
  int _selectedBackgroundStyle = 0;
  int _selectedFontFamily = 0;
  double _fontSize = 0.0;

  double get brightness => _brightness;
  int get selectedBackgroundStyle => _selectedBackgroundStyle;
  int get selectedFontFamily => _selectedFontFamily;
  double get fontSize => _fontSize;

  void setBrightness(double value) {
    _brightness = value;
    notifyListeners();
  }

  void setBackgroundStyle(int index) {
    _selectedBackgroundStyle = index;
    notifyListeners();
  }

  void setFontFamily(int index) {
    _selectedFontFamily = index;
    notifyListeners();
  }

  void setFontSize(double value) {
    _fontSize = value;
    notifyListeners();
  }
}