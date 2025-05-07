import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String? coverUrl;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? 'Без названия',
      author: data['author'] ?? 'Неизвестный автор',
      coverUrl: data['coverUrl'],
    );
  }
}