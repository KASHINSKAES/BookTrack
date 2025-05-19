import 'package:flutter/material.dart';

class QuoteSelectionToolbar extends StatelessWidget {
  final TextSelectionDelegate delegate;
  final Function(String) onSaveQuote;

  const QuoteSelectionToolbar({
    required this.delegate,
    required this.onSaveQuote,
  });

  @override
  Widget build(BuildContext context) {
    final selection = delegate.textEditingValue.selection;
    final selectedText = delegate.textEditingValue.text.substring(
      selection.start,
      selection.end,
    );

    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 4.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.content_copy, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              delegate.copySelection(SelectionChangedCause.toolbar);
              delegate.hideToolbar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Текст скопирован')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.format_quote, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              onSaveQuote(selectedText);
              delegate.hideToolbar();
            },
          ),
        ],
      ),
    );
  }
}