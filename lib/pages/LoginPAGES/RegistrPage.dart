import 'package:booktrack/main.dart';
import 'package:booktrack/models/userModels.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/pages/LoginPAGES/DetailPainterBlobRegistr.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  final String? email;
  final String? phone;
  final bool isEmail;

  const RegistrationScreen({
    super.key,
    this.phone,
    this.email,
    required this.isEmail,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _subnameController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _prefillInitialData();
  }

  void _prefillInitialData() {
    if (widget.isEmail && widget.email != null) {
      _emailController.text = widget.email!;
    } else if (!widget.isEmail && widget.phone != null) {
      _phoneController.text = widget.phone!;
    }
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate() || !mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Регистрация в Firebase Auth
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user == null) throw Exception('User creation failed');

      // 2. Создание документа пользователя в Firestore
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid);

      final userData = {
        'id': userCredential.user!.uid,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'totalBonuses': 0,
        'pagesReadTotal': 0,
        'createdAt': FieldValue.serverTimestamp(),
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
      };

      await userDoc.set(userData);

      // 3. Обновление состояния в провайдере
      if (!mounted) return;
      final authProvider = Provider.of<AuthProviders>(context, listen: false);
      await authProvider.login(UserModel(
        uid: userCredential.user!.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
      ));

      // 4. Переход на главный экран с очисткой стека
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => BottomNavigationBarEX()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _getAuthErrorMessage(e.code));
    } catch (e) {
      setState(() => _errorMessage = 'Ошибка регистрации: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Этот email уже используется';
      case 'invalid-email':
        return 'Некорректный email';
      case 'weak-password':
        return 'Пароль слишком простой';
      default:
        return 'Ошибка регистрации';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(value ?? '') ? null : 'Некорректный email';
  }

  String? _validateRussianPhone(String? value) {
    final phoneRegex = RegExp(r'^(\+7|8)[0-9]{10}$');
    return phoneRegex.hasMatch(value ?? '')
        ? null
        : 'Некорректный номер телефона';
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Введите пароль';
    if (value.length < 6) return 'Минимум 6 символов';
    return null;
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
            child: AnimatedWaveScreenRegisthWrap(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 23 * scale,
              vertical: 125 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("images/AthLogo.svg"),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 23 * scale,
                    vertical: 23 * scale,
                  ),
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
                                borderRadius: BorderRadius.circular(35 * scale),
                                borderSide: BorderSide(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35 * scale),
                                borderSide: BorderSide(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35 * scale),
                                borderSide: BorderSide(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          TextFormField(
                            controller: _subnameController,
                            decoration: InputDecoration(
                              labelText: 'Фамилия',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35 * scale),
                                borderSide: BorderSide(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35 * scale),
                                borderSide: BorderSide(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35 * scale),
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
                            validator: _validateRussianPhone,
                            decoration: InputDecoration(
                              labelText: 'Номер телефона',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35 * scale),
                                borderSide: BorderSide(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35 * scale),
                                borderSide: BorderSide(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35 * scale),
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
                            validator: _validateEmail,
                            decoration: InputDecoration(
                              labelText: 'Email*',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35 * scale),
                                borderSide: BorderSide(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35 * scale),
                                borderSide: BorderSide(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35 * scale),
                                borderSide: BorderSide(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) => _formKey.currentState?.validate(),
                          ),
                          SizedBox(height: 30 * scale),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Пароль*',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35 * scale),
                                borderSide: BorderSide(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35 * scale),
                                borderSide: BorderSide(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(35 * scale),
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
                              onPressed: _registerUser,
                              child: Text(
                                'Зарегистрироваться',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
