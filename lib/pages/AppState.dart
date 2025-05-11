import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart' as DateUtils;

class AppState extends ChangeNotifier {
  DateTime? _lastReadingDate;

  int readingPagesPurpose = 30; // Значение по умолчанию
  int _readingMinutesPurpose = 30 * 60; // 30 минут в секундах по умолчанию
  int _pagesReadToday = 0;
  int _minutesReadToday = 0;
  bool _dailyGoalAchieved = false;

  // Геттеры
  int get readingMinutesPurpose => _readingMinutesPurpose;
  int get pagesReadToday => _pagesReadToday;
  int get minutesReadToday => _minutesReadToday;
  bool get dailyGoalAchieved => _dailyGoalAchieved;

  // Загрузка текущих целей (метод, который отсутствовал)
  Future<void> loadCurrentGoals(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users/$userId/settings')
          .doc('goals')
          .get();

      if (doc.exists) {
        readingPagesPurpose = doc.data()?['pages'] ?? 30;
        _readingMinutesPurpose = (doc.data()?['minutes'] ?? 30) * 60;
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка загрузки целей: $e');
    }
  }

  // Форматированное время
  String get formattedRemainingTime {
    final remaining = max(0, _readingMinutesPurpose - _minutesReadToday * 60);
    final hours = (remaining ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((remaining % 3600) ~/ 60).toString().padLeft(2, '0');
    return "$hours:$minutes:00";
  }

  // Обновление целей
  Future<void> updateReadingPagesPurpose(int newPurpose, String userId) async {
    readingPagesPurpose = newPurpose;
    await FirebaseFirestore.instance
        .collection('users/$userId/settings')
        .doc('goals')
        .set({'pages': newPurpose}, SetOptions(merge: true));
    notifyListeners();
  }

  Future<void> updateReadingMinutesPurpose(int seconds, String userId) async {
    _readingMinutesPurpose = seconds;
    await FirebaseFirestore.instance
        .collection('users/$userId/settings')
        .doc('goals')
        .set({'minutes': seconds ~/ 60}, SetOptions(merge: true));
    notifyListeners();
  }

  // Обновление прогресса
  Future<void> updateReadingProgress({
    required int minutes,
    required int pages,
    required String userId,
  }) async {
    _minutesReadToday += minutes;
    _pagesReadToday += pages;

    if (!_dailyGoalAchieved &&
        (_pagesReadToday >= readingPagesPurpose ||
            _minutesReadToday * 60 >= _readingMinutesPurpose)) {
      _dailyGoalAchieved = true;
      await _rewardUser(userId);
    }

    await _saveDailyProgress(userId);
    notifyListeners();
  }

  Future<void> _saveDailyProgress(String userId) async {
    await FirebaseFirestore.instance
        .collection('users/$userId/progress')
        .doc('today')
        .set({
      'pages': _pagesReadToday,
      'minutes': _minutesReadToday,
      'date': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<void> _rewardUser(String userId) async {
    await FirebaseFirestore.instance
        .collection('users/$userId/stats')
        .doc('xp')
        .update({
      'total': FieldValue.increment(150),
      'lastReward': Timestamp.now(),
    });
  }

  void updatePagesReadToday(int pages) {
    _pagesReadToday = pages;
    notifyListeners();
  }

  // Загрузка целей и прогресса
  Future<void> loadUserData(String userId) async {
    try {
      // Загружаем цели
      final goalsDoc = await FirebaseFirestore.instance
          .collection('users/$userId/settings')
          .doc('goals')
          .get();

      if (goalsDoc.exists) {
        readingPagesPurpose = goalsDoc.data()?['pages'] ?? 30;
        _readingMinutesPurpose = (goalsDoc.data()?['minutes'] ?? 30) * 60;
      }

      // Загружаем прогресс
      final progressDoc = await FirebaseFirestore.instance
          .collection('users/$userId/progress')
          .doc('today')
          .get();

      if (progressDoc.exists) {
        _pagesReadToday = progressDoc.data()?['pages'] ?? 0;
        _minutesReadToday = progressDoc.data()?['minutes'] ?? 0;
        _lastReadingDate =
            (progressDoc.data()?['date'] as Timestamp?)?.toDate();
        _checkDailyReset();
      }

      notifyListeners();
    } catch (e) {
      print('Ошибка загрузки данных: $e');
    }
  }

  // Проверка сброса ежедневного прогресса
  void _checkDailyReset() {
    final today = DateTime.now();
    if (_lastReadingDate == null ||
        !DateUtils.isSameDay(_lastReadingDate!, today)) {
      _pagesReadToday = 0;
      _minutesReadToday = 0;
      _dailyGoalAchieved = false;
    }
  }
}
