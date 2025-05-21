import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/models/book.dart';
import 'package:booktrack/pages/BookDetailScreen.dart';
import 'package:booktrack/servises/reviewsServises.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late Stream<Map<String, dynamic>> _bookDataStream;

  @override
  void initState() {
    super.initState();
    _bookDataStream = _createBookDataStream();
    _reviewsCountStream = _reviewService.getReviewsCount(widget.book.id);
  }

  Stream<Map<String, dynamic>> _createBookDataStream() {
    // Создаем поток для данных книги
    final bookStream = FirebaseFirestore.instance
        .collection('books')
        .doc(widget.book.id)
        .snapshots();

    // Комбинируем с потоком количества отзывов
    return bookStream.asyncMap((bookDoc) async {
      final reviewCount = await _reviewService.getReviewsCount(widget.book.id);
      return {
        'raiting': bookDoc.data()?['raiting'] ?? 0.0,
        'reviewCount': reviewCount ?? 0,
      };
    });
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
    debugPrint('${widget.book.rating} raiting');

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
          tags: widget.book.tags,
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
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return StreamBuilder<Map<String, dynamic>>(
      stream: _bookDataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 100 * scale,
            height: 20 * scale,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        if (snapshot.hasError) {
          return Text('Ошибка загрузки',
              style: TextStyle(fontSize: 12 * scale));
        }

        return Row(
          children: [
            Icon(BookTrackIcon.starOtzv, color: AppColors.orange, size: 13),
            Text(
              snapshot.data!['raiting'].toString(),
              style: TextStyle(
                fontSize: 12 * widget.scale,
                fontWeight: FontWeight.bold,
                color: AppColors.orange,
              ),
            ),
            SizedBox(width: 6 * widget.scale),
            Icon(BookTrackIcon.comOtzv, color: AppColors.grey, size: 10),
            Text(
              snapshot.data!['reviewCount'].toString(),
              style: TextStyle(
                fontSize: 10,
                color: AppColors.grey,
              ),
            ),
          ],
        );
      },
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
