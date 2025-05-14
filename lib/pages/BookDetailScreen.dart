import 'dart:math';

import 'package:booktrack/icons.dart';
import 'package:booktrack/pages/LoginPAGES/RegistrPage.dart';
import 'package:booktrack/pages/PurchaseSuccessScreen.dart';
import 'package:booktrack/pages/purchaseButton.dart';
import 'package:booktrack/pages/selectedPage.dart';
import 'package:booktrack/pages/textBook.dart';
import 'package:booktrack/widgets/blobPath.dart';
import 'package:booktrack/widgets/bookListGoris.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final String bookId;
  final String bookTitle;
  final String authorName;
  final double bookRating;
  final String bookImageUrl;
  final int reviewCount;
  final int pages;
  final String age;
  final String description;
  final String publisher;
  final int yearPublisher;
  final String language;
  final int price;

  const BookDetailScreen({
    required this.bookId,
    required this.bookTitle,
    required this.authorName,
    required this.bookRating,
    required this.bookImageUrl,
    required this.reviewCount,
    required this.pages,
    required this.age,
    required this.description,
    required this.publisher,
    required this.yearPublisher,
    required this.language,
    required this.price,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  double _scrollPosition = 0.0;
  bool _isBookInCollection = false;
  bool _isLoading = true;
  bool _useBonuses = false; // Добавляем состояние для использования бонусов
  int _availableBonuses = 0; // Доступные бонусы
  @override
  void initState() {
    super.initState();
    _checkIfBookInCollection();
    _loadUserBonuses();
  }

  Future<void> _loadUserBonuses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _availableBonuses = getSafeInt(userDoc.data()?['totalBonuses']);
        });
      }
    } catch (e) {
      debugPrint('Ошибка при загрузке бонусов: $e');
    }
  }

  Future<void> _checkIfBookInCollection() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _isBookInCollection = false;
      });
      return;
    }

    try {
      const bookId = 'book_2'; // Замените на реальный ID книги
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final savedBooks =
            List<String>.from(userDoc.data()?['saved_books'] ?? []);
        setState(() {
          _isBookInCollection = savedBooks.contains(bookId);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isBookInCollection = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isBookInCollection = false;
        _isLoading = false;
      });
      debugPrint('Ошибка при проверке коллекции: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
          backgroundColor:
              _scrollPosition > 300 ? AppColors.background : Colors.transparent,
          title: _scrollPosition > 300
              ? Text(
                  widget.bookTitle,
                  style: const TextStyle(color: Colors.white),
                )
              : null,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / AppDimensions.baseWidth;
            return Stack(
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
                    width: 200 * scale,
                    height: 200 * scale,
                    blobType: 'blob2',
                  ),
                ),
                Positioned(
                  top: 10 * scale,
                  left: 140 * scale,
                  child: BlobShape(
                    width: 200 * scale,
                    height: 200 * scale,
                    blobType: 'blob3',
                  ),
                ),
                // Прокручиваемый контент
                SingleChildScrollView(
                  padding: EdgeInsets.only(top: 250 * scale),
                  child: Column(
                    children: [
                      _buildBookContent(scale),
                    ],
                  ),
                ),
                // Кнопки внизу экрана
                Positioned(
                  bottom: 16 * scale,
                  left: 16 * scale,
                  right: 16 * scale,
                  child: _buildBottomButtons(scale),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookContent(double scale) {
    return Stack(
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
            padding: const EdgeInsets.only(
                top: 16.0, left: 16.0, right: 16.0, bottom: 150.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30 * scale),
                _buildBookInfo(scale),
                _buildBookDescription(scale),
                _buildBookTags(scale),
                _buildSBooksSection(scale),
                _buildReviewsSection(scale),
              ],
            ),
          ),
        ),
        // Картинка книги
        Positioned(
          top: -180 * scale,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: _buildBookImage(scale),
          ),
        ),
      ],
    );
  }

  Widget _buildBookInfo(double scale) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(MyFlutterApp.star, size: 16 * scale, color: AppColors.orange),
            Text(
              '${widget.bookRating}',
              style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                  color: AppColors.orange),
            ),
            SizedBox(width: 6 * scale),
            Icon(MyFlutterApp.chat, size: 16 * scale, color: AppColors.grey),
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
          '${widget.pages} стр | ${widget.age} ',
          style: TextStyle(
            fontSize: 12 * scale,
            color: AppColors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBookDescription(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Описание',
          style: TextStyle(
            fontSize: 16 * scale,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          widget.description,
          style: TextStyle(
            fontSize: 14 * scale,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBookTags(double scale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Характеристики',
                style: TextStyle(
                  fontSize: 14 * scale,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Издательство: ${widget.publisher}',
                style: TextStyle(
                  fontSize: 14 * scale,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Язык: ${widget.language}',
                style: TextStyle(
                  fontSize: 14 * scale,
                  color: AppColors.textPrimary,
                ),
                softWrap: true,
              ),
              Text(
                'Год издания:${widget.yearPublisher}',
                style: TextStyle(
                  fontSize: 14 * scale,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSBooksSection(double scale) {
    return Column(
      children: [
        SectionTitle(
          title: "Другие книги автора ",
          onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllBooksPage()),
            );
          },
        ),
        BookList(),
        SectionTitle(
          title: "Похожие книги",
          onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllBooksPage()),
            );
          },
        ),
        BookList(),
      ],
    );
  }

  Widget _buildReviewsSection(double scale) {
    return Column(
      children: [
        Row(
          children: [
            Row(
              children: List.generate(
                5,
                (index) => Icon(MyFlutterApp.star,
                    size: 24 * scale, color: AppColors.orange),
              ),
            ),
            Text(
              widget.bookRating.toString(),
              style: TextStyle(
                fontSize: 18 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.orange,
              ),
            )
          ],
        ),
        SizedBox(
          height: 250 * scale,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return _buildReviewCard(reviews[index], scale);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(String text, double scale) {
    const maxChars = 150;
    final isLongText = text.length > maxChars;
    final displayText = isLongText ? text.substring(0, maxChars) : text;

    return Container(
      width: 350 * scale,
      margin: EdgeInsets.only(left: 16 * scale, right: 8 * scale),
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.blueColorLight,
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
          // Верхняя часть с аватаркой и рейтингом (оставляем без изменений)
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
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      "13 марта 2022",
                      style: TextStyle(
                          fontSize: 13 * scale, color: Color(0xff575656)),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(MyFlutterApp.star,
                      size: 18 * scale, color: AppColors.orange),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),

          // Текст отзыва с возможностью раскрытия
          StatefulBuilder(
            builder: (context, setState) {
              bool isExpanded = false;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Text(
                        isExpanded ? text : displayText,
                        style: TextStyle(
                            fontSize: 14 * scale, color: AppColors.textPrimary),
                      ),
                      if (isLongText && !isExpanded) ...[
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 40 * scale,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  AppColors.blueColorLight.withOpacity(0.9),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isLongText)
                    TextButton(
                      onPressed: () {
                        setState(() => isExpanded = !isExpanded);
                      },
                      child: Text(
                        isExpanded ? "Свернуть" : "Далее",
                        style: TextStyle(
                          fontSize: 14 * scale,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookImage(double scale) {
    return Container(
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
                  borderRadius: BorderRadius.circular(8.0),
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
    );
  }

  Widget _buildBottomButtons(double scale) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Material(
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 12 * scale,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _isBookInCollection
            ? _buildReadButton(scale)
            : _buildPurchaseButtons(scale),
      ),
    );
  }

  Widget _buildReadButton(double scale) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: Size(double.infinity, 50 * scale),
      ),
      onPressed: () {
        // Навигация на страницу чтения книги
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookScreen(
                bookId: widget.bookId,
                onBack: () {
                  Navigator.pop(context);
                }),
          ),
        );
      },
      child: Text(
        'Читать книгу',
        style: TextStyle(
          fontSize: 16 * scale,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPurchaseButtons(double scale) {
    return Column(
      children: [
        // Панель выбора использования бонусов
        if (_availableBonuses > 0) _buildBonusToggle(scale),
        SizedBox(height: 8 * scale),
        Row(
          children: [
            Expanded(
              child: PurchaseButton(
                icon: MyFlutterApp.school,
                title: 'Полностью',
                subtitle: _buildPriceWithBonuses(scale),
                onPressed: _handlePurchase,
                scale: scale,
              ),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: PurchaseButton(
                icon: MyFlutterApp.notes,
                title: 'Отрывок',
                subtitle: 'бесплатно',
                onPressed: () {},
                scale: scale,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBonusToggle(double scale) {
    var bookPrice = widget.price;
    final maxBonusUse = (bookPrice * 0.3).round();
    final canUseFullBonus = _availableBonuses >= maxBonusUse;

    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: AppColors.blueColorLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Переключатель
          Switch(
            value: _useBonuses,
            onChanged: (value) {
              setState(() => _useBonuses = value && _availableBonuses > 0);
            },
            activeColor: AppColors.orange,
          ),

          // Информация о бонусах
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Использовать бонусы',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  canUseFullBonus
                      ? 'Спишется ${min(_availableBonuses, maxBonusUse)}  (макс. 30%)'
                      : 'Доступно ${_availableBonuses}',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Иконка информации
          IconButton(
            icon: Icon(Icons.info_outline, size: 20 * scale),
            onPressed: _showBonusInfoDialog,
          ),
        ],
      ),
    );
  }

  String _buildPriceWithBonuses(double scale) {
    var bookPrice = widget.price;
    if (!_useBonuses || _availableBonuses <= 0) return 'за $bookPrice ₽';

    final maxBonusUse = (bookPrice * 0.3).round();
    final bonusesToUse = min(_availableBonuses, maxBonusUse);
    final finalPrice = bookPrice - bonusesToUse;

    return '${bookPrice} ₽ → ${finalPrice} ₽';
  }

  void _showBonusInfoDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Как использовать бонусы?'),
        content: Text(
          'Вы можете списать до 30% от стоимости книги. '
          'При использовании бонусов новые бонусы за покупку не начисляются.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Понятно'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase({bool useBonuses = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showAuthErrorDialog(context);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    try {
      var bookId = widget.bookId;
      var bookPrice = widget.price;

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        await userRef.set({
          'saved_books': [],
          'totalBonuses': 0,
          'payments': {},
          'selectedPaymentMethod': 'card_1',
          'lastPurchaseDate': FieldValue.serverTimestamp(),
        });
      }

      final userData = userDoc.data() ??
          {
            'saved_books': [],
            'totalBonuses': 0,
            'payments': {},
            'selectedPaymentMethod': 'card_1',
          };

      final savedBooks = List<String>.from(userData['saved_books'] ?? []);
      final currentBonuses = getSafeInt(userData['totalBonuses']);
      final paymentMethods = userData['payments'] is Map
          ? userData['payments'] as Map<String, dynamic>? ?? {}
          : {};
      final selectedMethod =
          userData['selectedPaymentMethod'] as String? ?? 'card_1';

      if (savedBooks.contains(bookId)) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Эта книга уже у вас в коллекции')),
        );
        return;
      }

      // Расчет бонусов
      final maxBonusUse = (bookPrice * 0.3).round();
      final bonusesAvailable = min(currentBonuses, maxBonusUse);
      final willUseBonuses = useBonuses && bonusesAvailable > 0;

      final bonusesToUse = willUseBonuses ? bonusesAvailable : 0;
      final bonusesToAdd = (bookPrice * 0.15).round();
      final finalPrice = bookPrice - bonusesToUse;

      // Проверка на отрицательные бонусы
      if (currentBonuses - bonusesToUse < 0) {
        throw Exception('Недостаточно бонусов для списания');
      }

      // Получаем данные о карте
      final cardData =
          paymentMethods[selectedMethod] as Map<String, dynamic>? ??
              {
                'cardNumber': '**** **** **** ****',
                'brand': 'Unknown',
              };
      final cardNumber =
          cardData['cardNumber'] as String? ?? '**** **** **** ****';
      final cardLast4 = cardNumber.length > 4
          ? cardNumber.substring(cardNumber.length - 4)
          : '****';

      // Создаем запись о покупке
      final purchaseData = {
        'amount': finalPrice,
        'date': FieldValue.serverTimestamp(),
        'paymentMethod': selectedMethod,
        'paymentDetails': {
          'cardLast4': cardLast4,
          'cardBrand': cardData['brand'] as String? ?? 'Unknown',
        },
        'reason': 'Покупка книги',
        'bookId': bookId,
        'bonusesUsed': bonusesToUse,
        'bonusesAdded': bonusesToAdd,
        'status': 'completed',
        'originalPrice': bookPrice,
      };

      // Обновляем данные пользователя
      final updateData = {
        'saved_books': FieldValue.arrayUnion([bookId]),
        'totalBonuses': FieldValue.increment(bonusesToAdd - bonusesToUse),
        'lastPurchaseDate': FieldValue.serverTimestamp(),
      };
      await userRef.update(updateData);

      // Добавляем запись в историю покупок
      final purchaseDocRef =
          await userRef.collection('purchase_history').add(purchaseData);

      // Добавляем записи в историю бонусов
      if (bonusesToUse > 0) {
        await userRef.collection('bonus_history').add({
          'amount': bonusesToUse.toString(),
          'date': FieldValue.serverTimestamp(),
          'isPositive': false,
          'title': 'Списание бонусов',
          'bookId': bookId,
          'relatedPurchaseId': purchaseDocRef.id,
        });
      }

      if (bonusesToAdd > 0) {
        await userRef.collection('bonus_history').add({
          'amount': bonusesToAdd.toString(),
          'date': FieldValue.serverTimestamp(),
          'isPositive': true,
          'title': 'Покупка книги',
          'bookId': bookId,
          'relatedPurchaseId': purchaseDocRef.id,
        });
      }

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PurchaseSuccessScreen(
            bookId: bookId,
            price: finalPrice.toDouble(),
            bonusesUsed: bonusesToUse,
            bonusesAdded: bonusesToAdd,
            bookTitle: widget.bookTitle,
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Ошибка при покупке: $e');
      debugPrint('Stack trace: $stackTrace');

      Navigator.pop(context);
      _showRetryDialog(context, e.toString(), user?.uid ?? '');
    }
  }

  void _showAuthErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ошибка авторизации'),
        content: Text('Для совершения покупки необходимо войти в систему.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RegistrationScreen(isEmail: false),
                ),
              );
            },
            child: Text('Войти'),
          ),
        ],
      ),
    );
  }

  void _showRetryDialog(
      BuildContext context, String error, String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    final paymentMethods =
        (userDoc.data()?['payments'] as Map<String, dynamic>?) ?? {};
    final selectedMethod = userDoc.data()?['selectedPaymentMethod'] ?? 'card_1';
    final cardData = paymentMethods[selectedMethod] ?? {};
    final cardLast4 =
        (cardData['cardNumber'] as String?)?.substring(15) ?? '****';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ошибка оплаты'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Не удалось завершить покупку:'),
            SizedBox(height: 8),
            Text(error, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            if (cardData.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Используемая карта:'),
                  SizedBox(height: 4),
                  Text(
                    '${cardData['brand'] ?? 'Карта'} **** $cardLast4',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            SizedBox(height: 16),
            Text(
                'Пожалуйста, попробуйте снова или выберите другой способ оплаты.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handlePurchase();
            },
            child: Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }

  Future<void> _logPurchaseStart(
      String userId, String bookId, int price) async {
    await FirebaseFirestore.instance.collection('purchase_logs').doc().set({
      'userId': userId,
      'bookId': bookId,
      'price': price,
      'status': 'started',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  int getSafeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const SectionTitle({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            'Смотреть все',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.orange,
            ),
          ),
        ),
      ],
    );
  }
}
