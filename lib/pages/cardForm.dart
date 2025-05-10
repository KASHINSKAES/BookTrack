import 'dart:math';

import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloudpayments/cloudpayments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddCardScreen extends StatefulWidget {
  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  String cardNumber = "";
  String expiryDate = "";
  String cvv = "";
  String publicId = "";
  String? userID;

  @override
  void initState() {
    super.initState();
    _loadUserID();
  }

  Future<void> _loadUserID() async {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final userModel = authProvider.userModel;

    if (userModel == null || userModel.uid.isEmpty) return;

    if (mounted) {
      setState(() {
        userID = userModel.uid;
      });
    }
  }

  void getToken() async {
    try {
      // Отправляем данные в CloudPayments для получения токена
      final token = await Cloudpayments.cardCryptogram(
          cardNumber: cardNumber,
          cardDate: expiryDate,
          cardCVC: cvv,
          publicId: publicId);
      final cryptogram = await Cloudpayments.cardCryptogram(
          cardNumber: cardNumber,
          cardDate: expiryDate,
          cardCVC: cvv,
          publicId: publicId);
      print('Cryptogram: $cryptogram');

      if (token != null) {
        print("Токен карты: $token");
        // Сохранить токен в Firestore
      } else {
        print("Ошибка при получении токена");
      }
    } catch (e) {
      print("Ошибка: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _cardNumberController = TextEditingController();
    final TextEditingController _expiryDateController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16.0), // Отступы по краям
      child: Column(
        children: [
          // Поле для номера карты
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0), // Отступ снизу
            child: // Использование в TextFormField

                TextFormField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'Номер карты',
                hintText: 'XXXX XXXX XXXX XXXX',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(35)),
                hoverColor: AppColors.background,
                focusColor: AppColors.background,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CardNumberInputFormatter(),
                LengthLimitingTextInputFormatter(19), // 16 цифр + 3 пробела
              ],
              onChanged: (value) => cardNumber = value,
            ),
          ),

          // Row для полей "Срок (MM/YY)" и "CVV"
          Row(
            children: [
              // Поле "Срок (MM/YY)"
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0), // Отступ справа
                  child: TextFormField(
                    controller: _expiryDateController,
                    decoration: InputDecoration(
                      labelText: 'Срок действия',
                      hintText: 'MM/YY',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(35)),
                      hoverColor: AppColors.background,
                      focusColor: AppColors.background,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      DateInputFormatter(),
                      LengthLimitingTextInputFormatter(5), // MM/YY
                    ],
                    onChanged: (value) => expiryDate = value,
                  ),
                ),
              ),

              // Поле "CVV"
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(left: 8.0), // Отступ слева
                    child: TextFormField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(3),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "CVV",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(35)),
                        hoverColor: AppColors.background,
                        focusColor: AppColors.background, // Добавляем рамку
                      ),
                      obscureText: true,
                      onChanged: (value) => cvv = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите CVV';
                        }
                        if (value.length != 3) {
                          return 'CVV должен состоять из 3 цифр';
                        }
                        return null;
                      },
                    )),
              ),
            ],
          ),

          // Кнопка "Получить токен"
          SizedBox(height: 20),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColors.background),
            ),
            onPressed: () {
              if (userID == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Пользователь не авторизован')),
                );
                return;
              }
              if (cardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Заполните все поля карты')),
                );
                return;
              }
              saveCardToken(userID!, 'token_example', cardNumber);
            },
            child: Text(
              "Применить",
              style: TextStyle(fontSize: 32, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Функция для генерации уникального идентификатора
  Future<String> generateUniqueCardId(String userId) async {
    // ← Добавьте параметр
    String cardId = '';
    bool isUnique = false;

    while (!isUnique) {
      int randomNumber = Random().nextInt(10000);
      cardId = 'card_$randomNumber';
      isUnique = await _isCardIdUnique(userId, cardId); // ← Передаём userId
    }

    return cardId;
  }

  // Функция для проверки уникальности идентификатора в Firestore
  Future<bool> _isCardIdUnique(String userId, String cardId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('payments')
          .doc(cardId)
          .get();

      // Если документ не существует, значит cardId уникален
      return !doc.exists;
    } catch (e) {
      print('Ошибка при проверке уникальности cardId: $e');
      return false; // В случае ошибки считаем, что cardId не уникален
    }
  }

  // Функция для проверки, существует ли уже такая карта
  Future<bool> _isCardDataUnique(
      Map<String, dynamic> cardData, String userId) async {
    try {
      // Получаем все карты пользователя
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('payments')
          .get();

      // Проверяем на дубликаты
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['cardNumber'] == cardData['cardNumber']) {
          return false;
        }
      }
      return true;
    } catch (e) {
      print('Ошибка проверки уникальности: $e');
      return false; // В случае ошибки считаем карту неуникальной
    }
  }

  // Функция для добавления карты в Firestore
  Future<void> saveCardToken(
      String userId, String token, String cardNumber) async {
    if (!mounted) return;
    String cardIds = await generateUniqueCardId(userId); // Передаём userId

    try {
      // Валидация параметров
      if (userId.isEmpty || token.isEmpty || cardNumber.isEmpty) {
        throw 'Все поля обязательны для заполнения';
      }

      // Нормализация номера карты
      final cleanCardNumber = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanCardNumber.length < 4) {
        throw 'Номер карты слишком короткий';
      }

      // Подготовка данных карты
      final cardType = getCardType(cleanCardNumber);
      final last4 =
          cleanCardNumber.substring(max(0, cleanCardNumber.length - 4));

      final cardData = {
        'token': token,
        'cardNumber': '**** **** **** $last4',
        'brand': cardType.toString().split('.').last,
        'addedAt': FieldValue.serverTimestamp(),
      };

      // Проверка уникальности
      if (!await _isCardDataUnique(cardData, userId)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Эта карта уже привязана к вашему аккаунту')),
          );
        }
        return;
      }

      // Сохранение карты
      final cardId = cardIds;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('payments')
          .doc(cardId)
          .set(cardData);

      // Успешное завершение
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Карта успешно добавлена')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      }
      print('Ошибка сохранения карты: $e');
    }
  }
}

enum CardType {
  visa,
  mastercard,
  americanExpress,
  discover,
  unionPay,
  jcb,
  mir,
  maestro,
  dinersClub,
  unknown,
}

CardType getCardType(String cardNumber) {
  // Убираем все пробелы и нечисловые символы
  cardNumber = cardNumber.replaceAll(RegExp(r'\D'), '');

  if (cardNumber.isEmpty) {
    return CardType.unknown;
  }

  // Определяем тип карты по первым цифрам
  if (cardNumber.startsWith('4')) {
    return CardType.visa;
  } else if (cardNumber.startsWith(RegExp(r'5[1-5]'))) {
    return CardType.mastercard;
  } else if (cardNumber
      .startsWith(RegExp(r'222[1-9]|22[3-9]\d|2[3-6]\d{2}|27[0-1]\d|2720'))) {
    return CardType.mastercard;
  } else if (cardNumber.startsWith('34') || cardNumber.startsWith('37')) {
    return CardType.americanExpress;
  } else if (cardNumber.startsWith('6011') ||
      cardNumber.startsWith('65') ||
      cardNumber.startsWith(RegExp(r'64[4-9]'))) {
    return CardType.discover;
  } else if (cardNumber.startsWith('62')) {
    return CardType.unionPay;
  } else if (cardNumber.startsWith('35')) {
    return CardType.jcb;
  } else if (cardNumber.startsWith('2200') ||
      cardNumber.startsWith('2201') ||
      cardNumber.startsWith('2202') ||
      cardNumber.startsWith('2203') ||
      cardNumber.startsWith('2204')) {
    return CardType.mir;
  } else if (cardNumber.startsWith('50') ||
      cardNumber.startsWith(RegExp(r'5[6-8]')) ||
      cardNumber.startsWith('639') ||
      cardNumber.startsWith('67')) {
    return CardType.maestro;
  } else if (cardNumber.startsWith('300') ||
      cardNumber.startsWith('301') ||
      cardNumber.startsWith('302') ||
      cardNumber.startsWith('303') ||
      cardNumber.startsWith('304') ||
      cardNumber.startsWith('305') ||
      cardNumber.startsWith('36') ||
      cardNumber.startsWith('38') ||
      cardNumber.startsWith('39')) {
    return CardType.dinersClub;
  } else {
    return CardType.unknown;
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    // Удаляем все пробелы
    text = text.replaceAll(' ', '');

    // Добавляем пробелы каждые 4 символа
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i != text.length - 1) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    // Удаляем все символы, кроме цифр
    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    // Добавляем "/" после первых двух цифр
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && i != text.length - 1) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class ExpiryDateInput extends StatefulWidget {
  @override
  _ExpiryDateInputState createState() => _ExpiryDateInputState();
}

class _ExpiryDateInputState extends State<ExpiryDateInput> {
  final TextEditingController _expiryDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ввод срока действия')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _expiryDateController,
              decoration: InputDecoration(
                labelText: 'Срок действия',
                hintText: 'MM/YY',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                DateInputFormatter(),
                LengthLimitingTextInputFormatter(5), // MM/YY
              ],
              onChanged: (value) {
                print('Срок действия: $value');
              },
            ),
          ],
        ),
      ),
    );
  }
}
