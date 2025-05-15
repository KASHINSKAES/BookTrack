import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class CustomSwitchTile extends StatelessWidget {
  final double scale;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String? subtitle;

  const CustomSwitchTile({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.scale,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      activeTrackColor: AppColors.background.withOpacity(0.5),
      activeColor: AppColors.background,
      inactiveThumbColor: Colors.grey.shade400,
      inactiveTrackColor: Colors.grey.shade300,
      onChanged: onChanged,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20.0 * scale,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 14.0 * scale,
                color: AppColors.textSecondary,
              ),
            )
          : null,
    );
  }
}