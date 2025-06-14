import 'package:booktrack/pages/BookCard/text/AppState.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReadingStatsProvider with ChangeNotifier {
  Map<String, int> dailyDataPages = {};
  Map<String, int> dailyDataMinutes = {};
  Map<String, int> dailyGoalPages = {};
  Map<String, int> dailyGoalMinutes = {};
  int selectedDay = 0;
  int selectedWeekTime = 0;
  int selectedWeekPage = 0;
  bool isLoading = true;
  String? errorMessage;
  AppState? _appState;

  // Метод для установки связи с AppState
  void setAppState(AppState appState) {
    _appState = appState;
    notifyListeners();
  }

  Map<String, List<int>> weeklyDataPages = {};
  Map<String, List<int>> weeklyDataMinutes = {};

  Future<Map<String, int>> fetchDailyReadingStats(
      String type, String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'reading_goals': [],
      });
    }

    final goalsCollection = userDoc.reference.collection('reading_goals');
    final goalsSnapshot = await goalsCollection.get();

    if (goalsSnapshot.docs.isEmpty) {
      await goalsCollection.doc('initial').set({
        'date': Timestamp.now(),
        'readPages': 0,
        'readMinutes': 0,
      });
    }

    final snapshot = await goalsCollection.orderBy('date').get();
    final Map<String, int> dailyData = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = data['date'] is String
          ? DateTime.parse(data['date'])
          : (data['date'] as Timestamp).toDate();
      final dayKey = _formatDate(date);

      if (type == "pages") {
        dailyData[dayKey] =
            ((dailyData[dayKey] ?? 0) + (data['readPages'] ?? 0)).toInt();
      } else if (type == "minutes") {
        dailyData[dayKey] =
            ((dailyData[dayKey] ?? 0) + (data['readMinutes'] ?? 0)).toInt();
      }
    }

    return dailyData;
  }

  /// Загружает статистику по неделям (страницы/минуты)
  Future<Map<String, List<int>>> fetchReadingStats(
      String type, String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'reading_goals': [],
      });
    }

    final goalsCollection = userDoc.reference.collection('reading_goals');
    final goalsSnapshot = await goalsCollection.get();

    if (goalsSnapshot.docs.isEmpty) {
      await goalsCollection.doc('initial').set({
        'date': Timestamp.now(),
        'readPages': 0,
        'readMinutes': 0,
      });
    }

    final snapshot = await goalsCollection.orderBy('date').get();
    final Map<String, List<int>> weeklyData = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = data['date'] is String
          ? DateTime.parse(data['date'])
          : (data['date'] as Timestamp).toDate();
      final weekKey = _getWeekKey(date);

      if (!weeklyData.containsKey(weekKey)) {
        weeklyData[weekKey] = List.filled(7, 0);
      }

      final weekday = (date.weekday % 7);
      if (type == "pages") {
        weeklyData[weekKey]![weekday] =
            (weeklyData[weekKey]![weekday] + (data['readPages'] ?? 0)).toInt();
      } else if (type == "minutes") {
        weeklyData[weekKey]![weekday] =
            (weeklyData[weekKey]![weekday] + (data['readMinutes'] ?? 0))
                .toInt();
      }
    }

    return weeklyData;
  }

  /// Форматирует дату в строку (2023-01-01)
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Генерирует ключ недели (01.01-07.01)
  String _getWeekKey(DateTime date) {
    final startOfWeek =
        DateTime(date.year, date.month, date.day - date.weekday + 1);
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return '${startOfWeek.day}.${startOfWeek.month}-${endOfWeek.day}.${endOfWeek.month}';
  }

  Future<void> _loadWeeklyStats(String userId) async {
    isLoading = true;
    notifyListeners();

    weeklyDataPages = await fetchReadingStats("pages", userId);
    weeklyDataMinutes = await fetchReadingStats("minutes", userId);

    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadDailyStats(String userId) async {
    isLoading = true;
    notifyListeners();

    dailyDataPages = await fetchDailyReadingStats("pages", userId);
    dailyDataMinutes = await fetchDailyReadingStats("minutes", userId);

    isLoading = false;
    notifyListeners();
  }

  void changeTimeWeek(int newIndex) {
    selectedWeekTime = newIndex;
    notifyListeners();
  }

  void changePageWeek(int newIndex) {
    selectedWeekPage = newIndex;
    notifyListeners();
  }

  Future<void> loadData(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      final authProvider = Provider.of<AuthProviders>(context, listen: false);
      final userModel = authProvider.userModel;

      if (userModel == null || userModel.uid.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Получаем AppState из провайдера
      _appState = Provider.of<AppState>(context, listen: false);

      // Загружаем цели из AppState
      await _appState?.loadUserData(userModel.uid);

      await Future.wait([
        _loadDailyStats(userModel.uid),
        _loadWeeklyStats(userModel.uid),
        _loadGoalData(userModel.uid),
      ]);

      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to load data: ${e.toString()}';
      debugPrint(errorMessage);
    } finally {
      // Важно использовать finally
      isLoading = false;
      notifyListeners(); // Уведомляем о завершении загрузки
    }
  }

  // Метод для загрузки целевых значений
  Future<void> _loadGoalData(String userId) async {
    if (userId.isEmpty) {
      print("Error: User ID is empty.");
      return;
    }

    // Используем цели из AppState, если они доступны
    if (_appState != null) {
      final todayKey = _formatDate(DateTime.now());
      dailyGoalPages[todayKey] = _appState!.readingPagesPurpose;
      dailyGoalMinutes[todayKey] = _appState!.readingMinutesPurpose ~/ 60;
      return;
    }

    // Резервный вариант: загрузка из Firestore
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'reading_goals': [],
      });
    }

    final goalsCollection = userDoc.reference.collection('reading_goals');
    final goalsSnapshot = await goalsCollection.get();

    for (var doc in goalsSnapshot.docs) {
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

  // Добавляем методы для обновления целей
  Future<void> updateDailyGoals(int pages, int minutes, String userId) async {
    final todayKey = _formatDate(DateTime.now());
    dailyGoalPages[todayKey] = pages;
    dailyGoalMinutes[todayKey] = minutes;

    // Синхронизируем с AppState
    if (_appState != null) {
      await _appState!.updateReadingPagesPurpose(pages, userId);
      await _appState!.updateReadingMinutesPurpose(minutes * 60, userId);
    }

    // Сохраняем в Firestore
    await _saveGoalsToFirestore(userId, pages, minutes);

    notifyListeners();
  }

  Future<void> _saveGoalsToFirestore(
      String userId, int pages, int minutes) async {
    final today = DateTime.now();
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    await userDoc.collection('reading_goals').doc(_formatDate(today)).set({
      'date': Timestamp.fromDate(today),
      'goalPages': pages,
      'goalMinutes': minutes,
    }, SetOptions(merge: true));
  }

  // Метод для изменения выбранного дня
  void setSelectedDay(int day) {
    selectedDay = day;
    notifyListeners(); // Уведомляем слушателей об изменении выбранного дня
  }

  // Геттер для выбранной даты
  String get selectedDate {
    final days = dailyDataPages.keys.toList();
    if (days.isEmpty) {
      return _formatDate(
          DateTime.now()); // Возвращаем текущую дату по умолчанию
    }
    return days[
        selectedDay.clamp(0, days.length - 1)]; // Защита от выхода за границы
  }

  // Геттеры для данных выбранного дня
  int get pages => dailyDataPages[selectedDate] ?? 0;
  int get minutes => dailyDataMinutes[selectedDate] ?? 0;
  int get goalPages => dailyGoalPages[selectedDate] ?? 0;
  int get goalMinutes => dailyGoalMinutes[selectedDate] ?? 0;
}
