import 'package:flutter/material.dart';

class FilterProvider with ChangeNotifier {
  bool _isSubscription = false;
  bool _isExclusive = false;
  String? _selectedFormat;
  String? _selectedLanguage;
  bool _isHighRated = false;

  // Временные переменные для хранения состояния фильтров
  bool _tempIsSubscription = false;
  bool _tempIsExclusive = false;
  String? _tempSelectedFormat;
  String? _tempSelectedLanguage;
  bool _tempIsHighRated = false;

  bool get isSubscription => _isSubscription;
  bool get isExclusive => _isExclusive;
  String? get selectedFormat => _selectedFormat;
  String? get selectedLanguage => _selectedLanguage;
  bool get isHighRated => _isHighRated;

  // Геттеры для временных переменных
  bool get tempIsSubscription => _tempIsSubscription;
  bool get tempIsExclusive => _tempIsExclusive;
  String? get tempSelectedFormat => _tempSelectedFormat;
  String? get tempSelectedLanguage => _tempSelectedLanguage;
  bool get tempIsHighRated => _tempIsHighRated;

  void toggleSubscription() {
    _tempIsSubscription = !_tempIsSubscription;
    notifyListeners();
  }

  void toggleExclusive() {
    _tempIsExclusive = !_tempIsExclusive;
    notifyListeners();
  }

  void setFormat(String? format) {
    if (_tempSelectedFormat == format) {
      _tempSelectedFormat = null;
    } else {
      _tempSelectedFormat = format;
    }
    notifyListeners();
  }

  void setLanguage(String? language) {
    if (_tempSelectedLanguage == language) {
      _tempSelectedLanguage = null;
    } else {
      _tempSelectedLanguage = language;
    }
    notifyListeners();
  }

  void toggleHighRated() {
    _tempIsHighRated = !_tempIsHighRated;
    notifyListeners();
  }

  // Метод для применения временных фильтров
  void applyFilters() {
    _isSubscription = _tempIsSubscription;
    _isExclusive = _tempIsExclusive;
    _selectedFormat = _tempSelectedFormat;
    _selectedLanguage = _tempSelectedLanguage;
    _isHighRated = _tempIsHighRated;
    notifyListeners();
  }

  // Метод для получения всех активных фильтров
  Map<String, dynamic> get activeFilters {
    return {
      'isSubscription': _isSubscription,
      'isExclusive': _isExclusive,
      'isHighRated': _isHighRated,
      'format': _selectedFormat,
      'language': _selectedLanguage,
    };
  }

  // Метод для сброса всех фильтров
  void resetFilters() {
    _isSubscription = false;
    _isExclusive = false;
    _isHighRated = false;
    _selectedFormat = null;
    _selectedLanguage = null;
    notifyListeners();
  }
}
