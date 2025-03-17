import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  // Выбранный стиль фона (0, 1, 2, 3)
  int _selectedBackgroundStyle = 0;
  int get selectedBackgroundStyle => _selectedBackgroundStyle;

  // Выбранный шрифт (0, 1, 2, 3)
  int _selectedFontFamily = 0;
  int get selectedFontFamily => _selectedFontFamily;

  // Размер текста
  double _fontSize = 16.0;
  double get fontSize => _fontSize;

  // Яркость экрана
  double _brightness = 50.0;
  double get brightness => _brightness;


  // Сеттер для размера шрифта
  set fontSize(double value) {
    _fontSize = value;
    notifyListeners(); // Уведомляем слушателей об изменении
  }

  // Установка стиля фона
  void setBackgroundStyle(int style) {
    _selectedBackgroundStyle = style;
    notifyListeners(); // Уведомляем слушателей об изменении
  }

  // Установка шрифта
  void setFontFamily(int family) {
    _selectedFontFamily = family;
    notifyListeners(); // Уведомляем слушателей об изменении
  }

  // Установка размера текста
  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners(); // Уведомляем слушателей об изменении
  }

  // Установка яркости
  void setBrightness(double value) {
    _brightness = value;
    notifyListeners(); // Уведомляем слушателей об изменении
  }
}
