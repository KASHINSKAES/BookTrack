import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class SelectableButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final double textSizeButton;
  final VoidCallback onTap;

  const SelectableButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.textSizeButton,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.background : Colors.white,
        foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
        side: BorderSide(
          color: isSelected ? AppColors.background : Colors.grey.shade300,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12 * (textSizeButton / 14),
          vertical: 8 * (textSizeButton / 14),
        ),
      ),
      onPressed: onTap,
      icon: Icon(icon,
          size: 16 * (textSizeButton / 14),
          color: isSelected ? Colors.white : AppColors.background),
      label: Text(
        label,
        style: TextStyle(fontSize: textSizeButton),
      ),
    );
  }
}
