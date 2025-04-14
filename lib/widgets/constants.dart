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
  static const baseCrossAxisSpacingBlock = 3.0;
  static const baseTextSizeButtonSort = 12.0;
  static const baseTextSizeFiltrTitle = 24.0;
  static const baseTextSizeFiltrText = 14.0;
  static const baseMainAxisSpacing = 12.0;
  static const baseScreenTop = 26.0;
  static const baseBoxWidthTimer = 330.0;
  static const baseBoxHeightTimer = 77.0;
}

class AppColors {
  static const background = Color(0xff5775CD);
  static const textPrimary = Color(0xff03044E);
  static const textSecondary = Color(0xff636391);
  static const blueColor = Color(0xffB8BEF6);
  static const blueColorLight = Color(0xffCDD2FF);
  static const buttonBorder = Color(0xff5775CD);
  static const orange = Color(0xffFD521B);
  static const orangeLight = Color(0xffFFD3C5);
  static const grey = Color(0xff575757);
}

// book_model.dart
class Book {
  final String title;
  final String author;
  final String image;
  final double bookRating;
  final int reviewCount;

  Book(
      {required this.title,
      required this.author,
      required this.image,
      required this.bookRating,
      required this.reviewCount});

  static List<Book> get books => [
        Book(
            title: "Бонсай",
            author: "Алехандро Самбра",
            image: "images/img1.svg",
            bookRating: 8.6,
            reviewCount: 100),
        Book(
            title: "Янтарь рассе...",
            author: "Люцида Аквила",
            image: "images/img2.svg",
            bookRating: 8.6,
            reviewCount: 100),
        Book(
            title: "Греческие и ...",
            author: "Филипп Матышак",
            image: "images/img6.svg",
            bookRating: 8.6,
            reviewCount: 100),
        Book(
            title: "Безмолвное чтение. Том 1. Жюльен",
            author: "Priest",
            image: "images/img15.svg",
            bookRating: 8.6,
            reviewCount: 100),
        Book(
            title: "Евгений Онегин",
            author: "Александр Пушкин",
            image: "images/img4.svg",
            bookRating: 8.6,
            reviewCount: 100),
        Book(
            title: "Мастер и Маргарита",
            author: "Михаил Булгаков",
            image: "images/img5.svg",
            bookRating: 8.6,
            reviewCount: 100),
      ];
}
