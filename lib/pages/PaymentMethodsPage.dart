import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/pages/CardMenegment.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/pages/cardForm.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PaymentMethodsPage extends StatefulWidget {
  final double scale;
  final VoidCallback onBack;

  const PaymentMethodsPage({
    super.key,
    required this.scale,
    required this.onBack,
  });

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  String? selectedPaymentMethod;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadSelectedPaymentMethod();
  }

  Future<void> _loadSelectedPaymentMethod() async {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final userModel = authProvider.userModel;

    if (userModel == null || userModel.uid.isEmpty) return;

    if (mounted) {
      setState(() {
        selectedPaymentMethod = userModel.selectedPaymentMethod;
        userId = userModel.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    debugPrint(selectedPaymentMethod);

    return Scaffold(
      appBar: _buildAppBar(scale),
      backgroundColor: AppColors.background,
      body: _buildBody(scale),
    );
  }

  AppBar _buildAppBar(double scale) {
    return AppBar(
      title: Text(
        'Способы оплаты',
        style: TextStyle(
          fontSize: 28 * scale,
          color: Colors.white,
        ),
        softWrap: true,
      ),
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: Icon(
          size: 35 * scale,
          BookTrackIcon.onBack,
          color: Colors.white,
        ),
        onPressed: widget.onBack,
      ),
      actions: [
        IconButton(
          icon: Icon(
            size: 35 * scale,
            Icons.settings,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CardsManagementScreen(userId: userId.toString()),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(double scale) {
    return Container(
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
          vertical: 19 * scale,
          horizontal: 16 * scale,
        ),
        children: [
          _buildCardsSection(scale),
          _buildPaymentHistorySection(scale),
        ],
      ),
    );
  }

  Widget _buildCardsSection(double scale) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _fetchPaymentCards(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyCardsState(scale);
        }

        return _buildCardsList(scale, snapshot.data!);
      },
    );
  }

  Widget _buildEmptyCardsState(double scale) {
    return _buildSectionContainer(
      scale,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Ваши карты", scale),
          const SizedBox(height: 10),
          SizedBox(
            height: 110 * scale,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildAddCardButton(scale),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsList(double scale, List<Map<String, dynamic>> cards) {
    return _buildSectionContainer(
      scale,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Ваши карты", scale),
          const SizedBox(height: 10),
          SizedBox(
            height: 110 * scale,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildAddCardButton(scale),
                ...cards.map((card) => _buildCardItem(scale, card)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(double scale, Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 19 * scale,
        vertical: 20 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(4, 8),
          ),
        ],
        borderRadius: BorderRadius.all(
          Radius.circular(AppDimensions.baseCircual * scale),
        ),
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, double scale) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 24 * scale,
      ),
    );
  }

  Widget _buildAddCardButton(double scale) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Container(
        width: 130 * scale,
        height: 95 * scale,
        padding: EdgeInsets.symmetric(
          horizontal: 9 * scale,
          vertical: 5 * scale,
        ),
        margin: const EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          color: const Color(0xffB8BEF6),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 15 * scale),
            Text(
              "Добавить карту",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15 * scale,
              ),
            ),
          ],
        ),
      ),
      onPressed: () => _showAddCardDialog(scale),
    );
  }

  Widget _buildCardItem(double scale, Map<String, dynamic> card) {
    return Container(
      width: 130 * scale,
      height: 95 * scale,
      padding: EdgeInsets.symmetric(
        horizontal: 9 * scale,
        vertical: 5 * scale,
      ),
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
                    fontSize: 15 * scale,
                  ),
                )
              : Text(
                  card["cardNumber"].toString().lastChars(4),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15 * scale,
                  ),
                  textAlign: TextAlign.center,
                ),
        ],
      ),
    );
  }

  void _showAddCardDialog(double scale) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.426,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 16 * scale),
                  child: SizedBox(
                    width: scale * 190,
                    child: Text(
                      "Введите данные карты",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24 * scale,
                      ),
                      softWrap: true,
                    ),
                  ),
                ),
                Expanded(child: AddCardScreen()),
                TextButton(
                  child: const Text('Закрыть'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentHistorySection(double scale) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchPaymentHistory(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("История оплаты", scale),
              const SizedBox(height: 10),
              Text(
                "История оплат пуста",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18 * scale,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }

        final groupedHistory = _groupHistoryByMonth(snapshot.data!);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("История оплаты", scale),
            const SizedBox(height: 10),
            ...groupedHistory.entries.map(
              (entry) => _buildMonthHistoryGroup(scale, entry.key, entry.value),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthHistoryGroup(
    double scale,
    String month,
    List<Map<String, dynamic>> payments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          month[0].toUpperCase() + month.substring(1),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18 * scale,
          ),
        ),
        const SizedBox(height: 10),
        ...payments.map(
          (payment) => _buildPaymentItem(scale, payment),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(double scale, Map<String, dynamic> payment) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10 * scale),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 5 * scale,
          vertical: 10 * scale,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(4, 8),
            ),
          ],
          borderRadius: BorderRadius.all(
            Radius.circular(AppDimensions.baseCircual * scale),
          ),
        ),
        child: ListTile(
          title: Text(
            payment['reason'],
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18 * scale,
            ),
          ),
          leading: Icon(
            BookTrackIcon.bonusProfilesvg,
            size: 48 * scale,
            color: AppColors.orange,
          ),
          subtitle: Text(
            'Списано ${DateFormat('dd MMMM', 'ru').format(payment['date'])}',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14 * scale,
            ),
            softWrap: false,
          ),
          trailing: Text(
            '-${payment['amount']}P',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20 * scale,
            ),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String lastChars(int n) => substring(length - n);
}

Future<List<Map<String, dynamic>>> _fetchPaymentHistory(
    BuildContext context) async {
  final authProvider = Provider.of<AuthProviders>(context, listen: false);
  final userModel = authProvider.userModel;

  if (userModel == null) return [];

  final QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userModel.uid)
      .collection('purchase_history')
      .get();

  return snapshot.docs.map((doc) {
    return {
      'amount': doc['amount'],
      'date': doc['date'].toDate(),
      'reason': doc['reason'],
    };
  }).toList();
}

Stream<List<Map<String, dynamic>>> _fetchPaymentCards(BuildContext context) {
  final authProvider = Provider.of<AuthProviders>(context, listen: false);
  final userModel = authProvider.userModel;

  if (userModel == null) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(userModel.uid)
      .collection('payments')
      .snapshots()
      .map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      return {
        'cardId': doc.id,
        'cardNumber': doc['cardNumber'],
        // Add other fields you might need from the document
      };
    }).toList();
  });
}

Map<String, List<Map<String, dynamic>>> _groupHistoryByMonth(
  List<Map<String, dynamic>> history,
) {
  final Map<String, List<Map<String, dynamic>>> groupedHistory = {};

  for (final entry in history) {
    final date = entry['date'] as DateTime;
    final monthKey = DateFormat('LLLL yyyy', 'ru').format(date);

    groupedHistory.putIfAbsent(monthKey, () => []).add(entry);
  }

  return groupedHistory;
}
