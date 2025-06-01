import 'package:flutter/material.dart';

class FilterProvider with ChangeNotifier {
  bool _isSubscription = false;
  bool _isExclusive = false;
  String? _selectedFormat;
  String? _selectedLanguage;
  double? _minRating;
  bool get isHighRated => minRating != null && minRating! >= 4.0;

  // Временные переменные
  bool _tempIsSubscription = false;
  bool _tempIsExclusive = false;
  String? _tempSelectedFormat;
  String? _tempSelectedLanguage;
  double? _tempMinRating;
  bool get tempIsHighRated => tempMinRating != null && tempMinRating! >= 4.0;

  // Геттеры
  bool get isSubscription => _isSubscription;
  bool get isExclusive => _isExclusive;
  String? get selectedFormat => _selectedFormat;
  String? get selectedLanguage => _selectedLanguage;
  double? get minRating => _minRating;

  // Геттеры для временных переменных
  bool get tempIsSubscription => _tempIsSubscription;
  bool get tempIsExclusive => _tempIsExclusive;
  String? get tempSelectedFormat => _tempSelectedFormat;
  String? get tempSelectedLanguage => _tempSelectedLanguage;
  double? get tempMinRating => _tempMinRating;

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
    _tempMinRating = tempIsHighRated ? null : 4.0;
    notifyListeners();
  }

  // Новый метод для установки минимального рейтинга

  void applyFilters() {
    _isSubscription = _tempIsSubscription;
    _isExclusive = _tempIsExclusive;
    _selectedFormat = _tempSelectedFormat;
    _selectedLanguage = _tempSelectedLanguage;
    _minRating = _tempMinRating;
    notifyListeners();
  }

  Map<String, dynamic> get activeFilters {
    return {
      'isSubscription': _isSubscription,
      'isExclusive': _isExclusive,
      'minRating': _minRating,  
      'format': _selectedFormat,
      'language': _selectedLanguage,
    };
  }

  void resetFilters() {
    _isSubscription = false;
    _isExclusive = false;
    _minRating = null;
    _selectedFormat = null;
    _selectedLanguage = null;

    // Сбрасываем также временные переменные
    _tempIsSubscription = false;
    _tempIsExclusive = false;
    _tempMinRating = null;
    _tempSelectedFormat = null;
    _tempSelectedLanguage = null;

    notifyListeners();
  }
}
