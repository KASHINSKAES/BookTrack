import 'package:flutter/material.dart';

class AppDimensions {
  static const baseWidth = 375.0;
  static const baseCircual = 20.0;
  static const baseCircualButton = 24.0;
  static const baseImageWidth = 105.0;
  static const baseImageHeight = 160.0;
  static const baseTextSizeButton = 20.0;
  static const baseTextSizeTitle = 13.0;
  static const baseTextSizeh1 = 32.0;
  static const baseTextSizeAuthor = 10.0;
  static const baseCrossAxisSpacing = 12.0;
  static const baseTextSizeButtonSort = 12.0;
  static const baseTextSizeFiltrTitle = 24.0;
  static const baseTextSizeFiltrText = 14.0;
  static const baseMainAxisSpacing = 13.0;
  static const baseScreenTop = 26.0;
}

class AppColors {
  static const background = Color(0xff5775CD);
  static const textPrimary = Color(0xff03044E);
  static const textSecondary = Color(0xff636391);
  static const buttonBorder = Color(0xff5775CD);
}

// book_model.dart
class Book {
  final String title;
  final String author;
  final String image;

  Book({required this.title, required this.author, required this.image});

  static List<Book> get books => [
        Book(
            title: "Бонсай",
            author: "Алехандро Самбра",
            image: "images/img1.svg"),
        Book(
            title: "Янтарь рассе...",
            author: "Люцида Аквила",
            image: "images/img2.svg"),
        Book(
            title: "Греческие и ...",
            author: "Филипп Матышак",
            image: "images/img6.svg"),
        Book(
            title: "Безмолвное чтение. Том 1. Жюльен",
            author: "Priest",
            image: "images/img15.svg"),
        Book(
            title: "Евгений Онегин",
            author: "Александр Пушкин",
            image: "images/img4.svg"),
        Book(
            title: "Мастер и Маргарита",
            author: "Михаил Булгаков",
            image: "images/img5.svg"),
      ];
}
