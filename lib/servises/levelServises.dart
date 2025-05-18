import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LevelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  LevelService(this.userId);

  // Проверка, достигнут ли новый уровень
  Future<void> checkLevelUp(BuildContext context) async {
    try {
      debugPrint('Checking level up for user: $userId');

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        debugPrint('User document does not exist');
        return;
      }

      final stats = userDoc.data()?['stats'] ?? {};
      final currentLevel = stats['current_level'] ?? 1;
      final xp = stats['xp'] ?? 0;
      final pages = stats['pages'] ?? 0;

      debugPrint('Current level: $currentLevel, XP: $xp, Pages: $pages');

      final nextLevelDoc = await _firestore
          .collection('game_levels')
          .doc((currentLevel + 1).toString())
          .get();

      if (!nextLevelDoc.exists) {
        debugPrint('Next level document does not exist (max level reached?)');
        return;
      }

      final nextLevelData = nextLevelDoc.data()!;

      final rewardPoints = nextLevelData['reward_points'] as int? ?? 0;
      _showLevelUpReward(context, currentLevel + 1, rewardPoints);
    } catch (e) {
      debugPrint('Ошибка при проверке уровня: $e');
    }
  }

  // Кастомизированный SnackBar с кнопкой "Получить"
  void _showLevelUpReward(
      BuildContext context, int newLevel, int rewardPoints) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.celebration, color: AppColors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '🎉 Уровень $newLevel! Бонус: $rewardPoints очков',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      action: SnackBarAction(
        label: 'Получить',
        textColor: Theme.of(context).colorScheme.secondary,
        onPressed: () => _addBonusToHistory(context, newLevel, rewardPoints),
      ),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(20),
      duration: Duration(seconds: 10),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Добавление бонуса в историю
  Future<void> _addBonusToHistory(
      BuildContext context, int newLevel, int rewardPoints) async {
    int bonuses = 0; // Убрали final, так как значение будет меняться
    final totalBonusesUser =
        await _firestore.collection('users').doc(userId).get();
    if (totalBonusesUser.exists) {
      final userData = totalBonusesUser.data();
      if (userData != null && userData.containsKey('totalBonuses')) {
        bonuses =
            userData['totalBonuses'] ?? 0; // Используем значение из Firestore
        print('Current Bonuses: $bonuses');
      }
    }
    final int newBonuses = bonuses + rewardPoints;
    debugPrint('New Bonuses: $newBonuses');

    try {
      // Обновляем данные пользователя одним запросом
      await _firestore.collection('users').doc(userId).update({
        'stats.current_level': newLevel,
        'totalBonuses': newBonuses, // Исправлено newBonuses вместо newBonuses
      });

      // Добавляем запись в bonus_history
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bonus_history')
          .add({
        'amount': rewardPoints,
        'title': 'Достижение уровня $newLevel',
        'date': FieldValue.serverTimestamp(),
        'isPositive': true,
        'relatedPurchaseId': null, // Опционально, можно передать при покупке
        'bookId': null, // Опционально
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSuccessMessage(context, rewardPoints);
    } catch (e) {
      debugPrint('Ошибка при начислении бонуса: $e');
      _showErrorMessage(context);
    }
  }

  void _showSuccessMessage(BuildContext context, int points) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $points очков добавлены!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚠️ Ошибка при начислении бонуса'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
