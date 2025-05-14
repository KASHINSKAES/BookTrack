import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final Timestamp date;
  final int likes;
  final double rating;
  final String text;
  final String userId;

  Review({
    required this.date,
    required this.likes,
    required this.rating,
    required this.text,
    required this.userId,
  });

  factory Review.fromFirestore(Map<String, dynamic> data) {
    return Review(
      date: data['date'],
      likes: data['likes'] ?? 0,
      rating: (data['ratingReview'] ?? 0).toDouble(),
      text: data['reviewText'] ?? '',
      userId: data['userId'],
    );
  }
}