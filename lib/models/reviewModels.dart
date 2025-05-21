import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String bookId;
  final String userId;
  final String userName;
  final String text;
  final int rating; // 1-5
  final DateTime date;
  final List<String> likes;

  Review({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.rating,
    required this.date,
    List<String>? likes,
  }) : likes = likes ?? [];

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Review(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      userId: data['userId'],
      userName: data['userName'] ?? 'Аноним',
      text: data['reviewText'],
      rating: data['ratingReview'],
      date: (data['date'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'userName': userName,
      'reviewText': text,
      'ratingReview': rating,
      'date': Timestamp.fromDate(date),
      'likes': likes,
    };
  }

  String get avatarUrl {
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=random';
  }
}
