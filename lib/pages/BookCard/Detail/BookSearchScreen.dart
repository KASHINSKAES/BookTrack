import 'dart:async';

import 'package:booktrack/models/book.dart';
import 'package:booktrack/pages/BookCard/Detail/BookDetailScreen.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookSearchScreen extends StatefulWidget {
  @override
  _BookSearchScreenState createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<QueryDocumentSnapshot> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(20)
          .get();

      setState(() {
        _searchResults = snapshot.docs;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка поиска: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              if (_searchController.text.isEmpty) {
                Navigator.pop(context);
              } else {
                _searchController.clear();
              }
            },
          ),
        ],
      ),
      body: _buildSearchResults(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocusNode,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Что вы хотите почитать?',
        hintStyle: TextStyle(
          fontSize: 14.0,
          color: AppColors.textPrimary.withOpacity(0.5),
        ),
        border: InputBorder.none,
      ),
      style: TextStyle(
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.isEmpty) {
      return Center(
        child: Text(
          'Введите название книги для поиска',
          style: TextStyle(
            color: AppColors.textPrimary,
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'Ничего не найдено',
          style: TextStyle(
            color: AppColors.textPrimary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8.0),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final book = _searchResults[index].data() as Map<String, dynamic>;
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            title: Text(
              book['title'] ?? 'Без названия',
              style: TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(book['author'] ?? 'Автор неизвестен',
                style: TextStyle(
                  color: AppColors.textPrimary,
                )),
            onTap: () {
              final bookData = _searchResults[index];
              _navigateToDetail(context, bookData);
            },
          ),
        );
      },
    );
  }

  void _navigateToDetail(BuildContext context, DocumentSnapshot doc) {
    final book = Book.fromFirestore(doc);
    // Получаем количество отзывов (аналогично вашему коду)
    final reviewCountFuture = FirebaseFirestore.instance
        .collection('reviews')
        .where('bookId', isEqualTo: doc.id)
        .get()
        .then((snapshot) => snapshot.size);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FutureBuilder<int>(
          future: reviewCountFuture,
          builder: (context, snapshot) {
            return BookDetailScreen(
              bookId: book.id,
              bookTitle: book.title,
              authorName: book.author,
              bookImageUrl: book.imageUrl,
              bookRating: book.rating,
              reviewCount: snapshot.data ?? 0,
              pages: book.pages,
              age: book.ageRestriction,
              description: book.description,
              publisher: book.publisher,
              yearPublisher: book.yearPublisher,
              language: book.language,
              price: book.price,
              format: book.format,
              tags: book.tags,
              onBack: () {
                              Navigator.pop(context);
                            },
            );
          },
        ),
      ),
    );
  }
}
