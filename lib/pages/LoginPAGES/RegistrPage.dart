import 'package:booktrack/main.dart';
import 'package:booktrack/pages/LoginPAGES/DetailPainterBlobRegistr.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';

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
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(alignment: Alignment.center, children: [
          Positioned.fill(
            child: AnimatedWaveScreenRegisthWrap(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 23 * scale, vertical: 125 * scale),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "images/AthLogo.svg",
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 23 * scale, vertical: 23 * scale),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Имя*',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(35 * scale),
                                  borderSide: BorderSide(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(35 * scale),
                                  borderSide: BorderSide(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(35 * scale),
                                  borderSide: BorderSide(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: _validateName,
                            ),
                            SizedBox(height: 30),
                            TextFormField(
                              controller: _subnameController,
                              decoration: InputDecoration(
                                labelText: 'Фамилия',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(35 * scale),
                                  borderSide: BorderSide(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(35 * scale),
                                  borderSide: BorderSide(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(35 * scale),
                                  borderSide: BorderSide(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30 * scale),
                            TextFormField(
                              controller: _phoneController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Номер телефона',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(35 * scale),
                                  borderSide: BorderSide(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(35 * scale),
                                  borderSide: BorderSide(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(35 * scale),
                                  borderSide: BorderSide(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30 * scale),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(35 * scale),
                                  borderSide: BorderSide(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(35 * scale),
                                  borderSide: BorderSide(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(35 * scale),
                                  borderSide: BorderSide(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (_) =>
                                  _formKey.currentState?.validate(),
                            ),
                            SizedBox(height: 30 * scale),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Пароль*',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(35 * scale),
                                  borderSide: BorderSide(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(35 * scale),
                                  borderSide: BorderSide(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(35 * scale),
                                  borderSide: BorderSide(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                              ),
                              obscureText: true,
                              validator: _validatePassword,
                            ),
                            SizedBox(height: 20 * scale),
                            if (_isLoading)
                              const CircularProgressIndicator()
                            else
                              ElevatedButton(
                                style: ButtonStyle(
                                  fixedSize: MaterialStateProperty.all(
                                    Size(
                                      260 *
                                          scale.clamp(
                                              0.5, 2.0), // Ограничиваем масштаб
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
                                onPressed: _registerUser,
                                child: Text('Зарегистрироваться',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: AppColors.textPrimary)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
          )
        ]));
  }
}
