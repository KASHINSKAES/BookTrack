import 'package:flutter/material.dart';
import '/widgets/BookListPage.dart';
import '/icons.dart';
import '/widgets/constants.dart';

class selectedPage extends StatelessWidget {
  const selectedPage({super.key});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Scaffold(
        backgroundColor: const Color(0xff5775CD),
        body: ListView(padding: const EdgeInsets.only(top: 23.0), children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Мои книги",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: AppDimensions.baseTextSizeh1 * scale),
              )),
          Container(
              width: screenWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.baseCircual * scale),
                  topRight: Radius.circular(AppDimensions.baseCircual * scale),
                ),
              ),
              child: Column())
        ]));
  }
}
