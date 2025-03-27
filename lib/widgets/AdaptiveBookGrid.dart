import 'package:booktrack/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'constants.dart';
import '/pages/BookDetailScreen.dart';

class AdaptiveBookGrid extends StatelessWidget {
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
            crossAxisSpacing: AppDimensions.baseCrossAxisSpacingBlock * scale,
            mainAxisSpacing: AppDimensions.baseMainAxisSpacing * scale,
            childAspectRatio: AppDimensions.baseImageWidth /
                (AppDimensions.baseImageHeight + 40 * scale),
          ),
          itemCount: Book.books.length,
          itemBuilder: (context, index) {
            final book = Book.books[index];
            return BookCard(
              title: book.title,
              author: book.author,
              image: book.image,
              bookRating: book.bookRating,
              reviewCount: book.reviewCount,
              imageWidth: AppDimensions.baseImageWidth * scale,
              imageHeight: AppDimensions.baseImageHeight * scale,
              textSizeTitle: AppDimensions.baseTextSizeTitle * scale,
              textSizeAuthor: AppDimensions.baseTextSizeAuthor * scale,
              textSpacing: 6.0 * scale,
              scale: scale,
            );
          },
        ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String image;
  final double bookRating;
  final double scale;
  final int reviewCount;
  final double imageWidth;
  final double imageHeight;
  final double textSizeTitle;
  final double textSizeAuthor;
  final double textSpacing;

  const BookCard({
    Key? key,
    required this.title,
    required this.author,
    required this.image,
    required this.bookRating,
    required this.scale,
    required this.reviewCount,
    required this.imageWidth,
    required this.imageHeight,
    required this.textSizeTitle,
    required this.textSizeAuthor,
    required this.textSpacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(
              bookTitle: title,
              authorName: author,
              bookImageUrl: image,
              bookRating: 8.6,
              reviewCount: 100,
              pages: 320,
              age: 16,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image.isEmpty)
            Container(
              width: imageWidth,
              height: imageHeight,
              decoration: BoxDecoration(
                color: const Color(0xffFD521B),
                borderRadius: BorderRadius.circular(8.0),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SvgPicture.asset(
                image,
                width: imageWidth,
                height: imageHeight,
                fit: BoxFit.cover,
                cacheColorFilter: true, // Кэширование SVG
              ),
            ),
          SizedBox(height: textSpacing),
          Row(
            children: [
              Icon(MyFlutterApp.star, color: AppColors.orange, size: 13),
              Text(
                bookRating.toString(),
                style: TextStyle(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orange),
              ),
              SizedBox(width: 6 * scale),
              Icon(MyFlutterApp.chat, color: AppColors.grey, size: 10),
              Text(
                reviewCount.toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: textSizeTitle,
              fontWeight: FontWeight.bold,
              color: const Color(0xff03044E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: textSpacing / 2),
          Text(
            author,
            style: TextStyle(
              fontSize: textSizeAuthor,
              color: const Color(0xff575757),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
