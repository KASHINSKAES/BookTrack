
import 'package:booktrack/models/reviewModels.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/pages/BookCard/Detail/addReview.dart';
import 'package:booktrack/servises/reviewsServises.dart';
import 'package:booktrack/widgets/LikeButtonWithCounter.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:booktrack/widgets/starRating.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class BookReviewsWidget extends StatefulWidget {
  final String bookId;
  final double scale;

  const BookReviewsWidget({Key? key, required this.bookId, required this.scale})
      : super(key: key);

  @override
  _BookReviewsWidgetState createState() => _BookReviewsWidgetState();
}

class _BookReviewsWidgetState extends State<BookReviewsWidget> {
  final ReviewService _reviewService = ReviewService();
  late Future<List<Review>> _reviewsFuture;
  double _bookRating = 0;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _loadReviews();
  }

  Future<List<Review>> _loadReviews() async {
    final reviews = await _reviewService.getReviewsForBook(widget.bookId);

    if (reviews.isNotEmpty) {
      final total = reviews.fold(0, (sum, review) => sum + review.rating);
      _bookRating = double.parse((total / reviews.length).toStringAsFixed(1));
    }

    return reviews;
  }

  void _navigateToAddReview() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReviewPage(
            bookId: widget.bookId,
            onBack: () {
              Navigator.pop(context);
            }),
      ),
    );

    if (result == true) {
      setState(() {
        _reviewsFuture = _loadReviews();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: _reviewsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint(snapshot.error.toString());
          return Text('Ошибка загрузки отзывов');
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildNoReviews();
        }

        final reviews = snapshot.data!;
        debugPrint('Review ${reviews.toString()}');

        return _buildReviewsSection(reviews);
      },
    );
  }

  Widget _buildNoReviews() {
    return Column(
      children: [
        Text(
          'Пока нет отзывов',
          style: TextStyle(
            fontSize: 16 * widget.scale,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 16 * widget.scale),
        ElevatedButton(
          onPressed: _navigateToAddReview,
          child: Text('Написать первый отзыв'),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(List<Review> reviews) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                StarRating(
                  rating: _bookRating,
                  isStatic: true,
                  size: 24 * widget.scale,
                ),
                SizedBox(width: 8 * widget.scale),
                Text(
                  _bookRating.toString(),
                  style: TextStyle(
                    fontSize: 18 * widget.scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orange,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _navigateToAddReview,
              child: Text('+ Добавить отзыв'),
            ),
          ],
        ),
        SizedBox(height: 16 * widget.scale),
        SizedBox(
          height: 250 * widget.scale,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              debugPrint('Review ${reviews.toString()}');

              return _buildReviewCard(reviews[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final currentUserId = authProvider.userModel?.uid;
    
    return Container(
      width: 350 * widget.scale,
      margin: EdgeInsets.only(right: 16 * widget.scale),
      padding: EdgeInsets.all(16 * widget.scale),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20 * widget.scale,
                backgroundImage: NetworkImage(review.avatarUrl),
              ),
              SizedBox(width: 10 * widget.scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(
                          fontSize: 16 * widget.scale,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    Text(
                      DateFormat('dd MMMM yyyy', 'ru_RU').format(review.date),
                      style: TextStyle(
                        fontSize: 13 * widget.scale,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          StarRating(
            rating: review.rating.toDouble(),
            isStatic: true,
            size: 18 * widget.scale,
          ),
          SizedBox(height: 8 * widget.scale),
          ExpandableText(
            text: review.text,
            scale: widget.scale,
          ),
          SizedBox(height: 8 * widget.scale),
          LikeButtonWithCounter(
            bookId: widget.bookId,
            reviewId: review.id,
            currentUserId: currentUserId,
          )
        ],
      ),
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final double scale;
  final int maxChars;

  const ExpandableText({
    Key? key,
    required this.text,
    this.scale = 1.0,
    this.maxChars = 150,
  }) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isLongText = widget.text.length > widget.maxChars;
    final displayText = _isExpanded || !isLongText
        ? widget.text
        : widget.text.substring(0, widget.maxChars) + '...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayText,
          style: TextStyle(
            fontSize: 14 * widget.scale,
          ),
        ),
        if (isLongText)
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(50, 30 * widget.scale),
            ),
            onPressed: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            child: Text(
              _isExpanded ? "Свернуть" : "Читать далее",
              style: TextStyle(
                fontSize: 14 * widget.scale,
                color: Colors.blue,
              ),
            ),
          ),
      ],
    );
  }
}
