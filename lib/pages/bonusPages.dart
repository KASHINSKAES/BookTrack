import 'package:booktrack/icons.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class BonusHistoryPage extends StatelessWidget {
  final VoidCallback onBack;
  BonusHistoryPage({super.key, required this.onBack});
  final List<Map<String, dynamic>> bonusHistory = [
    {
      "title": "Получение нового уровня",
      "date": "23.05.2023 13:35",
      "amount": 100,
      "isPositive": true
    },
    {
      "title": "Списание бонусов",
      "date": "23.05.2023 13:35",
      "amount": 255,
      "isPositive": false
    },
    {
      "title": "Получение нового уровня",
      "date": "23.05.2023 13:35",
      "amount": 100,
      "isPositive": true
    },
    {
      "title": "С днем рождения!",
      "date": "23.05.2023 13:35",
      "amount": 250,
      "isPositive": true
    },
    {
      "title": "Получение нового уровня",
      "date": "23.05.2023 13:35",
      "amount": 100,
      "isPositive": true
    },
    {
      "title": "Списание бонусов",
      "date": "23.05.2023 13:35",
      "amount": 255,
      "isPositive": false
    },
    {
      "title": "Получение нового уровня",
      "date": "23.05.2023 13:35",
      "amount": 100,
      "isPositive": true
    },
    {
      "title": "Списание бонусов",
      "date": "23.05.2023 13:35",
      "amount": 255,
      "isPositive": false
    },
    {
      "title": "Получение нового уровня",
      "date": "23.05.2023 13:35",
      "amount": 100,
      "isPositive": true
    },
    {
      "title": "С днем рождения!",
      "date": "23.05.2023 13:35",
      "amount": 250,
      "isPositive": true
    },
    {
      "title": "Получение нового уровня",
      "date": "23.05.2023 13:35",
      "amount": 100,
      "isPositive": true
    },
    {
      "title": "Списание бонусов",
      "date": "23.05.2023 13:35",
      "amount": 255,
      "isPositive": false
    },
    {
      "title": "Получение нового уровня",
      "date": "23.05.2023 13:35",
      "amount": 100,
      "isPositive": true
    },
    {
      "title": "Списание бонусов",
      "date": "23.05.2023 13:35",
      "amount": 255,
      "isPositive": false
    },
    {
      "title": "Получение нового уровня",
      "date": "23.05.2023 13:35",
      "amount": 100,
      "isPositive": true
    },
    {
      "title": "С днем рождения!",
      "date": "23.05.2023 13:35",
      "amount": 250,
      "isPositive": true
    },
    {
      "title": "Получение нового уровня",
      "date": "23.05.2023 13:35",
      "amount": 100,
      "isPositive": true
    },
    {
      "title": "Списание бонусов",
      "date": "23.05.2023 13:35",
      "amount": 255,
      "isPositive": false
    },
  ];

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
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
          )),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = bonusHistory[index];
                return ListTile(
                  title: Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    item['date'],
                    style: TextStyle(
                      fontSize: 16 * scale,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: Text(
                    "${item['isPositive'] ? '+' : '-'}${item['amount']}",
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
              childCount: bonusHistory.length,
            ),
          ),
        ],
      ),
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
    return ClipRRect(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(26 * scale),
            bottomRight: Radius.circular(26)),
        child: Container(
            color: AppColors.background,
            padding: EdgeInsets.all(16 * scale),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * scale)),
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
                              Text(
                                "3237",
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
            )));
  }

  @override
  bool shouldRebuild(_BonusHeaderDelegate oldDelegate) => false;
}
