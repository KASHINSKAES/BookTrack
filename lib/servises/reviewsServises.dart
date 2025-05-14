import 'package:booktrack/models/reviewModels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReview(String bookId, Review review) async {
    final bookRef = _firestore.collection('books').doc(bookId);
    final reviewsRef = bookRef.collection('reviews');

    // Транзакция для атомарного обновления
    await _firestore.runTransaction((transaction) async {
      // Добавляем отзыв
      transaction.set(reviewsRef.doc(), {
        'date': review.date,
        'likes': review.likes,
        'ratingReview': review.rating,
        'reviewText': review.text,
        'userId': review.userId,
      });

      // Обновляем рейтинг книги
      final bookDoc = await transaction.get(bookRef);
      final currentRating = bookDoc['rating'] ?? 0.0;
      final currentCount = bookDoc['reviewsCount'] ?? 0;

      final newCount = currentCount + 1;
      final newRating =
          ((currentRating * currentCount) + review.rating) / newCount;

      transaction.update(bookRef, {
        'rating': newRating,
        'reviewsCount': newCount,
      });
    });
  }

  Future<int?> getReviewsCount(String bookId) async {
    final snapshot = await _firestore
        .collection('books')
        .doc(bookId)
        .collection('reviews')
        .count()
        .get();
    return snapshot.count;
  }

  Stream<int> watchReviewsCount(String bookId) {
    final snapshot = _firestore
        .collection('reviews')
        .where('bookId', isEqualTo: bookId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
    return snapshot;
  }
}
