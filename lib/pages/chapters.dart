import 'package:booktrack/models/chaptersModel.dart';
import 'package:flutter/material.dart';

class ChapterPage extends StatefulWidget {
  final Chapter chapter;
  final int currentChapterIndex;
  final List<String> pages;
  final double fontSize;
  final String fontFamily;

  const ChapterPage({
    required this.chapter,
    required this.currentChapterIndex,
    required this.pages,
    required this.fontSize,
    required this.fontFamily,
    Key? key,
  }) : super(key: key);

  @override
  _ChapterPageState createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.chapter.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: PageView.builder(
            itemCount: widget.pages.length,
            onPageChanged: (index) {
              setState(() => _currentPageIndex = index);
            },
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.pages[index],
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontFamily: widget.fontFamily,
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Страница ${_currentPageIndex + 1} из ${widget.pages.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
