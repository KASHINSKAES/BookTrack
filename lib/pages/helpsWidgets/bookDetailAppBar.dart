import 'package:booktrack/FavoriteIcon.dart';
import 'package:booktrack/servises/bookServises.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class BookDetailsAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String bookId;
  final String bookTitle;
  final String userId;
  final double scrollPosition;
  
  const BookDetailsAppBar({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.userId,
    required this.scrollPosition,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<BookDetailsAppBar> createState() => _BookDetailsAppBarState();
}

class _BookDetailsAppBarState extends State<BookDetailsAppBar> {
  final BookService _bookService = BookService();
  late Stream<bool> _isSavedStream;

  @override
  void initState() {
    super.initState();
    _isSavedStream = _bookService.isBookSaved(widget.userId, widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      backgroundColor: widget.scrollPosition > 300 ? AppColors.background : Colors.transparent,
      title: widget.scrollPosition > 300 
          ? Text(widget.bookTitle, style: const TextStyle(color: Colors.white))
          : null,
      actions: [
        StreamBuilder<bool>(
          stream: _isSavedStream,
          builder: (context, snapshot) {
            final isSaved = snapshot.data ?? false;
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: FavoriteIcon(
                isSaved: isSaved,
                onPressed: () => _bookService.toggleSavedStatus(
                  widget.userId,
                  widget.bookId,
                  isSaved,
                ),
                size: 20,
              ),
            );
          },
        ),
      ],
    );
  }
}