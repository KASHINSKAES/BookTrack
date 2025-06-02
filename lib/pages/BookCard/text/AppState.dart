import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart' as DateUtils;

class AppState extends ChangeNotifier {
  DateTime? _lastReadingDate;
  int readingPagesPurpose = 30;
  int _readingMinutesPurpose = 30 * 60;
  int _pagesReadToday = 0;
  int _minutesReadToday = 0;
  bool _dailyGoalAchieved = false;

  // Геттеры
  int get readingMinutesPurpose => _readingMinutesPurpose;
  int get pagesReadToday => _pagesReadToday;
  int get minutesReadToday => _minutesReadToday;
  bool get dailyGoalAchieved => _dailyGoalAchieved;

  // Форматированное время
  String get formattedRemainingTime {
    final remaining = max(0, _readingMinutesPurpose - _minutesReadToday * 60);
    final hours = (remaining ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((remaining % 3600) ~/ 60).toString().padLeft(2, '0');
    return "$hours:$minutes:00";
  }

  // Основной метод загрузки данных пользователя
  Future<void> loadUserData(String userId) async {
    if (userId.isEmpty) return;

    await Future.wait([
      _loadGoals(userId),
      _loadTodayProgress(userId),
    ]);
    notifyListeners();
  }

  // Загрузка целей
  Future<void> _loadGoals(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users/$userId/settings')
          .doc('goals')
          .get();

      if (doc.exists) {
        readingPagesPurpose = doc.data()?['pages'] ?? 30;
        _readingMinutesPurpose = (doc.data()?['minutes'] ?? 30) * 60;
      }
    } catch (e) {
      print('Ошибка загрузки целей: $e');
    }
  }

  // Загрузка сегодняшнего прогресса
  Future<void> _loadTodayProgress(String userId) async {
    try {
      final now = DateTime.now();
      final docId = 'goal_${now.year}_${now.month}_${now.day}';

      final doc = await FirebaseFirestore.instance
          .collection('users/$userId/reading_goals')
          .doc(docId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _pagesReadToday = (data['pagesRead'] ?? data['readPages'] ?? 0).toInt();
        _minutesReadToday =
            (data['minutesRead'] ?? data['readMinutes'] ?? 0).toInt();
        _dailyGoalAchieved = _pagesReadToday >= readingPagesPurpose ||
            _minutesReadToday * 60 >= _readingMinutesPurpose;
      } else {
        _pagesReadToday = 0;
        _minutesReadToday = 0;
        _dailyGoalAchieved = false;
      }
    } catch (e) {
      print('Ошибка загрузки прогресса: $e');
    }
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

  // Обновление прогресса чтения
  Future<void> updateReadingProgress({
    required int minutes,
    required int pages,
    required String userId,
  }) async {
    _minutesReadToday += minutes;
    _pagesReadToday += pages;

    final now = DateTime.now();
    final docId = 'goal_${now.year}_${now.month}_${now.day}';

    await FirebaseFirestore.instance
        .collection('users/$userId/reading_goals')
        .doc(docId)
        .set({
      'readPages': FieldValue.increment(pages),
      'readMinutes': FieldValue.increment(minutes),
      'date': Timestamp.now(),
    }, SetOptions(merge: true));

    if (!_dailyGoalAchieved &&
        (_pagesReadToday >= readingPagesPurpose ||
            _minutesReadToday * 60 >= _readingMinutesPurpose)) {
      _dailyGoalAchieved = true;
      await _rewardUser(userId);
    }

    notifyListeners();
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

  // Проверка сброса ежедневного прогресса
  void checkDailyReset() {
    final today = DateTime.now();
    if (_lastReadingDate == null ||
        !DateUtils.isSameDay(_lastReadingDate!, today)) {
      _pagesReadToday = 0;
      _minutesReadToday = 0;
      _dailyGoalAchieved = false;
      _lastReadingDate = today;
    }
  }
}
