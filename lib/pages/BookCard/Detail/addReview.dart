import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/servises/reviewsServises.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:booktrack/widgets/starRating.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddReviewPage extends StatefulWidget {
  final String bookId;
  
  final VoidCallback onBack;

  const AddReviewPage({Key? key, required this.bookId,required this.onBack}) : super(key: key);

  @override
  _AddReviewPageState createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  int _selectedRating = 0;
  final ReviewService _reviewService = ReviewService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAuth();
  }

  void _checkAuth() {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    if (authProvider.userModel == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        _showAuthWarning();
      });
    }
  }

  void _showAuthWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Только авторизованные пользователи могут оставлять отзывы'),
        action: SnackBarAction(
          label: 'Войти',
          onPressed: () => _navigateToAuth(),
        ),
      ),
    );
  }

  void _navigateToAuth() {
    // Реализуйте переход на экран авторизации
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    final authProvider = Provider.of<AuthProviders>(context);
    final user = authProvider.userModel;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Ошибка')),
        body: Center(child: Text('Требуется авторизация')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Добавить отзыв',
          style: TextStyle(
            fontSize: 32 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            size: 35 * scale,
            BookTrackIcon.onBack,
            color: AppColors.textPrimary,
          ),
          onPressed: widget.onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ваша оценка:',
                style: TextStyle(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              SizedBox(height: 8 * scale),
              StarRating(
                rating: _selectedRating.toDouble(),
                onRatingChanged: (rating) {
                  setState(() => _selectedRating = rating.toInt());
                },
              ),
              SizedBox(height: 24 * scale),
              TextFormField(
                controller: _reviewController,
                decoration: InputDecoration(
                  focusColor: AppColors.textPrimary,
                  labelText: 'Ваш отзыв',
                  labelStyle: TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.textPrimary, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.orange, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите текст отзыва';
                  }
                  if (_selectedRating == 0) {
                    return 'Пожалуйста, выберите оценку';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16 * scale),
              Center(
                child: ElevatedButton(
                  onPressed: _submitReview,
                  child: Text('Отправить отзыв',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 16 * scale)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final user = authProvider.userModel;
    if (user == null) return;

    try {
      final confirmed = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text('Подтверждение',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontSize: 30 * scale)),
              content: Text(
                  'После отправки отзыв нельзя будет изменить. Продолжить?',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontSize: 20 * scale)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Отмена',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 20 * scale)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Отправить',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 24 * scale)),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirmed) return;

      await _reviewService.addReview(
        bookId: widget.bookId,
        userId: user.uid,
        userName: user.name ?? 'Аноним',
        text: _reviewController.text,
        rating: _selectedRating,
      );

      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');

      String errorMessage = 'Ошибка при отправке отзыва';
      if (e.toString().contains('Книга не найдена')) {
        errorMessage = 'Книга не найдена';
      } else if (e.toString().contains('firestore/permission-denied')) {
        errorMessage = 'Нет прав для выполнения операции';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
