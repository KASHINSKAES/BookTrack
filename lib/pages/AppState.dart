import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppState extends ChangeNotifier {
  int readingPagesPurpose = 0;
  int _readingMinutesPurpose = 0;

  int get readingMinutesPurpose => _readingMinutesPurpose;

  Future<void> loadCurrentGoals(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users/$userId/settings')
          .doc('goals')
          .get();

      if (doc.exists) {
        readingPagesPurpose = doc.data()?['pages'] ?? 0;
        _readingMinutesPurpose = doc.data()?['minutes'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка загрузки целей: $e');
    }
  }

  void updateReadingPagesPurpose(int newPurpose) {
    readingPagesPurpose = newPurpose;
    notifyListeners();
  }

  void updateReadingMinutesPurpose(int newPurpose) {
    _readingMinutesPurpose = newPurpose;
    notifyListeners();
  }

  String get formattedTime {
    final hours = (_readingMinutesPurpose ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_readingMinutesPurpose % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_readingMinutesPurpose % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }
  
  void updateTextFormat(int newPurpose) {
    _readingMinutesPurpose = newPurpose;
    notifyListeners();
  }
}