import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // Количество минут по умолчанию
  int readingPagesPurpose = 0;
  // Метод для обновления цели чтения
  void updateReadingPagesPurpose(int newPurpose) {
    readingPagesPurpose = newPurpose;
    notifyListeners(); // Уведомляет подписчиков об изменении
  }

  int _readingMinutesPurpose = 0;

  int get readingMinutesPurpose => _readingMinutesPurpose;

  void updateReadingMinutesPurpose(int newPurpose) {
    _readingMinutesPurpose = newPurpose;
    notifyListeners();
  }

  String get formattedTime {
    final hours = (_readingMinutesPurpose ~/ 3600).toString().padLeft(2, '0');
    final minutes =
        ((_readingMinutesPurpose % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_readingMinutesPurpose % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }
  
void updateTextFormat(int newPurpose) {
    _readingMinutesPurpose = newPurpose;
    notifyListeners();
  }

}
