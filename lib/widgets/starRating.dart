
import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final ValueChanged<double>? onRatingChanged;
  final bool isStatic;
  final double size;

  StarRating({
    Key? key,
    required this.rating,
    this.onRatingChanged,
    this.isStatic = false,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData icon;
        double ratingValue = index + 1;

        if (rating >= ratingValue) {
          icon = BookTrackIcon.starOtzv;
        } else if (rating > ratingValue - 1) {
          icon = BookTrackIcon.starOtzv;
        } else {
          icon = BookTrackIcon.starOtzv;
        }

        return IconButton(
          iconSize: size,
          icon: Icon(icon),
          color: rating >= ratingValue
              ? AppColors.orange
              : const Color.fromARGB(255, 253, 201, 184),
          onPressed: isStatic || onRatingChanged == null
              ? null
              : () => onRatingChanged!(ratingValue),
        );
      }),
    );
  }
}
