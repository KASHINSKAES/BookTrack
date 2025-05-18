import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class FavoriteIcon extends StatelessWidget {
  final bool isSaved;
  final VoidCallback onPressed;
  final double size;

  const FavoriteIcon({
    super.key,
    required this.isSaved,
    required this.onPressed,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size + 8,
        height: size + 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.orange,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(
            isSaved ? Icons.favorite : Icons.favorite_border,
            size: size,
            color: isSaved ? AppColors.orange : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
