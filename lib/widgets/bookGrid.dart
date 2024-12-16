import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdaptiveBookGrid extends StatelessWidget {
  final List<Map<String, String>> books = [
    {
      "title": "Бонсай",
      "author": "Алехандро Самбра",
      "image": "images/img1.svg"
    },
    {
      "title": "Янтарь рассе...",
      "author": "Люцида Аквила",
      "image": "images/img2.svg"
    },
    {
      "title": "Греческие и ...",
      "author": "Филипп Матышак",
      "image": "images/img6.svg"
    },
    {
      "title": "Безмолвное чтение. Том 1. Жюльен",
      "author": "Priest",
      "image": "images/img15.svg"
    },
    {
      "title": "Евгений Онегин",
      "author": "Александр Пушкин",
      "image": "images/img4.svg"
    },
    {
      "title": "Мастер и Маргарита",
      "author": "Михаил Булгаков",
      "image": "images/img5.svg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Определение количества колонок в зависимости от ширины экрана
        final crossAxisCount = screenWidth > 600 ? 4 : 3;

        // Динамичные отступы и размеры, основанные на ширине и высоте экрана
        final double gridPadding = screenWidth * 0.05; // Отступы по бокам
        final double crossAxisSpacing =
            screenWidth * 0.04; // Горизонтальные отступы
        final double mainAxisSpacing =
            screenHeight * 0.02; // Вертикальные отступы

        return Container(
          padding: EdgeInsets.only(top: screenHeight * 0.03),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(screenWidth * 0.05),
              topRight: Radius.circular(screenWidth * 0.05),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: gridPadding),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    crossAxisCount, // Количество колонок зависит от ширины экрана
                crossAxisSpacing: crossAxisSpacing, // Горизонтальные отступы
                mainAxisSpacing: mainAxisSpacing, // Вертикальные отступы
                childAspectRatio:
                    0.6, // Фиксированные пропорции карточки, сохраняющие правильное соотношение
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return BookCard(
                  title: book["title"]!,
                  author: book["author"]!,
                  image: book["image"]!,
                  imageHeight: screenHeight * 0.18, // Высота изображения
                  textSpacing: screenHeight * 0.008, // Отступы между элементами
                  textSizeTitle:
                      screenWidth * 0.04, // Размер текста для названия
                  textSizeAuthor:
                      screenWidth * 0.03, // Размер текста для автора
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String image;
  final double imageHeight;
  final double textSpacing;
  final double textSizeTitle;
  final double textSizeAuthor;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.image,
    required this.imageHeight,
    required this.textSpacing,
    required this.textSizeTitle,
    required this.textSizeAuthor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Обложка книги
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SvgPicture.asset(
            image,
            height: imageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: textSpacing), // Отступ между изображением и названием
        // Название книги
        Text(
          title,
          style: TextStyle(
            fontSize: textSizeTitle,
            fontWeight: FontWeight.bold,
            color: const Color(0xff03044E),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis, // Обрезка текста с "..."
        ),
        SizedBox(height: textSpacing), // Отступ между названием и автором
        // Автор книги
        Text(
          author,
          style: TextStyle(
            fontSize: textSizeAuthor,
            color: const Color(0xff575757),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // Обрезка текста с "..."
        ),
      ],
    );
  }
}
