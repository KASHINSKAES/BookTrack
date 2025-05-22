
import 'package:booktrack/pages/BookCard/Detail/BookSearchScreen.dart';
import 'package:booktrack/pages/PagesMainBottom/catalog/BookListPage.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:booktrack/widgets/searchField.dart';
import 'package:flutter/material.dart';

// CatalogPage с обработчиком нажатий на категории
class CatalogPage extends StatelessWidget {
  final Function(String) onCategoryTap;

  const CatalogPage({super.key, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xff5775CD),
      
      body: ListView(
        padding: const EdgeInsets.only(top: 23.0),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SearchField(onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookSearchScreen()),
              );
            }),
          ),
          Container(
            width: screenWidth,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: const [
                BookCategory(title: 'Художественная литература'),
                BookCategory(title: 'Учебная литература'),
                BookCategory(title: 'Саморазвитие'),
                BookCategory(title: 'Психология'),
                BookCategory(title: 'Детская литература'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookCategory extends StatelessWidget {
  final String title;

  const BookCategory({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 30, left: 26),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Transform.scale(
                    scaleX: -1,
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ))
              ],
            )),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookListPage(
                        category: title,
                        onBack: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
                child: const BookCard(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class BookCard extends StatelessWidget {
  const BookCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(top: 15, left: 26),
      decoration: BoxDecoration(
        color: const Color(0xffB8BEF6),
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}
