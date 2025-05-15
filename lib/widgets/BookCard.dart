import 'package:booktrack/icons.dart';
import 'package:booktrack/models/book.dart';
import 'package:booktrack/pages/BookDetailScreen.dart';
import 'package:booktrack/servises/reviewsServises.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BookCards extends StatefulWidget {
  final Book book;
  final double scale;
  final double imageWidth;
  final double imageHeight;
  final double textSizeTitle;
  final double textSizeAuthor;
  final double textSpacing;

  const BookCards({
    Key? key,
    required this.book,
    required this.scale,
    required this.imageWidth,
    required this.imageHeight,
    required this.textSizeTitle,
    required this.textSizeAuthor,
    required this.textSpacing,
  }) : super(key: key);
  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCards> {
  final ReviewService _reviewService = ReviewService();
  late Future<int?> _reviewsCountStream;
  int reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _reviewsCountStream = _reviewService.getReviewsCount(widget.book.id);
  }

  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
        future: _reviewsCountStream,
        builder: (context, snapshot) {
          reviewCount = snapshot.data ?? 0;
          debugPrint(reviewCount.toString());
          return GestureDetector(
            onTap: () => _navigateToDetail(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookImage(),
                SizedBox(height: widget.textSpacing),
                _buildRatingRow(),
                _buildTitle(),
                SizedBox(height: widget.textSpacing / 4),
                _buildAuthor(),
              ],
            ),
          );
        });
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(
          bookId: widget.book.id, // Передаем ID для загрузки деталей
          bookTitle: widget.book.title,
          authorName: widget.book.author,
          bookImageUrl: widget.book.imageUrl,
          bookRating: widget.book.rating,
          reviewCount: reviewCount,
          pages: widget.book.pages,
          age: widget.book.ageRestriction,
          description: widget.book.description,
          publisher: widget.book.publisher,
          yearPublisher: widget.book.yearPublisher,
          language: widget.book.language,
          price: widget.book.price,
          format: widget.book.format,
        ),
      ),
    );
  }

  Widget _buildBookImage() {
    return widget.book.imageUrl.isEmpty
        ? Container(
            width: widget.imageWidth,
            height: widget.imageHeight,
            decoration: BoxDecoration(
              color: const Color(0xffFD521B),
              borderRadius: BorderRadius.circular(8.0),
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SvgPicture.asset(
              widget.book.imageUrl,
              width: widget.imageWidth,
              height: widget.imageHeight,
              fit: BoxFit.cover,
              placeholderBuilder: (context) => Container(
                color: Colors.grey[200],
              ),
            ));
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        Icon(MyFlutterApp.star, color: AppColors.orange, size: 13),
        Text(
          widget.book.rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12 * widget.scale,
            fontWeight: FontWeight.bold,
            color: AppColors.orange,
          ),
        ),
        SizedBox(width: 6 * widget.scale),
        Icon(MyFlutterApp.chat, color: AppColors.grey, size: 10),
        Text(
          reviewCount.toString(),
          style: TextStyle(
            fontSize: 10,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.book.title,
      style: TextStyle(
        fontSize: widget.textSizeTitle,
        fontWeight: FontWeight.bold,
        color: const Color(0xff03044E),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      
    );
  }

  Widget _buildAuthor() {
    return Text(
      widget.book.author,
      style: TextStyle(
        fontSize: widget.textSizeAuthor,
        color: const Color(0xff575757),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
