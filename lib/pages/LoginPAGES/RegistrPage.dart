import 'package:booktrack/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  final String? phone;
  final String? email;
  final bool isEmail;

  const RegistrationScreen({
    super.key,
    this.phone,
    this.email,
    required this.isEmail,
  }); //

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Устанавливаем начальные значения
    if (widget.isEmail && widget.email != null) {
      _emailController.text = widget.email!;
    } else if (!widget.isEmail && widget.phone != null) {
      _phoneController.text = widget.phone!;
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите имя';
    }
    return null;
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Создаем документ в Firestore
      final userDoc = FirebaseFirestore.instance.collection('users').doc();

      final userData = {
        'id': userDoc.id,
        'name': _nameController.text,
        'phone': widget.phone, // Номер из предыдущего экрана
        'email':
            _emailController.text.isNotEmpty ? _emailController.text : null,
        'password': _passwordController
            .text, // ⚠️ В реальном приложении не храните пароль в Firestore!
        'subcollections': [
          'reading_progress',
          'reading_goals',
          'quotes',
          'purchase_history',
          'payments',
          'levels',
          'bonus_history',
        ],
        'saved_books': [],
        'read_books': [],
        'totalBonuses': 0,
        'pagesReadTotal': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await userDoc.set(userData);

      // 2. Переход на главный экран
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BottomNavigationBarEX()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка регистрации: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите пароль';
    }
    if (value.length < 6) {
      return 'Пароль должен содержать минимум 6 символов';
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Имя*'),
                  validator: _validateName,
                ),
                TextFormField(
                  controller: _subnameController,
                  decoration: const InputDecoration(labelText: 'Фамилия'),
                ),
                TextFormField(
                  controller: _phoneController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Номер телефона'),
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => _formKey.currentState?.validate(),
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Пароль*'),
                  obscureText: true,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _registerUser,
                    child: const Text('Зарегистрироваться'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
