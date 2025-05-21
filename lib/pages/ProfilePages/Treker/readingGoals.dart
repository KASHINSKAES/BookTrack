import 'package:cloud_firestore/cloud_firestore.dart';

class ReadingGoal {
  final DateTime date;
  final int goalMinutes;
  final int goalPages;
  final int readMinutes;
  final int readPages;

  ReadingGoal({
    required this.date,
    required this.goalMinutes,
    required this.goalPages,
    required this.readMinutes,
    required this.readPages,
  });

    factory ReadingGoal.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ReadingGoal(
      date: (data['date'] as Timestamp).toDate(),
      goalMinutes: data['goalMinutes'] ?? 0,
      goalPages: data['goalPages'] ?? 0,
      readMinutes: data['readMinutes'] ?? 0,
      readPages: data['readPages'] ?? 0,
    );
  }
}