import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class RatingRow extends StatelessWidget {
  final double bookRating;
  final int reviewCount;

  const RatingRow({
    required this.bookRating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(BookTrackIcon.starOtzv, size: 16 * scale, color: AppColors.orange),
        Text(
          '$bookRating',
          style: TextStyle(
            fontSize: 16 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.orange,
          ),
        ),
        SizedBox(width: 6 * scale),
        Icon(BookTrackIcon.comOtzv, size: 16 * scale, color: AppColors.grey),
        SizedBox(width: 4 * scale),
        Text(
          '$reviewCount',
          style: TextStyle(
            fontSize: 12 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
}