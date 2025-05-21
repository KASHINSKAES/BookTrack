import 'package:booktrack/servises/levelServises.dart';
import 'package:flutter/material.dart';

class LevelProvider extends ChangeNotifier {
  late String _userId;
  late LevelService _levelService;

  LevelProvider.empty() { // Для инициализации до авторизации
    _userId = '';
    _levelService = LevelService(_userId,);
  }

  String get userId => _userId; // Геттер для доступа к _userId

  void updateUserId(String newUserId) {
    _userId = newUserId;
    _levelService = LevelService(_userId);
    notifyListeners();
  }

  Future<void> checkLevelUp(BuildContext context) async {
    if (_userId.isEmpty) return;
    await _levelService.checkLevelUp(context);
  }
}
