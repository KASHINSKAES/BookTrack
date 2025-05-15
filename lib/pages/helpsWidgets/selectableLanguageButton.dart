import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class SelectableLanguageButton extends StatelessWidget {
  final String label;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;
  final double textSizeButton;

  const SelectableLanguageButton({
    required this.label,
    required this.flag,
    required this.isSelected,
    required this.onTap,
    required this.textSizeButton,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
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
          horizontal: 16 * (textSizeButton / 14),
          vertical: 8 * (textSizeButton / 14),
        ),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: TextStyle(fontSize: textSizeButton * 1.2)),
          SizedBox(width: 8 * (textSizeButton / 14)),
          Text(
            label,
            style: TextStyle(fontSize: textSizeButton),
          ),
        ],
      ),
    );
  }
}