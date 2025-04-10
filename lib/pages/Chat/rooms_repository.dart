import 'package:booktrack/models/roomsModels.dart';
import 'package:booktrack/models/userModels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 Stream<List<Room>> getRooms() {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  return _firestore
      .collection('rooms')
      .where('members', arrayContains: userId)  // Совпадает с индексом
      .orderBy('lastMessageTime', descending: true)  // Совпадает с индексом
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Room.fromFirestore({
            ...doc.data(),
            'id': doc.id,
          })).toList());
}

  Future<void> createRoom(String name, String userId,
      {required String otherUserId}) async {
    await _firestore.collection('rooms').add({
      'name': name,
      'lastMessage': '',
      'lastMessageTime':
          FieldValue.serverTimestamp(), // Используем серверное время
      'imageUrl': 'assets/images/logoProfile.svg',
      'members': [userId, otherUserId],
    });
  }

// Возвращаем Future<List<UserModel>> вместо Stream
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      // Проверяем авторизацию
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel(
          uid: doc.id,
          email: data['email'] ?? '',
          name: data['name'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Ошибка поиска: $e');
      return []; // Возвращаем пустой список при ошибке
    }
  }
}
