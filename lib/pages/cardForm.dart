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
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(labelText: "Номер карты"),
          keyboardType: TextInputType.number,
          onChanged: (value) => cardNumber = value,
        ),
        TextField(
          decoration: InputDecoration(labelText: "Срок (MM/YY)"),
          keyboardType: TextInputType.datetime,
          onChanged: (value) => expiryDate = value,
        ),
        TextField(
          decoration: InputDecoration(labelText: "CVV"),
          keyboardType: TextInputType.number,
          obscureText: true,
          onChanged: (value) => cvv = value,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: getToken,
          child: Text("Получить токен"),
        ),
      ],
    );
  }
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
