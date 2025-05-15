import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final double scale;

  const FilterButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        textStyle: TextStyle(
          fontSize: AppDimensions.baseTextSizeButtonSort * scale,
          fontFamily: 'MPLUSRounded1c',
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppDimensions.baseCircualButton * scale),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 8 * scale,
        ),
      ),
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: AppColors.textPrimary,
        size: 19 * scale,
      ),
      label: Text(
        label,
        style: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }
}