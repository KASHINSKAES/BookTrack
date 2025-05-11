import 'package:booktrack/icons.dart';
import 'package:booktrack/pages/AppState.dart';
import 'package:booktrack/pages/readingGoals.dart';
import 'package:booktrack/widgets/SemiCircleChart.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_pie_chart/easy_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class ActivityPage extends StatefulWidget {
  final VoidCallback onBack;
  final String userId;

  const ActivityPage({super.key, required this.onBack, required this.userId});

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late Stream<List<ReadingGoal>> _goalsStream;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _goalsStream = FirebaseFirestore.instance
        .collection('users/${widget.userId}/reading_goals')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReadingGoal.fromFirestore(doc))
            .toList());

    // Загрузка текущих целей
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Provider.of<AppState>(context, listen: false)
            .loadCurrentGoals(widget.userId);
      } catch (e) {
        print('Ошибка инициализации целей: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Активность',
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
          onPressed: widget.onBack,
        ),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.baseCircual * scale),
              topRight: Radius.circular(AppDimensions.baseCircual * scale),
            ),
          ),
          child: ListView(
            children: [
              _buildDailyGoals(appState),
              _buildActivityDays(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyGoals(AppState appState) {
    return StreamBuilder<List<ReadingGoal>>(
      stream: _goalsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки данных'));
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final today = DateTime.now();
        final todayGoal = snapshot.data!.firstWhere(
          (goal) => isSameDay(goal.date, today),
          orElse: () => ReadingGoal(
            date: today,
            goalMinutes: 0,
            goalPages: 0,
            readMinutes: 0,
            readPages: 0,
          ),
        );

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Дневная цель",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPieChart(
                    todayGoal.readMinutes.toDouble(),
                    appState.readingMinutesPurpose.toDouble(),
                    "минут",
                  ),
                  _buildPieChart(
                    todayGoal.readPages.toDouble(),
                    appState.readingPagesPurpose.toDouble(),
                    "страниц",
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPieChart(double value, double total, String unit) {
    if (total <= 0) total = 1; // Чтобы избежать деления на ноль

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
                  PieData(value: total - value, color: AppColors.orangeLight),
                  PieData(value: value, color: AppColors.orange),
                ],
                borderEdge: StrokeCap.round,
                showValue: false,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          "из ${total.toStringAsFixed(0)} $unit",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartPol(double value, double total, String unit) {
    final double percentage = total > 0 ? (value / total) : 0.0;

    return Column(
      children: [
        SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            SemiCircleChart(progress: percentage),
            Text(
              value.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          "из ${total.toStringAsFixed(0)} $unit",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityDays() {
    return StreamBuilder<List<ReadingGoal>>(
      stream: _goalsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки календаря'));
        }

        final highlightedDates = snapshot.hasData
            ? snapshot.data!.map((goal) => goal.date).toSet()
            : <DateTime>{};

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Дни активности",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 10),
              TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) =>
                    highlightedDates.any((d) => isSameDay(d, day)),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
