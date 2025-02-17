import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  int readingMinutesPurpose = 30; // Количество минут по умолчанию

  // Метод для обновления цели чтения
  void updateReadingMinutesPurpose(int newPurpose) {
    readingMinutesPurpose = newPurpose;
    notifyListeners(); // Уведомляет подписчиков об изменении
  }
  
}
