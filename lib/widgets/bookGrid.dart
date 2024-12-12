import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BookGrid extends StatelessWidget {
  // Пример данных

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
      "title": "Евгений Онегин [Борис Годунов Маленькие трагедии]",
      "author": "Александр Пушкин",
      "image": "images/img4.svg"
    },
    {
      "title": "Мастер и Маргарита. Вечные истории. Young Adult",
      "author": "Михаил Булгаков",
      "image": "images/img5.svg"
    },
    
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 25),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 21), // Общий отступ вокруг сетки
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Три книги в ряду
              crossAxisSpacing: 12, // Расстояние между колонками
              mainAxisSpacing: 13, // Расстояние между строками
              childAspectRatio: 120 / 210, // Пропорции карточки (ширина/высота)
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(
                title: book["title"]!,
                author: book["author"]!,
                image: book["image"]!,
              );
            },
          ),
        ));
  }
}

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String image;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Обложка книги
        ClipRRect(
          borderRadius:
              BorderRadius.circular(8), // Радиус углов для изображения
          child: SvgPicture.asset(
            image,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 6), // Отступ между изображением и текстом
        // Название книги
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xff03044E),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis, // Обрезка текста с "..."
        ),
        SizedBox(height: 3), // Отступ между названием и автором
        // Автор книги
        Text(
          author,
          style: TextStyle(
            fontSize: 10,
            color: Color(0xff575757),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // Обрезка текста с "..."
        ),
      ],
    );
  }
}
