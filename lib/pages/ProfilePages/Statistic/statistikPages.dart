import 'dart:math';

import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/pages/ProfilePages/Statistic/ReadingStatsProvider.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_pie_chart/easy_pie_chart.dart';
import 'package:flutter_svg/svg.dart';

class StatisticsPage extends StatefulWidget {
  final VoidCallback onBack;
  const StatisticsPage({super.key, required this.onBack});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int selectedWeek = 0;
  double scale = 1.0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<ReadingStatsProvider>(context, listen: false);
    await provider.loadData(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReadingStatsProvider>(context);
    scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text(provider.errorMessage!)),
      );
    }

    if (provider.dailyDataPages.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Нет данных для отображения')),
      );
    }

    final weeks = provider.weeklyDataPages.keys.toList();
    final currentWeekDataPages =
        provider.weeklyDataPages[weeks[selectedWeek]] ?? List.filled(7, 0);
    final currentWeekDataMinutes =
        provider.weeklyDataMinutes[weeks[selectedWeek]] ?? List.filled(7, 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Статистика',
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
            BookTrackIcon.onBack,
            color: Colors.white,
          ),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.baseCircual * scale),
              topRight: Radius.circular(AppDimensions.baseCircual * scale),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildWeekChartCard(
                  title: "Страницы",
                  chart: _PagesBarChart(
                    readingPages: provider.weeklyDataPages[
                            weeks[provider.selectedWeekPage]] ??
                        List.filled(7, 0),
                  ),
                  weeks: weeks,
                  provider: provider,
                  isPages: true),
              const SizedBox(height: 20),
              _buildWeekChartCard(
                  title: "Минуты",
                  chart: _ReadingTimeLineChart(
                    readingTime: provider.weeklyDataMinutes[
                            weeks[provider.selectedWeekTime]] ??
                        List.filled(7, 0),
                  ),
                  weeks: weeks,
                  provider: provider,
                  isPages: false),
              const SizedBox(height: 20),
              _buildDaySelector(provider),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPieChartCard(
                    title: "Время чтения",
                    minutes: provider.minutes,
                    goalMinutes: provider.goalMinutes,
                  ),
                  _buildPieChartCard(
                      title: "Количество страниц",
                      pages: provider.pages,
                      goalPages: provider.goalPages,
                      minutes: provider.minutes,
                      goalMinutes: provider.goalMinutes),
                ],
              ),
              const SizedBox(height: 20),
              _buildBooksReadToday(scale),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekChartCard({
    required String title,
    required Widget chart,
    required List<String> weeks,
    required ReadingStatsProvider provider,
    required bool isPages,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildWeekSelector(weeks, provider, isPages),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSelector(
      List<String> weeks, ReadingStatsProvider provider, bool isPages) {
    return isPages
        ? Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: provider.selectedWeekPage > 0
                    ? () =>
                        provider.changePageWeek(provider.selectedWeekPage - 1)
                    : null,
              ),
              Text(
                weeks[provider.selectedWeekPage],
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: provider.selectedWeekPage < weeks.length - 1
                    ? () =>
                        provider.changePageWeek(provider.selectedWeekPage + 1)
                    : null,
              ),
            ],
          )
        : Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: provider.selectedWeekTime > 0
                    ? () =>
                        provider.changeTimeWeek(provider.selectedWeekTime - 1)
                    : null,
              ),
              Text(
                weeks[provider.selectedWeekTime],
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: provider.selectedWeekTime < weeks.length - 1
                    ? () =>
                        provider.changeTimeWeek(provider.selectedWeekTime + 1)
                    : null,
              ),
            ],
          );
  }
}

Widget _buildPieChartCard(
    {required String title,
    required int minutes,
    required int goalMinutes,
    int? pages,
    int? goalPages}) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(horizontal: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 145,
            child: TodayPieChart(
              progress: (pages ?? minutes).toDouble(),
              progressWant: (goalPages ?? goalMinutes).toDouble(),
              title: pages != null ? 'страниц' : 'минут',
              value: (pages ?? minutes).toString(),
              icon: pages != null
                  ? BookTrackIcon.bookStat
                  : BookTrackIcon.clockStat,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDaySelector(ReadingStatsProvider provider) {
  final days = provider.dailyDataPages.keys.toList();
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: provider.selectedDay > 0
            ? () => provider.setSelectedDay(provider.selectedDay - 1)
            : null,
      ),
      Text(
        provider.selectedDate,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: provider.selectedDay < days.length - 1
            ? () => provider.setSelectedDay(provider.selectedDay + 1)
            : null,
      ),
    ],
  );
}

Widget _buildBooksReadToday(double scale) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(horizontal: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Что вы читали сегодня",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3, // Замените на реальное количество книг
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SvgPicture.asset(
                  "images/img1.svg",
                  width: 150 * scale,
                  height: 200 * scale,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PagesBarChart extends StatelessWidget {
  final List<int> readingPages;

  const _PagesBarChart({required this.readingPages});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const days = ["ВС", "ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ"];
                  final index = value.toInt();
                  if (index >= 0 && index < days.length) {
                    return Text(days[index],
                        style: const TextStyle(fontSize: 12));
                  }
                  return const SizedBox
                      .shrink(); // или верните пустой виджет, если индекс недопустим
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 40),
            )),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        barGroups: List.generate(
          readingPages.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                  toY: readingPages[index].toDouble(),
                  color: AppColors.buttonBorder,
                  width: 16,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadingTimeLineChart extends StatelessWidget {
  final List<int> readingTime;

  const _ReadingTimeLineChart({required this.readingTime});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const days = ["ВС", "ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ"];
                  final index = value.toInt();
                  if (index >= 0 && index < days.length) {
                    return Text(days[index],
                        style: const TextStyle(fontSize: 12));
                  }
                  return const SizedBox
                      .shrink(); // или верните пустой виджет, если индекс недопустим
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 40),
            )),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
              spots: List.generate(
                  readingTime.length,
                  (index) =>
                      FlSpot(index.toDouble(), readingTime[index].toDouble())),
              isCurved: false,
              color: Color(0xffFFD3C5),
              barWidth: 3,
              dotData: FlDotData(show: true, checkToShowDot: (_, __) => true),
              belowBarData: (BarAreaData(show: false))),
        ],
      ),
    );
  }
}

class TodayPieChart extends StatelessWidget {
  final double progress;
  final double progressWant;
  final String title;
  final String value;
  final IconData icon;

  TodayPieChart({
    required this.progress,
    required this.progressWant,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
                width: 100,
                height: 100,
                child: EasyPieChart(
                  children: [
                    PieData(
                        value: max(0, progressWant - progress),
                        color: Color(0xffFFD3C5)),
                    PieData(value: progress, color: AppColors.orange),
                  ],
                  borderEdge: StrokeCap.round,
                  showValue: false,
                )),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: AppColors.textPrimary),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Text(value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(width: 3),
            Text(title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}

class _BooksReadToday extends StatelessWidget {
  final double scale;
  _BooksReadToday({
    required this.scale,
  });
  final List<String> bookCovers = [
    "images/img1.svg",
    "images/img1.svg",
    "images/img1.svg",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text("Что вы читали сегодня",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: bookCovers.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SvgPicture.asset(
              bookCovers[index],
              width: 150 * scale,
              height: 200 * scale,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ]);
  }
}
