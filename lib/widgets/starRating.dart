import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final ValueChanged<double>? onRatingChanged;
  final bool isStatic;
  final double size;
  final Color color;

  const StarRating({
    Key? key,
    required this.rating,
    this.onRatingChanged,
    this.isStatic = false,
    this.size = 24,
    this.color = Colors.orange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        IconData icon;
        double ratingValue = index + 1;

        if (rating >= ratingValue) {
          icon = Icons.star;
        } else if (rating > ratingValue - 1) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }

        return IconButton(
          iconSize: size,
          icon: Icon(icon),
          color: color,
          onPressed: isStatic || onRatingChanged == null
              ? null
              : () => onRatingChanged!(ratingValue),
        );
      }),
    );
  }
}