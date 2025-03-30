import 'package:booktrack/auth_service.dart';
import 'package:booktrack/database_service.dart';
import 'package:booktrack/models/userModels.dart';
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
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _phoneController = PhoneController(null);
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isCodeSent = false;
  bool _isEmailAuth = true;
  bool _usePassword = false;
  String? _verificationId;
  String? _generatedCode;

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
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  String _generate6DigitCode() {
    final code = (100000 + Random().nextInt(900000)).toString();
    print('Сгенерирован код: $code');
    return code;
  }

  Future<void> _handleEmailSubmit() async {
    if (_formKey.currentState!.validate()) {
      _generatedCode = _generate6DigitCode();
      setState(() {
        _isCodeSent = true;
        _isEmailAuth = true;
        _usePassword = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Код отправлен на ${_emailController.text}')),
      );
      print('Тестовый код для email: $_generatedCode');
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CodeVerificationScreen(
                  email: _emailController.text,
                  generatedCode: _generatedCode.toString(),
                  isEmailAuth: true,
                  onCodeVerified: _onCodeVerified,
                )),
      );
    }
  }

  Future<void> _handlePhoneSubmit() async {
    if (_formKey.currentState!.validate() && _phoneController.value != null) {
      _generatedCode = _generate6DigitCode();
      setState(() {
        _isCodeSent = true;
        _isEmailAuth = false;
        _usePassword = false;
        _verificationId = 'mock_verification_id';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Код отправлен на ваш телефон: $_generatedCode')),
      );
      print('Тестовый код для телефона: $_generatedCode');
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CodeVerificationScreen(
                  phoneNumber: _phoneController.value!.international,
                  generatedCode: _generatedCode,
                  isEmailAuth: false,
                  onCodeVerified: _onCodeVerified,
                )),
      );
    }
  }

  Future<void> _signInWithPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = await AuthService().signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
      if (user != null) {
        await _checkUserExists(user.uid);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка входа: ${e.toString()}')),
      );
    }
  }

  Future<void> _checkUserExists(String? uid) async {
    if (uid == null) return;

    try {
      final exists = await DatabaseService().checkUserExists(uid);
      if (exists) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RegistrationScreen(
                    email: _emailController.text,
                    phoneNumber: _phoneController.value?.international,
                    onUserRegistered: _onUserRegistered,
                  )),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Ошибка проверки пользователя: ${e.toString()}')),
      );
    }
  }

  Future<void> _onCodeVerified(bool isValid) async {
    if (isValid) {
      await _checkUserExists(FirebaseAuth.instance.currentUser?.uid);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Неверный код подтверждения')),
      );
    }
  }

  Future<void> _onUserRegistered() async {
    Navigator.pushReplacementNamed(context, '/home');
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
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  value?.contains('@') ?? false ? null : 'Некорректный email',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _usePassword = !_usePassword);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(_usePassword
                        ? 'Использовать код'
                        : 'Использовать пароль'),
                  ),
                ),
              ],
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
                onPressed: _signInWithPassword,
                child: const Text('Войти'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _handleEmailSubmit,
                child: const Text('Получить код'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneAuthTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            PhoneFormField(
              controller: _phoneController,
              validator: PhoneValidator.validMobile(),
              defaultCountry: 'RU',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _usePassword = !_usePassword);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(_usePassword
                        ? 'Использовать код'
                        : 'Использовать пароль'),
                  ),
                ),
              ],
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
                onPressed: () {
                  _checkUserExists(FirebaseAuth.instance.currentUser?.uid);
                },
                child: const Text('Войти'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _handlePhoneSubmit,
                child: const Text('Получить код'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CodeVerificationScreen extends StatelessWidget {
  final String? email;
  final String? phoneNumber;
  final String? generatedCode;
  final bool isEmailAuth;
  final Function(bool) onCodeVerified;

  const CodeVerificationScreen({
    super.key,
    required this.generatedCode,
    required this.isEmailAuth,
    required this.onCodeVerified,
    this.email,
    this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    final _codeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Подтверждение кода')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Введите 6-значный код, отправленный на ${isEmailAuth ? email : phoneNumber}',
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final isValid = _verifyUserCode(
                    _codeController.text, generatedCode.toString());
                onCodeVerified(isValid);
              },
              child: const Text('Подтвердить'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Назад'),
            ),
            if (generatedCode != null)
              Text('Тестовый код: $generatedCode',
                  style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  bool _verifyUserCode(String inputCode, String generatedCode) {
    final isValid = inputCode == generatedCode;
    print(
        'Проверка кода: $inputCode, ожидаемый: $generatedCode, результат: $isValid');
    return isValid;
  }
}

class RegistrationScreen extends StatelessWidget {
  final String? email;
  final String? phoneNumber;
  final Function() onUserRegistered;

  const RegistrationScreen({
    super.key,
    required this.onUserRegistered,
    this.email,
    this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _surnameController = TextEditingController();
    final _passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Имя'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Введите имя' : null,
              ),
              TextFormField(
                controller: _surnameController,
                decoration: const InputDecoration(labelText: 'Фамилия'),
              ),
              if (email != null)
                TextFormField(
                  initialValue: email,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              if (phoneNumber != null)
                TextFormField(
                  initialValue: phoneNumber,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Телефон'),
                ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                validator: (value) =>
                    value!.length > 5 ? null : 'Минимум 6 символов',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final user = UserModel(
                        uid: FirebaseAuth.instance.currentUser?.uid ??
                            'new_user_${DateTime.now().millisecondsSinceEpoch}',
                        name: _nameController.text,
                        subname: _surnameController.text,
                        email: email,
                        phone: phoneNumber,
                        password: _passwordController.text,
                      );

                      await DatabaseService().createUser(user);
                      onUserRegistered();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка: ${e.toString()}')),
                      );
                    }
                  }
                },
                child: const Text('Зарегистрироваться'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
