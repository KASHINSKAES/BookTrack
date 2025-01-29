import 'package:booktrack/icons.dart';
import 'package:booktrack/pages/selectedPage.dart';
import 'package:booktrack/widgets/blobPath.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

final List<String> reviews = [
  "Недавно прочитала книгу «Аня с острова Принца Эдуарда» и осталась в восторге! "
      "Это история о сильной и независимой девушке, которая преодолевает множество трудностей "
      "и находит своё счастье.",
  "Очень захватывающая книга! Интересный сюжет, великолепная проработка персонажей.",
  "Эта книга вдохновила меня на новые свершения. Определённо рекомендую к прочтению!"
];

class BookDetailScreen extends StatefulWidget {
  final String bookTitle;
  final String authorName;
  final double bookRating;
  final String bookImageUrl;
  final int reviewCount;
  final int pages;
  final int age;

  const BookDetailScreen({
    required this.bookTitle,
    required this.authorName,
    required this.bookRating,
    required this.bookImageUrl,
    required this.reviewCount,
    required this.pages,
    required this.age,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  double _scrollPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    return NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification) {
            setState(() {
              _scrollPosition = scrollNotification.metrics.pixels;
            });
          }
          return true;
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            backgroundColor: _scrollPosition > 300 * scale
                ? AppColors.background
                : Colors.transparent,
            title: _scrollPosition > 300 * scale
                ? Text(
                    widget.bookTitle,
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
          ),
          body: Stack(
            children: [
              // Фиолетовый фон
              Container(
                padding: EdgeInsets.only(top: 200 * scale),
                color: AppColors.background,
              ),
              Positioned(
                  top: 0,
                  left: -40 * scale,
                  child: BlobShape(
                    width: 200 * scale, // Размеры пятна
                    height: 200 * scale,
                    blobType: 'blob2',
                  )),
              Positioned(
                  top: 10 * scale,
                  left: 140 * scale,
                  child: BlobShape(
                    width: 200 * scale, // Размеры пятна
                    height: 200 * scale,
                    blobType: 'blob3',
                  )),
              // Прокручиваемый контент
              SingleChildScrollView(
                padding: EdgeInsets.only(top: 250 * scale),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Белый блок
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height: 30 * scale), // Отступ для картинки
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(MyFlutterApp.star,
                                              size: 16 * scale,
                                              color: AppColors.orange),
                                          Text(
                                            '${widget.bookRating}',
                                            style: TextStyle(
                                                fontSize: 16 * scale,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.orange),
                                          ),
                                          SizedBox(width: 6 * scale),
                                          Icon(MyFlutterApp.chat,
                                              size: 16 * scale,
                                              color: AppColors.grey),
                                          SizedBox(width: 4 * scale),
                                          Text(
                                            '${widget.reviewCount}',
                                            style: TextStyle(
                                                fontSize: 12 * scale,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.grey),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5 * scale),
                                      Text(widget.bookTitle,
                                          style: TextStyle(
                                            fontSize: 20 * scale,
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          softWrap: true),
                                      Text(
                                        widget.authorName,
                                        style: TextStyle(
                                          fontSize: 14 * scale,
                                          color: AppColors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${widget.pages} стр | ${widget.age}+ ',
                                        style: TextStyle(
                                          fontSize: 12 * scale,
                                          color: AppColors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ]),
                                Text(
                                  'Описание',
                                  style: TextStyle(
                                    fontSize: 16 * scale,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Третья книга из цикла про Аню Ширли.Аня проработал 2 года учительницей в местной школе, но теперь она нацелена поступить в Редмондский университет Кингспорта. Её друзья детства практически все устроили свою жизнь, кто-то уехал, многие вступили в семейную жизнь. ',
                                  style: TextStyle(
                                    fontSize: 14 * scale,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Chip(
                                          label: Text('Зарубежная классика'),
                                          backgroundColor: AppColors.background,
                                          labelStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11 * scale,
                                          ),
                                        ),
                                        Chip(
                                          label: Text('Яркая классика'),
                                          backgroundColor: AppColors.background,
                                          labelStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11 * scale,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Характеристика',
                                          style: TextStyle(
                                            fontSize: 14 * scale,
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Издательство:Эксмо',
                                          style: TextStyle(
                                            fontSize: 14 * scale,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                            'Серия:Яркие страницы.Коллекционные издания',
                                            style: TextStyle(
                                              fontSize: 14 * scale,
                                              color: AppColors.textPrimary,
                                            ),
                                            softWrap: true),
                                        Text(
                                          'Год издания:2024',
                                          style: TextStyle(
                                            fontSize: 14 * scale,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                SectionTitle(
                                  title: "Другие книги автора ",
                                  onSeeAll: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AllBooksPage()),
                                    );
                                  },
                                ),
                                BookList(),
                                SectionTitle(
                                  title: "Похожие книги",
                                  onSeeAll: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AllBooksPage()),
                                    );
                                  },
                                ),
                                BookList(),

                                const Text(
                                  'Отзывы',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      160 * scale, // Фиксируем высоту списка
                                  child: ListView.builder(
                                    scrollDirection: Axis
                                        .horizontal, // Горизонтальный скролл
                                    itemCount: reviews.length,
                                    itemBuilder: (context, index) {
                                      return ReviewCard(
                                          text: reviews[index], scale: scale);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Картинка книги между белым и фиолетовым слоями
                        Positioned(
                          top: -180 * scale,
                          left: 0,
                          right: 0,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 130 * scale,
                              height: 220 * scale,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: widget.bookImageUrl.isEmpty
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xffFD521B),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SvgPicture.asset(
                                          widget.bookImageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 680 * scale, // Позиция сверху, чтобы "висел"
                left: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.background),
                          onPressed: () {},
                          child: Row(
                            children: [
                              Icon(
                                MyFlutterApp.school,
                                color: Colors.white,
                              ),
                              SizedBox(
                                  width: 7), // Отступы между иконками и текстом
                              Column(
                                children: [
                                  Text(
                                    'Полностью ',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(' за 299 ₽',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(.6),
                                      )),
                                ],
                              )
                            ],
                          )),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.background),
                          onPressed: () {},
                          child: Row(
                            children: [
                              Icon(
                                MyFlutterApp.notes,
                                color: Colors.white,
                              ),
                              SizedBox(
                                  width: 7), // Отступы между иконками и текстом
                              Column(
                                children: [
                                  Text(
                                    'Отрывок ',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(' бесплатно',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(.6),
                                      )),
                                ],
                              )
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildReviewsList() {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    return Container(
      width: 380 * scale, // Фиксированная ширина карточки
      margin: EdgeInsets.only(left: 16 * scale, right: 8 * scale),
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.blue.shade100, // Фон комментария
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Аватар и имя
          Row(
            children: [
              CircleAvatar(
                radius: 20 * scale,
                backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/women/44.jpg'),
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Алиса",
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "13 марта 2022",
                      style:
                          TextStyle(fontSize: 12 * scale, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),

          // Оценка
          Row(
            children: List.generate(
              5,
              (index) =>
                  Icon(Icons.star, size: 16 * scale, color: Colors.orange),
            ),
          ),
          SizedBox(height: 8 * scale),

          // Контейнер с текстом и затемнением
          Stack(
            children: [
              SizedBox(
                height: 160 * scale, // Ограничиваем высоту текста
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(), // Отключаем скролл
                  child: Text(
                    "Недавно прочитала книгу «Аня с острова Принца Эдуарда» и осталась в восторге! "
                    "Это история о сильной и независимой девушке, которая преодолевает множество трудностей "
                    "и находит своё счастье.",
                    style: TextStyle(fontSize: 14 * scale, color: Colors.black),
                    softWrap: true,
                  ),
                ),
              ),

              // Затемнение
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 20 * scale,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blue.shade100.withOpacity(0.0),
                        Colors.blue.shade100,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String text;
  final double scale;

  ReviewCard({required this.text, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350 * scale,
      height: 350 * scale, // Фиксированная ширина карточки
      margin: EdgeInsets.only(left: 16 * scale, right: 8 * scale),
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.blue.shade100, // Фон комментария
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Аватар и имя
          Row(
            children: [
              CircleAvatar(
                radius: 20 * scale,
                backgroundImage: NetworkImage(
                    'https://randomuser.me/api/portraits/women/44.jpg'),
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Алиса",
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "13 марта 2022",
                      style:
                          TextStyle(fontSize: 12 * scale, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),

          // Оценка
          Row(
            children: List.generate(
              5,
              (index) =>
                  Icon(Icons.star, size: 16 * scale, color: Colors.orange),
            ),
          ),
          SizedBox(height: 8 * scale),

          // Контейнер с текстом и затемнением
          Stack(
            children: [
              SizedBox(
                height: 160 * scale, // Ограничиваем высоту текста
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(), // Отключаем скролл
                  child: Text(
                    text,
                    style: TextStyle(fontSize: 14 * scale, color: Colors.black),
                    softWrap: true, // ✅ Включает перенос строк
                    maxLines:
                        null, // ✅ Позволяет неограниченное количество строк
                    overflow:
                        TextOverflow.visible, // ✅ Отключает обрезку текста,
                  ),
                ),
              ),

              // Затемнение
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 20 * scale,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blue.shade100.withOpacity(0.0),
                        Colors.blue.shade100,
                      ],
                    ),
                  ),
                ),
              ),

              // Кнопка "Далее"
              Positioned(
                bottom: 0,
                right: 0,
                child: TextButton(
                  onPressed: () {
                    // Открытие полного текста
                  },
                  child: Text(
                    "Далее",
                    style: TextStyle(
                      fontSize: 14 * scale,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
