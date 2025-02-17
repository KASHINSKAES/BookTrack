import 'package:booktrack/pages/statistikPages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReadingStatsProvider with ChangeNotifier {
  Map<String, int> dailyDataPages = {};
  Map<String, int> dailyDataMinutes = {};
  Map<String, int> dailyGoalPages = {};
  Map<String, int> dailyGoalMinutes = {};
  int selectedDay = 0;

  // Метод для загрузки данных
  Future<void> loadData() async {
    // Загружаем данные из базы
    dailyDataPages = await fetchDailyReadingStats("pages");
    dailyDataMinutes = await fetchDailyReadingStats("minutes");
    await _loadGoalData(); // Загружаем целевые значения

    notifyListeners(); // Уведомляем слушателей об изменении данных
  }

  // Метод для загрузки целевых значений
  Future<void> _loadGoalData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc('user_1')
        .collection('reading_goals')
        .orderBy('date')
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      final dateKey = _formatDate(date);

      if (data.containsKey('goalPages')) {
        dailyGoalPages[dateKey] = (data['goalPages'] ?? 0).toInt();
      }
      if (data.containsKey('goalMinutes')) {
        dailyGoalMinutes[dateKey] = (data['goalMinutes'] ?? 0).toInt();
      }
    }
  }

  // Вспомогательная функция для форматирования даты
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Метод для изменения выбранного дня
  void setSelectedDay(int day) {
    selectedDay = day;
    notifyListeners(); // Уведомляем слушателей об изменении выбранного дня
  }

  // Геттер для выбранной даты
  String get selectedDate {
    final days = dailyDataPages.keys.toList();
    return days[selectedDay];
  }

  // Геттеры для данных выбранного дня
  int get pages => dailyDataPages[selectedDate] ?? 0;
  int get minutes => dailyDataMinutes[selectedDate] ?? 0;
  int get goalPages => dailyGoalPages[selectedDate] ?? 0;
  int get goalMinutes => dailyGoalMinutes[selectedDate] ?? 0;
}