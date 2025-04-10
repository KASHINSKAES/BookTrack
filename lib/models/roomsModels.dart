import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String imageUrl;
  final List<String> members;

  Room({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.imageUrl,
    required this.members,
  });

  factory Room.fromFirestore(Map<String, dynamic> data) {
    return Room(
      id: data['id'] ?? '',
      name: data['name'] ?? 'Без названия',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(
        data['lastMessageTime'] as int, // Конвертируем int в DateTime
      ),
      imageUrl: data['imageUrl'] ?? '',
      members: List<String>.from(data['members'] ?? []),
    );
  }
}
