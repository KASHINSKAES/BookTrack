import 'dart:math';

import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/pages/BookCard/text/textBookOtr.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/pages/LoginPAGES/RegistrPage.dart';
import 'package:booktrack/pages/BookCard/Detail/PurchaseSuccessScreen.dart';
import 'package:booktrack/pages/helpsWidgets/bookDetailAppBar.dart';
import 'package:booktrack/pages/BookCard/Detail/purchaseButton.dart';
import 'package:booktrack/pages/BookCard/text/textBook.dart';
import 'package:booktrack/widgets/BookReviewsWidget.dart';
import 'package:booktrack/widgets/blobPath.dart';
import 'package:booktrack/widgets/bookListGoris.dart';
import 'package:booktrack/widgets/bookRaitingWidget.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

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
  final String format;
  final int price;
  final VoidCallback onBack;
  final List<String> tags;

  const BookDetailScreen(
      {required this.bookId,
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
      required this.format,
      required this.price,
      required this.tags,
      required this.onBack});

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
      var bookId = widget.bookId;
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
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final userModel = authProvider.userModel;
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
        appBar: BookDetailsAppBar(
          bookId: widget.bookId,
          bookTitle: widget.bookTitle,
          userId: userModel?.uid ?? '', //
          scrollPosition: _scrollPosition,
          onBack: widget.onBack,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final scale =
                MediaQuery.of(context).size.width / AppDimensions.baseWidth;

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
                top: 16.0, left: 16.0, right: 16.0, bottom: 250.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30 * scale),
                _buildBookInfo(scale),
                _buildBookDescription(scale),
                _buildBookTags(scale),
                _buildSBooksSection(
                  scale,
                ),
                BookReviewsWidget(
                  bookId: widget.bookId,
                  scale: scale,
                ),
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
        BookRatingWidget(
          bookId: widget.bookId,
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
        Expanded(
            flex: 1,
            child: widget.tags.isEmpty
                ? (Text('Нет тегов'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Wrap(
                          runSpacing: 4.0 * scale,
                          children: widget.tags
                              .take(5)
                              .map((tag) => Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11 * scale,
                                      ),
                                      softWrap: true,
                                    ),
                                  ))
                              .toList(),
                        )
                      ])),
        SizedBox(width: 8 * scale),
        Expanded(
          flex: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 180 * scale),
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
                ),
                Text(
                  'Год издания: ${widget.yearPublisher}',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSBooksSection(double scale) {
    return Column(
      children: [
        SectionTitle(
          title: "Другие книги автора",
          onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AllBooksPage(
                        author: widget.authorName,
                        currentBookId: widget.bookId,
                      )),
            );
          },
        ),
        BookList(
          currentBookId: widget.bookId,
          author: widget.authorName,
          maxItemsToShow: 5,
        ),
        SectionTitle(
          title: "Похожие книги",
          onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AllBooksPage(
                        format: widget.format,
                        language: widget.language,
                        currentBookId: widget.bookId,
                      )),
            );
          },
        ),
        BookList(
          currentBookId: widget.bookId,
          format: widget.format,
          language: widget.language,
          maxItemsToShow: 5,
        ),
      ],
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
                icon: BookTrackIcon.selectetScreen,
                title: 'Полностью',
                subtitle: _buildPriceWithBonuses(scale),
                onPressed: _handlePurchase,
                scale: scale,
              ),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: PurchaseButton(
                icon: BookTrackIcon.listDetailBook,
                title: 'Отрывок',
                subtitle: 'бесплатно',
                onPressed: () {
                  // Навигация на страницу чтения книги
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookScreenOtr(
                          bookId: widget.bookId,
                          onBack: () {
                            Navigator.pop(context);
                          }),
                    ),
                  );
                },
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
      _showRetryDialog(context, e.toString(), user.uid);
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
