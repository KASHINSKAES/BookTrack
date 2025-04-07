import 'package:booktrack/main.dart';
import 'package:booktrack/pages/LoginPAGES/DetailPainterBlobAuth.dart';
import 'package:booktrack/pages/LoginPAGES/RegistrPage.dart';
import 'package:booktrack/pages/LoginPAGES/AuthEnums.dart';
import 'package:booktrack/pages/LoginPAGES/SmsCodePages.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _phoneNumber = '';
  String _mail = '';
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _usePassword = false;
  String? _errorMessage;
  String? _verificationId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkUserLoggedIn();
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

  Future<void> _checkUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      // Пользователь уже вошел в систему
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomNavigationBarEX()),
      );
    }
  }

  String? _validateEmail(String? value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(value ?? '') ? null : 'Некорректный email';
  }

  Future<void> _sendSmsCode() async {
    if (_phoneFormKey.currentState == null) return;

    if (_phoneFormKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _saveUserId();
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _errorMessage = 'Ошибка: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _showCodeVerificationScreen(_phoneNumber);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: Duration(
            seconds:
                60), // Установите таймаут для автоматического получения кода
      );
    } catch (e) {
      setState(() => _errorMessage = 'Ошибка: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMailCode() async {
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.sendSignInLinkToEmail(
        email: _mail,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://your-app.firebaseapp.com',
          handleCodeInApp: true,
        ),
      );
      _showCodeVerificationScreenMail(_mail);
    } catch (e) {
      setState(() => _errorMessage = 'Ошибка: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<VerificationStatus> _verifyCode(
      String phone, String enteredCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: enteredCode,
      );
      await _auth.signInWithCredential(credential);
      _saveUserId();
      return VerificationStatus.existingUser;
    } catch (e) {
      debugPrint('Ошибка верификации: $e');
      return VerificationStatus.invalidCode;
    }
  }

  Future<VerificationStatus> _verifyCodeMail(
      String mail, String enteredCode) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailLink(
        email: mail,
        emailLink: enteredCode,
      );
      if (userCredential.user != null) {
        _saveUserId();
        return VerificationStatus.existingUser;
      }
      return VerificationStatus.error;
    } catch (e) {
      debugPrint('Ошибка верификации: $e');
      return VerificationStatus.invalidCode;
    }
  }

  Future<void> _saveUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', _auth.currentUser!.uid);
  }

  Future<void> _showCodeVerificationScreen(String phone) async {
    final status = await Navigator.push<VerificationStatus>(
      context,
      MaterialPageRoute(
        builder: (context) => CodeVerificationScreen(
          onCodeVerified: (code) => _verifyCode(phone, code),
          phoneNumber: phone,
          isEmail: false,
        ),
      ),
    );

    if (status == VerificationStatus.existingUser) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomNavigationBarEX()),
      );
    } else if (status == VerificationStatus.newUser) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RegistrationScreen(
            phone: phone,
            isEmail: false,
          ),
        ),
      );
    }
  }

  Future<void> _showCodeVerificationScreenMail(String mail) async {
    final status = await Navigator.push<VerificationStatus>(
      context,
      MaterialPageRoute(
        builder: (context) => CodeVerificationScreen(
          onCodeVerified: (code) => _verifyCodeMail(mail, code),
          email: mail,
          isEmail: true,
        ),
      ),
    );

    if (status == VerificationStatus.existingUser) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomNavigationBarEX()),
      );
    } else if (status == VerificationStatus.newUser) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RegistrationScreen(
            email: mail,
            isEmail: true,
          ),
        ),
      );
    }
  }

  Future<void> _signInWithEmail() async {
    setState(() => _isLoading = true);
    try {
      final user = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (user.user != null) {
        _saveUserId();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BottomNavigationBarEX()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
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
                    onPressed: _sendMailCode,
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
                onPressed: _sendSmsCode,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Получить код',
                        style: TextStyle(
                            fontSize: 20, color: AppColors.textPrimary)),
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
