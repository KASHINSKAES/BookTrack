import 'package:booktrack/icons.dart';
import 'package:booktrack/pages/ReadingStatsProvider.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';


Future<String> fetchText() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('books')
      .doc('book_1')
      .collection('chapters')
      .get();

  String text = '';

  for (var doc in snapshot.docs) {
    final data = doc.data();
    text += data['text']; // Предположим, что поле с текстом называется 'text'
  }

  return text;
}


class textBook extends StatefulWidget {
  final VoidCallback onBack;
  textBook({super.key, required this.onBack});

  @override
  State<textBook> createState() => _textBook();
}

class _textBook extends State<textBook> {
  String textBook='';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }


  Future<void> _loadData() async {
  final data = await fetchText(); // Добавьте скобки
  setState(() {
    textBook = data;
    isLoading = false;
  });
}

  

  

 @override
Widget build(BuildContext context) {
  final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: Icon(
          size: 35 * scale,
          MyFlutterApp.back,
          color: Colors.white,
        ),
        onPressed: widget.onBack,
      ),
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(textBook),
            ),
          ),
  );
}
}