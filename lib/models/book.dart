import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Book {
  final String id;
  final String ageRestriction;
  final String author;
  final String description;
  final int pages;
  final int price;
  final String publisher;
  final double rating;
  final bool isExclusive;
  final bool isSubscription;
  final String format;
  final String language;
  final List<String> subcollection;
  final String title;
  final String imageUrl;
  final int yearPublisher;

  Book({
    required this.id,
    required this.ageRestriction,
    required this.author,
    required this.description,
    required this.pages,
    required this.price,
    required this.publisher,
    required this.rating,
    required this.isExclusive,
    required this.isSubscription,
    required this.format,
    required this.language,
    required this.subcollection,
    required this.title,
    required this.imageUrl,
    required this.yearPublisher,
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    // Добавьте проверку данных
    final data =
        doc.data() as Map<String, dynamic>? ?? {}; // Добавлен null-check
    debugPrint(
        'Processing document: ${doc.id}, data keys: ${data.keys.join(', ')}');

    // Добавьте валидацию для сложных полей
    List<String> safeSubcollection = [];
    if (data['subcollection'] is List) {
      safeSubcollection = List<String>.from(
          data['subcollection'].where((item) => item is String));
    }

    return Book(
      id: doc.id,
      ageRestriction: data['ageRestriction'] ?? 'N/A',
      author: data['author'] ?? 'Неизвестен',
      description: data['description'] ?? '',
      pages: data['pages'] ?? 0,
      price: data['price'] ?? 0,
      publisher: data['publisher'] ?? '',
      rating: data['raiting'] ?? 0,
      isExclusive: data['isExclusive'] ?? false,
      isSubscription: data['isSubscription'] ?? false,
      format: data['format'] ?? 'text',
      language: data['language'] ?? 'Русский',
      subcollection: safeSubcollection,
      title: data['title'] ?? '',
      imageUrl: data['url'] ?? '',
      yearPublisher: data['yearPublisher'] ?? 0,
    );
  }
}
