import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloudpayments/cloudpayments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class AddCardScreen extends StatefulWidget {
  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  String cardNumber = "";
  String expiryDate = "";
  String cvv = "";
  String publicId = "";

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
                border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(35)),
                      hoverColor: AppColors.background,
                      focusColor: AppColors.background,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CardNumberInputFormatter(),
                LengthLimitingTextInputFormatter(19), // 16 цифр + 3 пробела
              ],
              onChanged:  (value) => cardNumber = value,
            ),
          ),

          // Row для полей "Срок (MM/YY)" и "CVV"
          Row(
            children: [
              // Поле "Срок (MM/YY)"
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0), // Отступ справа
                  child:  TextFormField(
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
              onChanged:(value) =>expiryDate = value,
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
                    onChanged: (value) =>cvv = value,
                    
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите CVV';
    }
    if (value.length != 3) {
      return 'CVV должен состоять из 3 цифр';
    }
    return null;
  },
)
                ),
              ),
            ],
          ),

          // Кнопка "Получить токен"
          SizedBox(height: 20),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(AppColors.background),
            ),
            onPressed: getToken,
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

  void saveCardToken(String userId, String token, String last4, String brand) {
    FirebaseFirestore.instance.collection("user_cards").doc(userId).set({
      "cards": FieldValue.arrayUnion([
        {
          "token": token,
          "maskedNumber": "**** **** **** $last4",
          "brand": brand,
          "addedAt": DateTime.now().toIso8601String(),
        }
      ])
    }, SetOptions(merge: true));
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