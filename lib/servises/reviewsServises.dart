import 'package:booktrack/models/reviewModels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Добавление отзыва с обновлением рейтинга книги
  Future<void> addReview({
    required String bookId,
    required String userId,
    required String userName,
    required String text,
    required int rating,
  }) async {
    if (rating < 1 || rating > 5) {
      throw ArgumentError('Рейтинг должен быть от 1 до 5');
    }
    if (text.isEmpty) {
      throw ArgumentError('Текст отзыва не может быть пустым');
    }

    final review = Review(
      id: '',
      bookId: bookId,
      userId: userId,
      userName: userName,
      text: text,
      rating: rating,
      date: DateTime.now(),
    );

    await _addReviewWithTransaction(bookId, review);
  }

  Future<void> _addReviewWithTransaction(String bookId, Review review) async {
    final bookRef = _firestore.collection('books').doc(bookId);
    final reviewsRef = bookRef.collection('reviews');
    final newReviewRef = reviewsRef.doc();

    try {
      await _firestore.runTransaction((transaction) async {
        // Проверяем существование книги
        final bookDoc = await transaction.get(bookRef);
        if (!bookDoc.exists) {
          throw Exception('Книга не найдена');
        }

        // Добавляем отзыв
        transaction.set(newReviewRef, review.toMap());

        // Обновляем рейтинг книги
        final currentRating = _safeCastToDouble(bookDoc.data()?['raiting']);
        final currentCount = _safeCastToInt(bookDoc.data()?['reviewsCount']);

        debugPrint('Current raiting: $currentRating, count: $currentCount');

        final newCount = currentCount + 1;
        debugPrint('${currentCount}');
        debugPrint('${currentRating}');
        final newRating =
            ((currentRating * currentCount) + review.rating) / newCount;
        debugPrint('${newRating}');

        final updatedRating = double.parse(newRating.toStringAsFixed(1));

        debugPrint('${updatedRating}');
        debugPrint('New rating: $updatedRating, count: $newCount');

        transaction.update(bookRef, {
          'raiting': updatedRating,
          'reviewsCount': newCount,
        });
      });

      debugPrint('Transaction completed successfully');
    } catch (e, stackTrace) {
      debugPrint('Transaction error: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

// Вспомогательные методы для безопасного приведения типов
  double _safeCastToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return 0.0;
  }

  int _safeCastToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return 0;
  }

  // Получение всех отзывов для книги
  Stream<List<Review>> getReviewsStream(String bookId) {
    return _firestore
        .collection('books')
        .doc(bookId)
        .collection('reviews')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  Stream<int> getReviewsCountStream(String bookId) {
  return FirebaseFirestore.instance
      .collection('reviews')
      .where('bookId', isEqualTo: bookId)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}

  // Переключение лайка на отзыве
 Future<void> toggleLike(String bookId, String reviewId, String userId) async {
    final reviewRef = _firestore
        .collection('books')
        .doc(bookId)
        .collection('reviews')
        .doc(reviewId);

    try {
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(reviewRef);
        if (!doc.exists) throw Exception('Review not found');

        final currentLikes = List<String>.from(doc['likes'] ?? []);
        currentLikes.contains(userId) 
            ? currentLikes.remove(userId)
            : currentLikes.add(userId);

        transaction.update(reviewRef, {'likes': currentLikes});
      });
    } on FirebaseException catch (e) {
      throw 'Не удалось обновить лайк: ${e.message}';
    }
  }

  // Получение среднего рейтинга книги
  Future<double> getBookRating(String bookId) async {
    final doc = await _firestore.collection('books').doc(bookId).get();
    return (doc.data()?['rating'] as num?)?.toDouble() ?? 0.0;
  }

  // Проверка, оставлял ли пользователь отзыв на книгу
  Future<bool> hasUserReviewed(String bookId, String userId) async {
    final snapshot = await _firestore
        .collection('books')
        .doc(bookId)
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<List<Review>> getReviewsForBook(String bookId) async {
    final snapshot = await _firestore
        .collection('books')
        .doc(bookId)
        .collection('reviews')
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
  }

  // Получение количества отзывов (оптимизированная версия)
  Future<int> getReviewsCount(String bookId) async {
    final snapshot = await _firestore
        .collection('books')
        .doc(bookId)
        .collection('reviews')
        .count()
        .get();
    return snapshot.count ?? 0; // Добавляем fallback значение
  }
}
