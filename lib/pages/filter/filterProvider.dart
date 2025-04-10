import 'package:flutter/material.dart';

class FilterProvider with ChangeNotifier {
  bool _isSubscription = false;
  bool _isExclusive = false;
  bool _isHighRated = false;
  String? _selectedFormat;
  String? _selectedLanguage;

  // Геттеры
  bool get isSubscription => _isSubscription;
  bool get isExclusive => _isExclusive;
  bool get isHighRated => _isHighRated;
  String? get selectedFormat => _selectedFormat;
  String? get selectedLanguage => _selectedLanguage;

  // Сеттеры
  void toggleSubscription(bool value) {
    _isSubscription = value;
    notifyListeners();
  }

  void toggleExclusive(bool value) {
    _isExclusive = value;
    notifyListeners();
  }

  void toggleHighRated(bool value) {
    _isHighRated = value;
    notifyListeners();
  }

  void setFormat(String? format) {
    _selectedFormat = format;
    notifyListeners();
  }

  void setLanguage(String? language) {
    _selectedLanguage = language;
    notifyListeners();
  }
}