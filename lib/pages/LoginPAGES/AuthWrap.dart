import 'package:booktrack/main.dart';
import 'package:booktrack/pages/LoginPAGES/auth_enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:pinput/pinput.dart';
import 'dart:math';

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
  final _phoneController = PhoneController(null);
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isLoading = false;
  bool _isEmailAuth = true;
  bool _usePassword = false;
  String? _errorMessage;
  String? _generatedCode;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

  String _generate6DigitCode() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  Future<void> _sendSmsCode() async {
    if (!_phoneFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phone = _phoneController.value?.international ?? '';
      _generatedCode = _generate6DigitCode();

      debugPrint('Код подтверждения для $phone: $_generatedCode');

      await _showCodeVerificationScreen(phone);
    } catch (e) {
      setState(() => _errorMessage = 'Ошибка: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<VerificationStatus> _verifyCode(
      String phone, String enteredCode) async {
    try {
      if (enteredCode != _generatedCode) {
        return VerificationStatus.invalidCode;
      }

      final snapshot = await _firestore
          .collection('users')
          .where('phoneNumber ', isEqualTo: phone)
          .limit(1)
          .get();

      return snapshot.docs.isEmpty
          ? VerificationStatus.newUser
          : VerificationStatus.existingUser;
    } catch (e) {
      debugPrint('Ошибка верификации: $e');
      return VerificationStatus.error;
    }
  }
  // Future<void> _registerNewUser(String phone) async {
  //   try {
  //     await _firestore.collection('users').add({
  //       'phone': phone,
  //       'createdAt': FieldValue.serverTimestamp(),
  //     });
  //   } catch (e) {
  //     throw Exception('Не удалось зарегистрировать пользователя');
  //   }
  // }

  Future<void> _showCodeVerificationScreen(String phone) async {
    final status = await Navigator.push<VerificationStatus>(
      context,
      MaterialPageRoute(
        builder: (context) => CodeVerificationScreen(
          onCodeVerified: (code) => _verifyCode(phone, code),
          phoneNumber: phone,
          correctCode: _generatedCode.toString(),
        ),
      ),
    );

    if (status == VerificationStatus.existingUser) {
      // Вход
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => BottomNavigationBarEX()));
    } else if (status == VerificationStatus.newUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Новый номер')),
      );
    }
  }

  Future<void> _signInWithEmail() async {
    setState(() => _isLoading = true);
    try {
      final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (user.user != null) {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация/Вход')),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'По почте'),
              Tab(text: 'По телефону'),
            ],
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
    );
  }

  Widget _buildEmailAuthTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _emailFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  value?.contains('@') ?? false ? null : 'Некорректный email',
            ),
            const SizedBox(height: 20),
            if (_usePassword) ...[
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                validator: (value) =>
                    value!.length > 5 ? null : 'Минимум 6 символов',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signInWithEmail,
                child: const Text('Войти'),
              ),
            ] else ...[
              Builder(
                builder: (innerContext) {
                  return ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(innerContext).showSnackBar(
                        const SnackBar(
                            content: Text('Тестовая отправка кода на email')),
                      );
                    },
                    child: const Text('Получить код'),
                  );
                },
              ),
            ],
            TextButton(
              onPressed: () {
                setState(() => _usePassword = !_usePassword);
              },
              child: Text(
                  _usePassword ? 'Использовать код' : 'Использовать пароль'),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _phoneFormKey,
        child: Column(
          children: [
            PhoneFormField(
              controller: _phoneController,
              validator: PhoneValidator.validMobile(),
              defaultCountry: 'RU',
            ),
            const SizedBox(height: 20),
            if (_usePassword) ...[
              TextFormField(
                key: ValueKey(_usePassword),
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                validator: (value) =>
                    value!.length > 5 ? null : 'Минимум 6 символов',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Тестовый вход по паролю')),
                  );
                },
                child: const Text('Войти'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _sendSmsCode,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Получить код'),
              ),
            ],
            TextButton(
              onPressed: () {
                setState(() => _usePassword = !_usePassword);
              },
              child: Text(
                  _usePassword ? 'Использовать код' : 'Использовать пароль'),
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

class CodeVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String correctCode;
  final Future<VerificationStatus> Function(String) onCodeVerified;

  const CodeVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.correctCode,
    required this.onCodeVerified,
  });

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Подтверждение кода')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Введите 6-значный код, отправленный на ${widget.phoneNumber}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Pinput(
              length: 6,
              controller: _codeController,
              defaultPinTheme: PinTheme(
                width: 56,
                height: 56,
                textStyle:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      final enteredCode = _codeController.text;
                      if (enteredCode.length != 6) {
                        setState(() => _errorMessage = 'Введите 6 цифр');
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });

                      try {
                        final status = await widget.onCodeVerified(enteredCode);

                        switch (status) {
                          case VerificationStatus.existingUser:
                            Navigator.pop(context, status);
                            break;
                          case VerificationStatus.newUser:
                            Navigator.pop(context, status);
                            break;
                          case VerificationStatus.invalidCode:
                            setState(() => _errorMessage = 'Неверный код');
                            break;
                          case VerificationStatus.error:
                            setState(() => _errorMessage = 'Ошибка сервера');
                        }
                      } catch (e) {
                        setState(
                            () => _errorMessage = 'Ошибка: ${e.toString()}');
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Подтвердить'),
            ),
            const SizedBox(height: 20),
            Text('Тестовый код: ${widget.correctCode}',
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
