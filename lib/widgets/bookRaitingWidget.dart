import 'package:booktrack/servises/reviewsServises.dart';
import 'package:booktrack/widgets/RaitingView.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookRatingWidget extends StatefulWidget {
  final String bookId;

  const BookRatingWidget({Key? key, required this.bookId}) : super(key: key);

  @override
  _BookRatingWidgetState createState() => _BookRatingWidgetState();
}

class _BookRatingWidgetState extends State<BookRatingWidget> {
  final ReviewService _reviewService = ReviewService();
  late Stream<Map<String, dynamic>> _bookDataStream;

  @override
  void initState() {
    super.initState();
    _bookDataStream = _createBookDataStream();
  }

  Stream<Map<String, dynamic>> _createBookDataStream() {
    // Создаем поток для данных книги
    final bookStream = FirebaseFirestore.instance
        .collection('books')
        .doc(widget.bookId)
        .snapshots();

    // Комбинируем с потоком количества отзывов
    return bookStream.asyncMap((bookDoc) async {
      final reviewCount = await _reviewService.getReviewsCount(widget.bookId);
      return {
        'raiting': bookDoc.data()?['raiting'] ?? 0.0,
        'reviewCount': reviewCount ?? 0,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
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

        return RatingRow(
          bookRating: snapshot.data?['raiting'] ?? 0.0,
          reviewCount: snapshot.data?['reviewCount'] ?? 0,
        );
      },
    );
  }
}