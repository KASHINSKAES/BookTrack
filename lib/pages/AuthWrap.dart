import 'package:booktrack/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';
import 'dart:math';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.hasData ? BottomNavigationBarEX() : AuthWrapperLogin();
      },
    );
  }
}

class AuthWrapperLogin extends StatefulWidget {
  @override
  _AuthWrapperLoginState createState() => _AuthWrapperLoginState();
}

class _AuthWrapperLoginState extends State<AuthWrapperLogin> {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isEmail = true;
  bool _codeSent = false;
  String _generatedCode = '';
  bool _isLoading = false;

  String _generate6DigitCode() =>
      (100000 + Random().nextInt(900000)).toString();

  Future<void> _sendVerificationCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _generatedCode = _generate6DigitCode();
      final contact = _contactController.text.trim();

      try {
        if (_isEmail) {
          // Для email используем Firebase Auth
          await _sendEmailCode(contact);
        } else {
          // Для телефона - кастомная реализация
          await _sendSmsCode(contact);
        }
        setState(() {
          _codeSent = true;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sendEmailCode(String email) async {
    // Сохраняем код в Firestore
    await FirebaseFirestore.instance
        .collection('verification_codes')
        .doc(email)
        .set({
      'code': _generatedCode,
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'email'
    });

    // В реальном приложении здесь должен быть вызов Cloud Function для отправки email
    debugPrint('Email code for $email: $_generatedCode');
  }

  Future<void> _sendSmsCode(String phone) async {
    // Сохраняем код в Firestore
    await FirebaseFirestore.instance
        .collection('verification_codes')
        .doc(phone)
        .set({
      'code': _generatedCode,
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'phone'
    });

    // В реальном приложении здесь должен быть вызов SMS API
    debugPrint('SMS code for $phone: $_generatedCode');
  }

  Future<void> _verifyCode() async {
    setState(() => _isLoading = true);
    final contact = _contactController.text.trim();
    final code = _codeController.text.trim();

    try {
      if (_isEmail) {
        await _verifyEmailCode(contact, code);
      } else {
        await _verifyPhoneCode(contact, code);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.message ?? "Неверный код"}')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Произошла ошибка. Пожалуйста, попробуйте позже.')),
      );
      debugPrint('Ошибка при проверке кода: $e');
    }
  }

  Future<void> _verifyEmailCode(String email, String code) async {
    // Проверяем код с добавлением времени жизни
    final doc = await FirebaseFirestore.instance
        .collection('verification_codes')
        .doc(email)
        .get();

    if (!doc.exists) {
      throw FirebaseAuthException(
          code: 'invalid-code', message: 'Код не найден');
    }

    // Проверяем срок действия кода (5 минут)
    final createdAt = doc['createdAt'] as Timestamp;
    if (DateTime.now().difference(createdAt.toDate()).inMinutes > 5) {
      throw FirebaseAuthException(
          code: 'expired-code', message: 'Срок действия кода истёк');
    }

    if (doc['code'] != code) {
      throw FirebaseAuthException(
          code: 'invalid-code', message: 'Неверный код');
    }

    // Проверяем существование пользователя
    final userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userQuery.docs.isNotEmpty) {
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: 'temp_${code}');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // Если пользователь не найден, переходим к регистрации
          await RegistrationScreen(
            email: email,
            phone: null,
          );
        } else {
          rethrow;
        }
      }
    } else {
      await RegistrationScreen(
        email: email,
        phone: null,
      );
    }
  }

  Future<void> _verifyPhoneCode(String phone, String code) async {
    try {
      // 1. Проверяем доступ к Firestore
      final doc = await FirebaseFirestore.instance
          .collection('verification_codes')
          .doc(phone)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!doc.exists) {
        throw FirebaseAuthException(
          code: 'code-not-found',
          message: 'Код не найден. Запросите новый код.',
        );
      }

      // 2. Проверяем срок действия (5 минут)
      final createdAt = (doc['createdAt'] as Timestamp).toDate();
      if (DateTime.now().difference(createdAt).inMinutes > 5) {
        throw FirebaseAuthException(
          code: 'code-expired',
          message: 'Срок действия кода истёк. Запросите новый.',
        );
      }

      // 3. Сравниваем коды
      if (doc['code'] != code) {
        throw FirebaseAuthException(
          code: 'invalid-code',
          message: 'Неверный код подтверждения',
        );
      }

      // 4. Проверяем существование пользователя
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        // Вход через анонимную аутентификацию
        await FirebaseAuth.instance.signInAnonymously();
      } else {
        // Регистрация нового пользователя
        await RegistrationScreen(
          email: null,
          phone: phone,
        );
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        // Специальная обработка ошибки доступа
        throw FirebaseAuthException(
          code: 'permission-error',
          message: 'Ошибка доступа. Попробуйте позже.',
        );
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _codeSent
                ? _buildCodeVerification()
                : _buildContactInput(),
      ),
    );
  }

  Widget _buildContactInput() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _contactController,
            decoration: InputDecoration(
              labelText: _isEmail ? 'Email' : 'Номер телефона',
              hintText: _isEmail ? 'example@mail.com' : '+71234567890',
            ),
            keyboardType:
                _isEmail ? TextInputType.emailAddress : TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _isEmail ? 'Введите email' : 'Введите номер телефона';
              }
              if (_isEmail &&
                  !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                return 'Введите корректный email';
              }
              if (!_isEmail && !RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                return 'Введите корректный номер телефона';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Text(_isEmail
                  ? 'Использовать номер телефона'
                  : 'Использовать email'),
              Switch(
                value: _isEmail,
                onChanged: (value) {
                  setState(() {
                    _isEmail = value;
                    _contactController.clear();
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _sendVerificationCode,
            child: Text('Получить код'),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeVerification() {
    return Column(
      children: [
        Text(
            'Введите 6-значный код, отправленный на ${_isEmail ? _contactController.text : "ваш телефон"}'),
        SizedBox(height: 20),
        Pinput(
          length: 6,
          controller: _codeController,
          defaultPinTheme: PinTheme(
            width: 56,
            height: 56,
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _verifyCode,
          child: Text('Подтвердить'),
        ),
        TextButton(
          onPressed: () => setState(() => _codeSent = false),
          child: Text('Изменить ${_isEmail ? 'email' : 'номер телефона'}'),
        ),
      ],
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  final String? email;
  final String? phone;

  const RegistrationScreen({this.email, this.phone, Key? key})
      : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _completeRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final userData = {
          'name': _nameController.text.trim(),
          'surname': _surnameController.text.trim(),
          if (widget.email != null) 'email': widget.email,
          if (widget.phone != null) 'phone': widget.phone,
          'createdAt': FieldValue.serverTimestamp(),
          // Другие поля по умолчанию
        };

        if (widget.email != null) {
          // Создаем пользователя через email/password
          final credential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: widget.email!,
                  password:
                      'temp_${DateTime.now().millisecondsSinceEpoch}' // Временный пароль
                  );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.user!.uid)
              .set(userData);
        } else {
          // Для телефона - анонимная аутентификация
          final credential = await FirebaseAuth.instance.signInAnonymously();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.user!.uid)
              .set(userData);
        }

        // Переход в приложение
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigationBarEX()),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка регистрации: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(widget.email != null
                  ? 'Регистрация для ${widget.email}'
                  : 'Регистрация для ${widget.phone}'),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Имя'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите имя';
                  return null;
                },
              ),
              TextFormField(
                controller: _surnameController,
                decoration: InputDecoration(labelText: 'Фамилия'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите фамилию';
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _completeRegistration,
                      child: Text('Завершить регистрацию'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
