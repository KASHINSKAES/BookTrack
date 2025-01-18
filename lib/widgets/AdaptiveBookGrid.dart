import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'constants.dart';

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
    {"title": "Греческие и ...", "author": "Филипп Матышак", "image": ""},
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
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Container(
        padding: EdgeInsets.only(top: AppDimensions.baseScreenTop * scale),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.baseCircual * scale),
            topRight: Radius.circular(AppDimensions.baseCircual * scale),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.baseCrossAxisSpacing * scale),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppDimensions.baseCrossAxisSpacing * scale,
              mainAxisSpacing: AppDimensions.baseMainAxisSpacing * scale,
              childAspectRatio: AppDimensions.baseImageWidth /
                  (AppDimensions.baseImageHeight + 40 * scale),
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(
                title: book["title"]!,
                author: book["author"]!,
                image: book["image"]!,
                imageWidth: AppDimensions.baseImageWidth * scale,
                imageHeight: AppDimensions.baseImageHeight * scale,
                textSizeTitle: AppDimensions.baseTextSizeTitle * scale,
                textSizeAuthor: AppDimensions.baseTextSizeAuthor * scale,
                textSpacing: 6.0 * scale,
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
  final double imageWidth;
  final double imageHeight;
  final double textSizeTitle;
  final double textSizeAuthor;
  final double textSpacing;

  const BookCard({
    required this.title,
    required this.author,
    required this.image,
    required this.imageWidth,
    required this.imageHeight,
    required this.textSizeTitle,
    required this.textSizeAuthor,
    required this.textSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        image.isEmpty
            ? Container(
                width: imageWidth,
                height: imageHeight,
                decoration: BoxDecoration(
                  color: const Color(0xffFD521B),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SvgPicture.asset(
                  image,
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit.cover,
                ),
              ),
        SizedBox(height: textSpacing),
        Container(
          width: imageWidth, // Ensure the text has a defined width
          child: Text(
            title,
            style: TextStyle(
              fontSize: textSizeTitle,
              fontWeight: FontWeight.bold,
              color: const Color(0xff03044E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: textSpacing / 2),
        Container(
          width: imageWidth, // Ensure the text has a defined width
          child: Text(
            author,
            style: TextStyle(
              fontSize: textSizeAuthor,
              color: const Color(0xff575757),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
