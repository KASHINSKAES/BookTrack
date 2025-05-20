import 'package:booktrack/BookTrackIcon.dart';
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
          child: CircleAvatar(
            backgroundColor: Colors.white, // цвет круга
            radius: 20, // радиус круга
            child: Center(
              child: Icon(
                isSaved
                    ? BookTrackIcon.heartSelectetFull
                    : BookTrackIcon.heartSelectet,
                size: isSaved ? size - 4 : size,
                color: AppColors.orange,
              ),
            ),
          ),
        ));
  }
}
