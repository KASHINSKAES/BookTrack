import 'dart:math';

import 'package:booktrack/MyFlutterIcons.dart';
import 'package:booktrack/icons.dart';
import 'package:booktrack/models/userModels.dart';
import 'package:booktrack/pages/Chat/roomsPages.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/pages/LoginPAGES/AuthWrap.dart';
import 'package:booktrack/pages/PaymentMethodsPage.dart';
import 'package:booktrack/pages/activityPages.dart';
import 'package:booktrack/pages/bonusPages.dart';
import 'package:booktrack/pages/languagePages.dart';
import 'package:booktrack/pages/level.dart';
import 'package:booktrack/pages/levelPage.dart';
import 'package:booktrack/pages/loveQuote.dart';
import 'package:booktrack/pages/statistikPages.dart';
import 'package:booktrack/widgets/blobPath.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userId;
  String? userName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateUserData();
  }

  void _updateUserData() {
    final authProvider = Provider.of<AuthProviders>(context, listen: true);
    final userModel = authProvider.userModel;

    if (userModel?.uid != userId) {
      // Проверяем, изменился ли пользователь
      setState(() {
        userId = userModel?.uid;
        userName = userModel?.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(userName);
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Material(
        color: Colors.transparent,
        child: Scaffold(
          extendBodyBehindAppBar:
              true, // Это ключевой параметр - позволяет контенту заходить под AppBar
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,

            scrolledUnderElevation: 0, // Убирает тень при скролле
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent, // Прозрачный статус-бар
              statusBarIconBrightness:
                  Brightness.dark, // Иконки статус-бара (темные/светлые)
              statusBarBrightness: Brightness.light,
            ),

            actions: [
              IconButton(
                icon: Icon(MyFlutter.setting,
                    color: Colors.black), // Явно задаем цвет иконки
                onPressed: () {
                  // Действие для настроек
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight),
            child: Container(
              color: AppColors.background,
              child: Stack(
                children: [
                  // Добавляем пятна (blobs)
                  Positioned(
                    top: 0,
                    left: -40 * scale,
                    child: BlobShape(
                      width: 200 * scale,
                      height: 200 * scale,
                      blobType: 'blob2',
                    ),
                  ),
                  Positioned(
                    top: 10 * scale,
                    left: 140 * scale,
                    child: BlobShape(
                      width: 200 * scale,
                      height: 200 * scale,
                      blobType: 'blob3',
                    ),
                  ),
                  Column(
                    children: [
                      _buildProfileHeader(scale),
                      _buildWhiteContainer(scale, context),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  // Верхний блок с аватаром
  Widget _buildProfileHeader(double scale) {
    final authProvider = context.watch<AuthProviders>();
    final user = authProvider.userModel;

    debugPrint("[ProfilePage] Current user: ${user?.name ?? 'null'}");
    return Consumer<AuthProviders>(builder: (context, authProvider, _) {
      final user = authProvider.userModel;
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              child: SvgPicture.asset(
                'images/logoProfile.svg',
                fit: BoxFit.cover,
              ),
            ),
            Text(
              user?.name ?? "No user",
              style: TextStyle(
                color: Colors.white,
                fontSize: 36 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    });
  }

  // Белый блок с закругленными углами
  Widget _buildWhiteContainer(double scale, BuildContext context) {
    final authProvider = Provider.of<AuthProviders>(context);
    final userModel = authProvider.userModel;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24 * scale),
          topRight: Radius.circular(24 * scale),
        ),
      ),
      padding: EdgeInsets.only(
          right: 23 * scale, left: 23 * scale, bottom: 18 * scale),
      child: Column(
        children: [
          _buildAchievementsSection(scale, context),
          _buildChatSection(scale, context),
          _buildSettingsSection(scale, context),
          SizedBox(height: scale * 20),
          TextButton(
              onPressed: () async {
                try {
                  await authProvider.logout();

                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => AuthScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  debugPrint('Ошибка при выходе: $e');
                }
              },
              child: Text(
                'Выйти',
                style: TextStyle(fontSize: 24 * scale, color: Colors.red),
              )),
        ],
      ),
    );
  }

  // Блок "Мои достижения"
  Widget _buildAchievementsSection(double scale, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.0 * scale),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 19 * scale),
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
        child: _buildSection(
          scale,
          "Мои достижения",
          [
            MenuItem(
              title: "Уровень",
              icon: MyFlutter.level,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LevelScreen(onBack: () {
                            Navigator.pop(context);
                          })),
                );
              },
              scale: scale,
            ),
            Divider(color: Color(0xffDCDCDC)),
            MenuItem(
              title: "Статистика",
              icon: MyFlutter.statistik,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StatisticsPage(onBack: () {
                            Navigator.pop(context);
                          })),
                );
              },
              scale: scale,
            ),
            Divider(color: Color(0xffDCDCDC)),
            MenuItem(
              title: "Трекер чтения",
              icon: MyFlutter.calendar,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ActivityPage(
                            onBack: () {
                              Navigator.pop(context);
                            },
                            userId: userId.toString(),
                          )),
                );
              },
              scale: scale,
            ),
            Divider(color: Color(0xffDCDCDC)),
            MenuItem(
              title: "История бонусов",
              icon: MyFlutter.bonus,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BonusHistoryPage(onBack: () {
                            Navigator.pop(context);
                          })),
                );
              },
              scale: scale,
            ),
            Divider(color: Color(0xffDCDCDC)),
            MenuItem(
              title: "Любимые цитаты",
              icon: MyFlutterApp.book2,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => loveQuotes(onBack: () {
                            Navigator.pop(context);
                          })),
                );
              },
              scale: scale,
            ),
          ],
        ),
      ),
    );
  }

  // Блок "Чат"
  Widget _buildChatSection(double scale, BuildContext context) {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final userModel = authProvider.userModel;
    return Padding(
      padding: EdgeInsets.only(top: 16.0 * scale),
      child: Container(
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
        child: MenuItem(
          title: "Чат",
          icon: MyFlutter.chatObsh,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RoomListPage(
                      onBack: () {
                        Navigator.pop(context);
                      },
                      currentUser: userModel!)),
            );
          },
          scale: scale,
        ),
      ),
    );
  }

  // Блок "Настройки"
  Widget _buildSettingsSection(double scale, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16 * scale),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 19 * scale),
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
        child: _buildSection(
          scale,
          "Настройки",
          [
            MenuItem2(
              title: "Способы оплаты",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PaymentMethodsPage(
                            onBack: () {
                              Navigator.pop(context);
                            },
                            scale: scale,
                          )),
                );
              },
              scale: scale,
            ),
            Divider(color: Color(0xffDCDCDC)),
            MenuItem2(
              title: "Язык интерфейса",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LanguageScreen(onBack: () {
                            Navigator.pop(context);
                          })),
                );
              },
              scale: scale,
              trailing: Text(
                "Русский",
                style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 14 * scale),
              ),
            ),
            Divider(color: Color(0xffDCDCDC)),
            MenuItem2(
              title: "Скачивать только по Wi-Fi",
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // Обработка переключателя
                },
              ),
              scale: scale,
            ),
          ],
        ),
      ),
    );
  }

  // Общий метод для создания секций
  Widget _buildSection(double scale, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: 14 * scale, horizontal: 19 * scale),
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

// Виджет для элементов меню с иконкой
class MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final double scale;

  const MenuItem({
    required this.title,
    required this.icon,
    this.onTap,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.textPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20 * scale,
        ),
      ),
      onTap: onTap,
    );
  }
}

// Виджет для элементов меню без иконки
class MenuItem2 extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final double scale;

  const MenuItem2({
    required this.title,
    this.onTap,
    this.trailing,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20 * scale,
        ),
      ),
      trailing: trailing ??
          Transform.rotate(
            angle: 180 * pi / 180,
            child: Icon(
              MyFlutterApp.back,
              color: AppColors.textPrimary,
            ),
          ),
      onTap: onTap,
    );
  }
}
