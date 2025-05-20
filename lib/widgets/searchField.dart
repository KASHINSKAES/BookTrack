import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final VoidCallback onTap;

  const SearchField({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(35.0),
      child: Container(
        width: 329 * scale,
        height: 44 * scale,
        decoration: BoxDecoration(
          color: const Color(0xff3A4E88).withOpacity(0.5),
          borderRadius: BorderRadius.circular(35.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Opacity(
                opacity: 0.6,
                child: Icon(
                  BookTrackIcon.research,
                  size: 21.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Что вы хотите почитать?',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
