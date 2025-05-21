import 'package:booktrack/models/chaptersModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import '../../../models/book.dart';

class BookRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получаем книгу с главами
  Future<BookWithChapters> getBookWithChapters(String bookId) async {
    try {
      // Загружаем книгу
      final bookDoc = await _firestore.collection('books').doc(bookId).get();
      if (!bookDoc.exists) {
        throw Exception('Книга с ID $bookId не найдена');
      }

      // Загружаем главы
      final chaptersQuery = await _firestore
          .collection('books')
          .doc(bookId)
          .collection('chapters')
          .get();

      // Отладочный вывод
      print('Книга загружена: ${bookDoc.id}');
      print('Найдено глав: ${chaptersQuery.docs.length}');
      if (chaptersQuery.docs.isEmpty) {
        print('Глав нет! Проверьте: books/$bookId/chapters в Firestore');
      }

      return BookWithChapters(
        book: Book.fromFirestore(bookDoc),
        chapters: chaptersQuery.docs.map(Chapter.fromFirestore).toList(),
      );
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Ошибка загрузки книги и глав: $e');
    }
  }
    Future<BookWithChapters> getBasicBookInfo(String bookId) async {
    try {
      // Загружаем книгу
      final bookDoc = await _firestore.collection('books').doc(bookId).get();
      if (!bookDoc.exists) {
        throw Exception('Книга с ID $bookId не найдена');
      }

      // Загружаем главы
      final chaptersQuery = await _firestore
          .collection('books')
          .doc(bookId)
          .collection('chapters')
          .limit(3)
          .get();

      // Отладочный вывод
      print('Книга загружена: ${bookDoc.id}');
      print('Найдено глав: ${chaptersQuery.docs.length}');
      if (chaptersQuery.docs.isEmpty) {
        print('Глав нет! Проверьте: books/$bookId/chapters в Firestore');
      }

      return BookWithChapters(
        book: Book.fromFirestore(bookDoc),
        chapters: chaptersQuery.docs.map(Chapter.fromFirestore).toList(),
      );
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Ошибка загрузки книги и глав: $e');
    }
  }
}

class BookWithChapters {
  final Book book;
  final List<Chapter> chapters;

  BookWithChapters({required this.book, required this.chapters});
}
