import 'package:booktrack/pages/bookReposityr.dart';

class _ProcessingParams {
  final BookWithChapters book;
  final double fontSize;
  final String fontFamily;

  _ProcessingParams({
    required this.book,
    required this.fontSize,
    required this.fontFamily,
  });
}

List<List<String>> _processBookChapters(_ProcessingParams params) {
  return params.book.chapters.map((chapter) {
    final fullText = chapter.epigraph != null
        ? '${chapter.epigraph!.text}\n\n— ${chapter.epigraph!.author}\n\n${chapter.text}'
        : chapter.text;
    return _splitTextIntoPages(
      fullText,
      params.fontSize,
      params.fontFamily,
    );
  }).toList();
}

List<String> _splitTextIntoPages(
  String text,
  double fontSize,
  String fontFamily,
) {
  // Упрощенная версия разбиения на страницы
  const charsPerPage = 2000; // Эмпирическое значение, можно настроить
  final pages = <String>[];
  var start = 0;

  while (start < text.length) {
    var end = (start + charsPerPage).clamp(start, text.length);
    if (end < text.length) {
      // Ищем ближайший пробел или перенос строки
      while (end > start && text[end] != ' ' && text[end] != '\n') {
        end--;
      }
    }
    pages.add(text.substring(start, end).trim());
    start = end;
  }

  return pages;
}