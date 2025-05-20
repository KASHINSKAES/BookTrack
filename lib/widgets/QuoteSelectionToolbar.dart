import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class QuoteSelectionDialog extends StatelessWidget {
  final TextSelectionDelegate delegate;
  final Function(String) onSaveQuote;

  const QuoteSelectionDialog({
    required this.delegate,
    required this.onSaveQuote,
  });

  @override
  Widget build(BuildContext context) {
    final selection = delegate.textEditingValue.selection;
    final text = delegate.textEditingValue.text;

    // Дополнительная проверка на случай, если диалог все же открылся с невалидным выделением
    if (!selection.isValid || selection.isCollapsed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return const SizedBox.shrink();
    }

    final start = selection.start.clamp(0, text.length);
    final end = selection.end.clamp(0, text.length);
    final selectedText = text.substring(start, end);

    return AlertDialog(
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Новая цитата',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"${selectedText.length > 50 ? '${selectedText.substring(0, 50)}...' : selectedText}"',
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                icon: Icons.content_copy,
                label: 'Скопировать',
                onPressed: () {
                  delegate.copySelection(SelectionChangedCause.toolbar);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Текст скопирован')),
                  );
                },
              ),
              _buildActionButton(
                context,
                icon: Icons.format_quote,
                label: 'Добавить',
                onPressed: () {
                  onSaveQuote(selectedText);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Цитата сохранена')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Отмена"),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
