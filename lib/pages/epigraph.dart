import 'package:flutter/material.dart';

class EpigraphWidget extends StatelessWidget {
  final String text;
  final String? author;

  const EpigraphWidget({required this.text, this.author, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey.shade400, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(text, style: const TextStyle(fontStyle: FontStyle.italic)),
          if (author != null) 
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('— $author'),
            ),
        ],
      ),
    );
  }
}