import 'package:booktrack/MyFlutterIcons.dart';
import 'package:booktrack/icons.dart';
import 'package:booktrack/pages/cardForm.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final List<Map<String, dynamic>> paymentHistory = [
  {"amount": 250, "date": DateTime(2024, 1, 5), "reason": "Покупка книги"},
  {"amount": 350, "date": DateTime(2024, 1, 5), "reason": "Оплата подписки"},
  {"amount": 250, "date": DateTime(2024, 2, 5), "reason": "Покупка книги"},
  {"amount": 250, "date": DateTime(2024, 3, 5), "reason": "Покупка книги"},
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
            padding: EdgeInsets.symmetric(vertical: 10 * scale),
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
                  vertical: 19 * scale, horizontal: 16 * scale),
              children: [
                _buildCard(scale, context),
                _builHistoryPaument(scale),
              ],
            )));
  }
}

Widget _buildCard(double scale, BuildContext context) {
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
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // Прозрачный фон
                    elevation: 0, // Убираем тень
                    padding: EdgeInsets.zero, // Убираем внутренние отступы
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // Скругление углов
                    ),
                  ),
                  child: Container(
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
                                    color: AppColors.textPrimary,
                                    fontSize: 15 * scale))
                          ])),
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      barrierDismissible:
                          false, // пользователь должен нажать кнопку!
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Container(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height *
                                  0.8, // Ограничиваем высоту
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    "Введите данные карты",
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 24 * scale,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: AddCardScreen(),
                                ),
                                TextButton(
                                  child: const Text('Закрыть'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
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

Map<String, List<Map<String, dynamic>>> groupBonusHistoryByMonth(
    List<Map<String, dynamic>> history) {
  Map<String, List<Map<String, dynamic>>> groupedHistory = {};

  for (var entry in history) {
    DateTime date = entry['date'];
    String monthKey =
        DateFormat('LLLL yyyy', 'ru').format(date); // Пример: "январь 2024"

    if (!groupedHistory.containsKey(monthKey)) {
      groupedHistory[monthKey] = [];
    }

    groupedHistory[monthKey]!.add(entry);
  }

  return groupedHistory;
}

Widget _builHistoryPaument(double scale) {
  Map<String, List<Map<String, dynamic>>> groupedHistory =
      groupBonusHistoryByMonth(paymentHistory);
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(
      "История оплаты",
      style: TextStyle(color: AppColors.textPrimary, fontSize: 24 * scale),
    ),
    SizedBox(height: 10),
    ...groupedHistory.entries.map((entry) {
      String month = entry.key; // Название месяца
      List<Map<String, dynamic>> bonuses = entry.value;

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          month[0].toUpperCase() + month.substring(1),
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18 * scale),
        ),
        SizedBox(height: 10),
        ...bonuses.map((bonus) {
          return Padding(
              padding: EdgeInsets.symmetric(vertical: 10 * scale),
              child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 5 * scale, vertical: 10 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 4,
                        offset: Offset(4, 8), // Shadow position
                      ),
                    ],
                    borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.baseCircual * scale)),
                  ),
                  child: ListTile(
                    title: Text(
                      "${bonus['reason']}",
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 18 * scale),
                    ),
                    leading: Icon(
                      MyFlutter.bonus,
                      size: 48 * scale,
                      color: AppColors.orange,
                    ),
                    subtitle: Text(
                      'Списано ${DateFormat('dd MMMM', 'ru').format(bonus['date'])}',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 14 * scale),
                      softWrap: false,
                    ),
                    trailing: Text('-${bonus['amount']}P',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20 * scale)),
                  )));
        })
      ]);
    }).toList(),
  ]);
}
