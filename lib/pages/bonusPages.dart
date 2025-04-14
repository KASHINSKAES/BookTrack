import 'package:booktrack/icons.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future<QuerySnapshot<Map<String, dynamic>>> bonusHistoriUser(
    String userId) async {
  final snapshot1 = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('bonus_history')
      .get();

  return snapshot1;
}

Future<int> totalBonusesUsers(String userId) async {
  var totalBonuses = 0;
  final snapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (snapshot.exists) {
    totalBonuses = snapshot.data()?['totalBonuses']; // Берём только поле 'name'
  }

  return totalBonuses;
}

Future<int> totalBonusesUsersGet(BuildContext context) async {
  final authProvider = Provider.of<AuthProviders>(context, listen: false);
  final userModel = authProvider.userModel;
  if (userModel == null || userModel.uid.isEmpty) {
    throw Exception('User not authenticated');
  }

  try {
    final querySnapshot = await totalBonusesUsers(userModel.uid);
    debugPrint(querySnapshot.toString());
    return querySnapshot;
  } catch (e) {
    debugPrint('Error: $e');
    return 0;
  }
}

class BonusHistoryPage extends StatelessWidget {
  final VoidCallback onBack;
  BonusHistoryPage({super.key, required this.onBack});

  Future<List<Map<String, dynamic>>> bonusHistoriUserGet(
      BuildContext context) async {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final userModel = authProvider.userModel;
    if (userModel == null || userModel.uid.isEmpty) {
      throw Exception('User not authenticated');
    }

    try {
      final querySnapshot = await bonusHistoriUser(userModel.uid);
      final List<Map<String, dynamic>> data =
          querySnapshot.docs.map((doc) => doc.data()).toList();
      debugPrint(data.toString());
      return data;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: bonusHistoriUserGet(context),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'История бонусов',
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
            body: Center(child: Text('Ошибка загрузки данных')),
          );
        }

        final data = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'История бонусов',
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
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _BonusHeaderDelegate(
                  scale: scale,
                ),
              ),
              SliverToBoxAdapter(
                child: Text(
                  "История списания бонусов",
                  style: TextStyle(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = data[index];
                    Timestamp timestamp = item['date'];
                    DateTime dateTime = timestamp.toDate();
                    String formattedDate =
                        DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
                    return ListTile(
                      title: Text(
                        item['title'].toString(),
                        style: TextStyle(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 16 * scale,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      trailing: Text(
                        "${item['isPositive'] ? '+' : '-'}${item['amount'].toString()}",
                        style: TextStyle(
                          fontSize: 30 * scale,
                          fontWeight: FontWeight.w900,
                          color: item['isPositive']
                              ? Color(0xff1B8D04)
                              : Color(0xff8C0404),
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16 * scale, vertical: 8 * scale),
                    );
                  },
                  childCount: data.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BonusHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double scale;
  _BonusHeaderDelegate({required this.scale});

  @override
  double get minExtent => 180;
  @override
  double get maxExtent => 180;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return FutureBuilder<int>(
      future: totalBonusesUsersGet(context),
      builder: (context, snapshot) {
        return _buildHeader(snapshot.data ?? 0);
      },
    );
  }

  // Вынесем UI в отдельный метод для удобства
  Widget _buildHeader(int bonuses,
      {bool isLoading = false, bool isError = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(26 * scale),
        bottomRight: Radius.circular(26),
      ),
      child: Container(
        color: AppColors.background,
        padding: EdgeInsets.all(16 * scale),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * scale),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Мой баланс:",
                            style: TextStyle(
                              fontSize: 24 * scale,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            "Обновлено:",
                            style: TextStyle(
                              fontSize: 16 * scale,
                              color: AppColors.grey,
                            ),
                          ),
                          Text(
                            "23.05.2023 13:35",
                            style: TextStyle(
                              fontSize: 16 * scale,
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (isLoading)
                            SizedBox(
                              width: 48 * scale,
                              height: 48 * scale,
                              child: CircularProgressIndicator(
                                color: AppColors.orange,
                              ),
                            )
                          else if (isError)
                            Text(
                              "Ошибка",
                              style: TextStyle(
                                fontSize: 24 * scale,
                                color: Colors.red,
                              ),
                            )
                          else
                            Text(
                              bonuses.toString(),
                              style: TextStyle(
                                fontSize: 48 * scale,
                                color: AppColors.orange,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          Text(
                            "буккоины",
                            style: TextStyle(
                              fontSize: 18 * scale,
                              color: AppColors.orange,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_BonusHeaderDelegate oldDelegate) => false;
}
