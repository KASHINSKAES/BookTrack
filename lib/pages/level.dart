import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> createLevelsCollection() async {
  try {
    final firestore = FirebaseFirestore.instance;
    const maxLevel = 50;
    
    // Параметры системы уровней
    const baseXP = 500;
    const xpGrowth = 1.2;
    const baseReward = 50;
    const rewardIncrement = 50;
    const basePages = 50;

    // Создаём batch для пакетной записи
    final batch = firestore.batch();
    final levelsRef = firestore.collection('game_levels');

    for (int level = 1; level <= maxLevel; level++) {
      final levelData = {
        'level': level,
        'xp_required': level == 1 ? 0 : (baseXP * pow(xpGrowth, level - 2)).round(),
        'pages_required': level * basePages,
        'reward_points': baseReward + (level - 1) * rewardIncrement,
      };
      
      batch.set(levelsRef.doc(level.toString()), levelData);
    }

    await batch.commit();
    debugPrint('Успешно создано $maxLevel уровней в Firestore');
  } catch (e) {
    debugPrint('Ошибка при создании уровней: $e');
    rethrow;
  }
}
