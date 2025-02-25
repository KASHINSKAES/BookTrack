import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloudpayments/cloudpayments.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

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
    return Padding(
      padding: const EdgeInsets.all(16.0), // Отступы по краям
      child: Column(
        children: [
          // Поле для номера карты
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0), // Отступ снизу
            child: TextField(
              decoration: InputDecoration(
                labelText: "Номер карты",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(35)),
                hoverColor: AppColors.background,
                focusColor: AppColors.background, // Добавляем рамку
              ),
              keyboardType: TextInputType.number,
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
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "MM/YY",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(35)),
                      hoverColor: AppColors.background,
                      focusColor: AppColors.background,
                      // Добавляем рамку
                    ),
                    keyboardType: TextInputType.datetime,
                    onChanged: (value) => expiryDate = value,
                  ),
                ),
              ),

              // Поле "CVV"
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0), // Отступ слева
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "CVV",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(35)),
                      hoverColor: AppColors.background,
                      focusColor: AppColors.background, // Добавляем рамку
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    onChanged: (value) => cvv = value,
                  ),
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
