import 'package:booktrack/models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _perPage = 10;
  static Stream<QuerySnapshot>? _cachedBooksStream;

  Future<List<Book>> getBooksPaginated(int page,
      {DocumentSnapshot? lastDocument}) async {
    Query query =
        _firestore.collection('books').orderBy('title').limit(_perPage);

    if (page > 0 && lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final books = snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();

    return books;
  }

  Stream<List<Book>> filterBooks({
    bool? isSubscription,
    bool? isExclusive,
    String? format,
    String? language,
    double? minRating,
  }) {
    Query query = _firestore.collection('books');

    if (isSubscription != null)
      query = query.where('isSubscription', isEqualTo: isSubscription);
    if (isExclusive != null)
      query = query.where('isExclusive', isEqualTo: isExclusive);
    if (format != null) query = query.where('format', isEqualTo: format);
    if (language != null) query = query.where('language', isEqualTo: language);
    if (minRating != null)
      query = query.where('rating', isGreaterThanOrEqualTo: minRating);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    });
  }

  Stream<QuerySnapshot> getBooksStream() {
    _cachedBooksStream ??= _firestore.collection('books').limit(20).snapshots();
    return _cachedBooksStream!;
  }

  Stream<List<Book>> getBooksStreams() {
    return _firestore
        .collection('books')
        .limit(6)
        .snapshots()
        .handleError((error) {
      debugPrint("Ошибка получения книг: $error");
      throw error;
    }).map((snapshot) =>
            snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  // Для сброса кеша при необходимости
  static void resetCache() {
    _cachedBooksStream = null;
  }

  Future<Book> getBookDetails(String bookId) async {
    final doc = await _firestore.collection('books').doc(bookId).get();
    return Book.fromFirestore(doc);
  }
}
