import 'package:booktrack/main.dart';
import 'package:booktrack/models/userModels.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/pages/LoginPAGES/DetailPainterBlobAuth.dart';
import 'package:booktrack/pages/LoginPAGES/RegistrPage.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  String _mail = '';
  String _phoneNumber = '';
  bool _usePassword = false;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkExistingAuth();
  }

  Future<void> _checkExistingAuth() async {
    final auth = Provider.of<AuthProviders>(context, listen: false);
    if (auth.userModel != null && mounted) {
      _redirectToHome();
    }
  }

  Future<void> _redirectToHome() async {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => BottomNavigationBarEX()),
      (route) => false,
    );
  }

  Future<void> _signInWithEmail() async {
    if (!_emailFormKey.currentState!.validate() || !mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user == null) return;

      // Загружаем данные из Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) throw Exception('User data not found');

      final auth = Provider.of<AuthProviders>(context, listen: false);
      await auth.login(UserModel(
        uid: userCredential.user!.uid,
        name: userDoc.data()?['name'] ?? 'No name',
        email: userCredential.user!.email ?? _emailController.text.trim(),
        phone: userDoc.data()?['phone'],
        selectedPaymentMethod: userDoc.data()?['selectedPaymentMethod'],
      ));

      // 4. Перенаправляем
      if (mounted) _redirectToHome();
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _getAuthErrorMessage(e.code));
    } catch (e) {
      setState(() => _errorMessage = 'Ошибка авторизации');
      debugPrint('Auth error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'invalid-email':
        return 'Некорректный email';
      default:
        return 'Ошибка авторизации';
    }
  }

  String? _validateEmail(String? value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(value ?? '') ? null : 'Некорректный email';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: AnimatedWaveScreenAuthWrap(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 135),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("images/logoRegist.svg"),
                TabBar(
                  dividerColor: Colors.white,
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Email'),
                    Tab(text: 'Телефон'),
                  ],
                  labelStyle:
                      TextStyle(fontFamily: 'MPLUSRounded1c', fontSize: 24),
                  indicatorColor: AppColors.background,
                  labelColor: AppColors.background,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildEmailAuthTab(),
                      _buildPhoneAuthTab(),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmailAuthTab() {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _emailFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Ваш Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(35.0),
                  borderSide: BorderSide(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(35.0),
                  borderSide: BorderSide(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(35.0),
                  borderSide: BorderSide(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
              ),
              validator: _validateEmail,
              onChanged: (mail) {
                setState(() {
                  _mail = mail;
                });
              },
            ),
            const SizedBox(height: 20),
            if (_usePassword) ...[
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35.0),
                    borderSide: BorderSide(
                      color: AppColors.background,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35.0),
                    borderSide: BorderSide(
                      color: AppColors.background,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35.0),
                    borderSide: BorderSide(
                      color: AppColors.background,
                      width: 2,
                    ),
                  ),
                ),
                obscureText: true,
                validator: (value) =>
                    value!.length > 5 ? null : 'Минимум 6 символов',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(
                    Size(
                      260 * scale.clamp(0.5, 2.0),
                      35 * scale.clamp(0.5, 2.0),
                    ),
                  ),
                  side: MaterialStateProperty.all(
                    const BorderSide(
                      color: AppColors.background,
                      width: 2,
                    ),
                  ),
                ),
                onPressed: _signInWithEmail,
                child: const Text('Войти',
                    style:
                        TextStyle(fontSize: 20, color: AppColors.textPrimary)),
              ),
            ] else ...[
              Builder(
                builder: (innerContext) {
                  return ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(
                        Size(
                          260 * scale.clamp(0.5, 2.0),
                          35 * scale.clamp(0.5, 2.0),
                        ),
                      ),
                      side: MaterialStateProperty.all(
                        const BorderSide(
                          color: AppColors.background,
                          width: 2,
                        ),
                      ),
                    ),
                    onPressed: () {},
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Получить код',
                            style: TextStyle(
                                fontSize: 20, color: AppColors.textPrimary)),
                  );
                },
              ),
            ],
            TextButton(
              onPressed: () {
                setState(() => _usePassword = !_usePassword);
              },
              child: Text(
                _usePassword ? 'Использовать код' : 'Использовать пароль',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => RegistrationScreen(
                            isEmail: false,
                          )),
                  (route) => false,
                );
              },
              child: Text(
                'Регистрироваться',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneAuthTab() {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _phoneFormKey,
        child: Column(
          children: [
            IntlPhoneField(
              controller: _phoneController,
              showCursor: false,
              invalidNumberMessage: " Номер слишком короткий",
              decoration: InputDecoration(
                labelText: 'Номер телефона',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(35.0),
                  borderSide: BorderSide(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(35.0),
                  borderSide: BorderSide(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(35.0),
                  borderSide: BorderSide(
                    color: AppColors.background,
                    width: 2,
                  ),
                ),
              ),
              initialCountryCode: 'RU',
              onChanged: (phone) {
                setState(() {
                  _phoneNumber = phone.completeNumber;
                });
              },
              validator: (phone) {
                final num = phone?.number ?? '';
                if (num == '') return 'Введите номер телефона';
                if (!RegExp(r'^[0-9]+$').hasMatch(num)) return 'Только цифры';
                if (num.length < 10) return 'Минимум 10 цифр';
                return null;
              },
              showCountryFlag: true,
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            if (_usePassword) ...[
              TextFormField(
                key: ValueKey(_usePassword),
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35.0),
                    borderSide: BorderSide(
                      color: AppColors.background,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35.0),
                    borderSide: BorderSide(
                      color: AppColors.background,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35.0),
                    borderSide: BorderSide(
                      color: AppColors.background,
                      width: 2,
                    ),
                  ),
                ),
                obscureText: true,
                validator: (value) =>
                    value!.length > 5 ? null : 'Минимум 6 символов',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(
                    Size(
                      260 * scale.clamp(0.5, 2.0),
                      35 * scale.clamp(0.5, 2.0),
                    ),
                  ),
                  side: MaterialStateProperty.all(
                    const BorderSide(
                      color: AppColors.background,
                      width: 2,
                    ),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Тестовый вход по паролю')),
                  );
                },
                child: const Text('Войти',
                    style:
                        TextStyle(fontSize: 20, color: AppColors.textPrimary)),
              ),
            ] else ...[
              ElevatedButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(
                    Size(
                      260 * scale.clamp(0.5, 2.0),
                      35 * scale.clamp(0.5, 2.0),
                    ),
                  ),
                  side: MaterialStateProperty.all(
                    const BorderSide(
                      color: AppColors.background,
                      width: 2,
                    ),
                  ),
                ),
                onPressed: () {},
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Получить код',
                        style: TextStyle(
                            fontSize: 20, color: AppColors.textPrimary)),
              ),
            ],
            SizedBox(height: 5 * scale),
            TextButton(
              onPressed: () {},
              child: Text(
                'Регистрироваться',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _usePassword = !_usePassword);
              },
              child: Text(
                _usePassword ? 'Использовать код' : 'Использовать пароль',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
