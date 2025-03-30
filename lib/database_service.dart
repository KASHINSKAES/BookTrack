import 'package:booktrack/models/userModels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Ошибка получения пользователя');
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw DatabaseException('Ошибка создания пользователя');
    }
  }

  Future<bool> checkUserExists(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      throw DatabaseException('Ошибка проверки пользователя');
    }
  }
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);
}