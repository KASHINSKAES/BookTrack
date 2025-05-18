import 'package:cloud_firestore/cloud_firestore.dart';

class BookReview {
  final String id;
  final String bookId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String text;
  final int rating;
  final DateTime date;
  final List<String> likes;

  BookReview({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.text,
    required this.rating,
    required this.date,
    List<String>? likes,
  }) : likes = likes ?? [];

  factory BookReview.fromMap(Map<String, dynamic> map) {
    return BookReview(
      id: map['id'],
      bookId: map['bookId'],
      userId: map['userId'],
      userName: map['userName'] ?? 'Аноним',
      userAvatar: map['userAvatar'],
      text: map['reviewText'],
      rating: map['ratingReview'],
      date: (map['date'] as Timestamp).toDate(),
      likes: List<String>.from(map['likes'] ?? []),
    );
  }

  String get avatarUrl {
    if (userAvatar != null && userAvatar!.isNotEmpty) {
      return userAvatar!;
    }
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=random';
  }
}