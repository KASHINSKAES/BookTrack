import 'package:booktrack/MyFlutterIcons.dart';
import 'package:booktrack/icons.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';



final String selectedPaymentMethod = "card_1";

class loveQuotes extends StatelessWidget {
  final VoidCallback onBack;
  loveQuotes({super.key, required this.onBack});

  Future<List<Map<String, dynamic>>> fetchLoveQuoteReviews(
      BuildContext context) async {
    final List<Map<String, dynamic>> result = [];

    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final userModel = authProvider.userModel;

    // 1. Получаем все отзывы пользователя (например, из подколлекции `users/{uid}/reviews`)
    final QuerySnapshot quoteSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel?.uid) // Замените на реальный ID пользователя
        .collection('quotes')
        .get();

    // 2. Для каждого отзыва получаем product_id и ищем продукт
    for (final quoteDoc in quoteSnapshot.docs) {
      final String bookId =
          quoteDoc['bookId']; // Предполагаем, что в отзыве есть product_id
      final String quoteText = quoteDoc['quoteText']; // Текст отзыва

      // 3. Получаем продукт по его ID
      final DocumentSnapshot bookSnapshot = await FirebaseFirestore.instance
          .collection('books')
          .doc(bookId)
          .get();

      if (bookSnapshot.exists) {
        final String productUrl = bookSnapshot['url']; // URL продукта

        // 4. Добавляем в результат
        result.add({
          'bookUrl': productUrl,
          'quote': quoteText,
        });
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchLoveQuoteReviews(context),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint(snapshot.error.toString());
            return Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Любимые цитаты',
                    style: TextStyle(
                      fontSize: 32 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppColors.background,
                  leading: IconButton(
                    icon: Icon(
                      size: 35 * scale,
                      MyFlutterApp.back,
                      color: Colors.white,
                    ),
                    onPressed: onBack,
                  ),
                ),
                backgroundColor: AppColors.background,
                body: Center(child: Text('Ошибка загрузки данных')));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Любимые цитаты',
                    style: TextStyle(
                      fontSize: 32 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: AppColors.background,
                  leading: IconButton(
                    icon: Icon(
                      size: 35 * scale,
                      MyFlutterApp.back,
                      color: Colors.white,
                    ),
                    onPressed: onBack,
                  ),
                ),
                backgroundColor: AppColors.background,
                body: Center(child: Text('Нет цитат')));
          }
          final data = snapshot.data ?? [];
          debugPrint(data.toString());
          return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Любимые цитаты',
                  style: TextStyle(
                    fontSize: 32 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: AppColors.background,
                leading: IconButton(
                  icon: Icon(
                    size: 35 * scale,
                    MyFlutterApp.back,
                    color: Colors.white,
                  ),
                  onPressed: onBack,
                ),
              ),
              backgroundColor: AppColors.background,
              body: Container(
                  padding: EdgeInsets.symmetric(vertical: 10 * scale),
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: const Color(0xffF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft:
                          Radius.circular(AppDimensions.baseCircual * scale),
                      topRight:
                          Radius.circular(AppDimensions.baseCircual * scale),
                    ),
                  ),
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      vertical: 19 * scale,
                    ),
                    children: [
                      ...data.map((quote) => Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 20 * scale, horizontal: 10 * scale),
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 19 * scale, vertical: 20 * scale),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 4,
                                    offset: Offset(4, 8), // Shadow position
                                  ),
                                ],
                                borderRadius: BorderRadius.all(Radius.circular(
                                    AppDimensions.baseCircual * scale)),
                              ),
                              child: ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: 800),
                                  child: Row(
                                    children: [
                                      quote['bookUrl'].toString().isEmpty
                                          ? Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xffFD521B),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: SvgPicture.asset(
                                                'assets/${quote['bookUrl']}',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                      SizedBox(
                                        width: 17 * scale,
                                      ),
                                      Expanded(
                                          child: Text(
                                        quote['quote'],
                                        style: TextStyle(
                                          fontSize: 15 * scale,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        softWrap:
                                            true, // ✅ Включает перенос строк
                                        maxLines:
                                            null, // ✅ Позволяет неограниченное количество строк
                                        overflow: TextOverflow.visible,
                                      ))
                                    ],
                                  )))))
                    ],
                  )));
        });
  }
}
