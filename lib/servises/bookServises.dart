import 'package:booktrack/models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

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
  Future<List<Book>> getBooks(String category) async {
  try {
    Query query = _firestore.collection('books');
    
    switch (category) {
      case 'recommendations':
        query = query.where('isRecommended', isEqualTo: true).limit(10);
        break;
      case 'popular':
        query = query.orderBy('views', descending: true).limit(10);
        break;
      case 'genres':
        query = query.orderBy('genre').limit(10);
        break;
      case 'coming_soon':
        final now = DateTime.now();
        query = query.where('releaseDate', isGreaterThan: now).orderBy('releaseDate').limit(10);
        break;
      default:
        query = query.limit(10);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
  } catch (e) {
    debugPrint('Error getting books: $e');
    return [];
  }
}

  Stream<List<Book>> getUserBooksStream({
    required String userId,
    required String listType, // 'saved_books', 'read_books', 'end_books'
    int limit = 20,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncMap((userDoc) async {
      final userData = userDoc.data() ?? {};
      final bookIds = List<String>.from(userData[listType] ?? []);

      if (bookIds.isEmpty) return [];

      // Чтобы избежать ошибки при пустом списке
      final limitedBookIds = bookIds.take(limit).toList();

      final books = await _firestore
          .collection('books')
          .where(FieldPath.documentId, whereIn: limitedBookIds)
          .get();

      return books.docs.map((doc) => Book.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Book>> getSimilarBooksStream({
    required String currentBookId,
    required String format,
    required String language,
    int limit = 5,
  }) {
    // Запрос 1: Книги с подходящим форматом (но не текущая книга)
    final formatStream = _firestore
        .collection('books')
        .where('format', isEqualTo: format)
        .where(FieldPath.documentId, isNotEqualTo: currentBookId)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());

    // Запрос 2: Книги с подходящим языком (но не текущая книга)
    final languageStream = _firestore
        .collection('books')
        .where('language', isEqualTo: language)
        .where(FieldPath.documentId, isNotEqualTo: currentBookId)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());

    // Объединяем два Stream с логикой OR (используем rxdart)
    return Rx.combineLatestList([formatStream, languageStream])
        .map((listOfLists) {
      // Объединяем результаты и убираем дубликаты
      final allBooks = listOfLists.expand((books) => books).toList();
      final uniqueBooks = allBooks
          .fold(<String, Book>{}, (map, book) {
            map.putIfAbsent(book.id, () => book);
            return map;
          })
          .values
          .toList();

      return uniqueBooks.take(limit).toList(); // Ограничиваем лимитом
    });
  }

  // Для книг того же автора
  Stream<List<Book>> getAuthorBooksStream({
    required String currentBookId,
    required String author,
    int limit = 5,
  }) {
    return _firestore
        .collection('books')
        .where('author', isEqualTo: author)
        .where(FieldPath.documentId, isNotEqualTo: currentBookId)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList());
  }

  Stream<List<Book>> getAllBooks() {
    return _firestore.collection('books').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    });
  }
  Future<void> toggleSavedBook(String userId, String bookId) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await userRef.update({
        'saved_books': FieldValue.arrayUnion([bookId]),
      });
    } catch (e) {
      debugPrint('Error adding to saved books: $e');
      rethrow;
    }
  }

  Future<void> removeSavedBook(String userId, String bookId) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await userRef.update({
        'saved_books': FieldValue.arrayRemove([bookId]),
      });
    } catch (e) {
      debugPrint('Error removing from saved books: $e');
      rethrow;
    }
  }

  Future<void> toggleSavedStatus(String userId, String bookId, bool isCurrentlySaved) async {
    if (isCurrentlySaved) {
      await removeSavedBook(userId, bookId);
    } else {
      await toggleSavedBook(userId, bookId);
    }
  }

  Stream<bool> isBookSaved(String userId, String bookId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          final savedBooks = List<String>.from(snapshot.data()?['saved_books'] ?? []);
          return savedBooks.contains(bookId);
        });
  }
}
