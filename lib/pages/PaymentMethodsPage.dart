import 'package:booktrack/icons.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

final List<Map<String, dynamic>> paymentHistory = [
  {
    "amount": 250,
    "date_bonus": DateTime(2024,1,5),
    "reason": "Достигнут новый уровень"
  }
];
final List<Map<String, dynamic>> paymentCard = [
  {
    "cardId": "card_1",
    "cardNumber": 1234123412341234,
  },
  {
    "cardId": "card_2",
    "cardNumber": 1234123434743564,
  },
  {
    "cardId": "card_3",
    "cardNumber": 1234123609800874,
  },
  {
    "cardId": "card_4",
    "cardNumber": 1234123412341234,
  },
  {
    "cardId": "card_5",
    "cardNumber": 1234123412341234,
  }
];
final String selectedPaymentMethod = "card_1";

class PaymentMethodsPage extends StatelessWidget {
  final VoidCallback onBack;
  PaymentMethodsPage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Способы оплаты',
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
            padding: EdgeInsets.symmetric(vertical: 19 * scale),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: const Color(0xffF5F5F5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.baseCircual * scale),
                topRight: Radius.circular(AppDimensions.baseCircual * scale),
              ),
            ),
            child: ListView(
              padding: EdgeInsets.symmetric(
                  vertical: 19 * scale, horizontal: 23 * scale),
              children: [
                _buildCard(scale),
              ],
            )));
  }
}

Widget _buildCard(double scale) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 19 * scale, vertical: 20 * scale),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 4,
          offset: Offset(4, 8), // Shadow position
        ),
      ],
      borderRadius:
          BorderRadius.all(Radius.circular(AppDimensions.baseCircual * scale)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ваши карты",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 24 * scale),
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 110 * scale, // Ограничиваем высоту списка
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Container(
                width: 130 * scale,
                height: 95 * scale,
                padding: EdgeInsets.symmetric(
                    horizontal: 9 * scale, vertical: 5 * scale),
                margin: const EdgeInsets.only(top: 15),
                decoration: BoxDecoration(
                  color: const Color(0xffB8BEF6),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(MyFlutterApp.back, size: 24 * scale),
                    SizedBox(height: 15 * scale),
                    Text("Добавить карту",
                        style: TextStyle(
                            color: AppColors.textPrimary, fontSize: 15 * scale))
                  ],
                ),
              ),
              ...paymentCard.map((card) => Container(
                    width: 130 * scale,
                    height: 95 * scale,
                    padding: EdgeInsets.symmetric(
                        horizontal: 9 * scale, vertical: 5 * scale),
                    margin: const EdgeInsets.only(top: 15, left: 26),
                    decoration: BoxDecoration(
                      color: const Color(0xffB8BEF6),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: 15 * scale),
                        card["cardId"] == selectedPaymentMethod
                            ? Text(
                                "${card["cardNumber"].toString().lastChars(4)} основной",
                                style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15 * scale))
                            : Text(
                                card["cardNumber"].toString().lastChars(4),
                                style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15 * scale),
                                textAlign: TextAlign.center,
                              )
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    ),
  );
}

extension E on String {
  String lastChars(int n) => substring(length - n);
}
