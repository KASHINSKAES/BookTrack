import 'package:booktrack/pages/BookCard/text/SettingsProvider.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EpigraphWidgets extends StatelessWidget {
  final String text;
  final String? author;

  const EpigraphWidgets({
    required this.text,
    required this.author,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border(
              left: BorderSide(
                  color: _getTextColor(settings.selectedBackgroundStyle),
                  width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: settings.fontSize * 0.9,
                fontStyle: FontStyle.italic,
                fontFamily: _getFontFamily(settings.selectedFontFamily),
                color: _getTextColor(settings.selectedBackgroundStyle),
              ),
            ),
            if (author != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '— $author',
                  style: TextStyle(
                    fontSize: settings.fontSize * 0.8,
                    fontFamily: _getFontFamily(settings.selectedFontFamily),
                    color: _getTextColor(settings.selectedBackgroundStyle),
                  ),
                ),
              ),
          ],
        ));
  }
}

// Получение цвета текста на основе выбранного стиля
Color _getTextColor(int selectedBackgroundStyle) {
  switch (selectedBackgroundStyle) {
    case 0:
      return AppColors.textPrimary; // Черный текст
    case 1:
      return AppColors.textPrimary; // Черный текст
    case 2:
      return Colors.white; // Белый текст
    case 3:
      return Colors.white; // Белый текст
    default:
      return AppColors.textPrimary;
  }
}

// Получение шрифта на основе выбранного стиля
String _getFontFamily(int selectedFontFamily) {
  switch (selectedFontFamily) {
    case 0:
      return 'MPLUSRounded1c';
    case 1:
      return 'Rubik';
    case 2:
      return 'Inter';
    case 3:
      return 'AdventPro';
    default:
      return 'MPLUSRounded1c';
  }
}
