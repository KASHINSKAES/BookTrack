import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class CardFormScreen extends StatefulWidget {
  final Function(Map<String, String>) onSave;

  CardFormScreen({required this.onSave});

  @override
  _CardFormScreenState createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void _submitForm() {
    if (formKey.currentState!.validate()) {
      final cardData = {
        'cardNumber': cardNumber,
        'expiryDate': expiryDate,
        'cardHolderName': cardHolderName,
        'cvvCode': cvvCode,
      };
      // Вызываем callback с данными карты
      widget.onSave(cardData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CreditCardWidget(
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cardHolderName: cardHolderName,
            cvvCode: cvvCode,
            showBackView: isCvvFocused,
            cardBgColor: Colors.blue,
            textStyle: TextStyle(color: Colors.white), onCreditCardWidgetChange: (CreditCardBrand ) {  },
          ),
          CreditCardForm(
            formKey: formKey,
            onCreditCardModelChange: (CreditCardModel creditCardModel) {
              setState(() {
                cardNumber = creditCardModel.cardNumber;
                expiryDate = creditCardModel.expiryDate;
                cardHolderName = creditCardModel.cardHolderName;
                cvvCode = creditCardModel.cvvCode;
                isCvvFocused = creditCardModel.isCvvFocused;
              });
            },
            themeColor: Colors.blue,
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cardHolderName: cardHolderName,
            cvvCode: cvvCode,
          ),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}