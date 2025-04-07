import 'package:booktrack/models/userModels.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _userModel;

  UserModel? get userModel => _userModel;

  AuthProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      // Загрузите данные пользователя из Firestore или другого источника
      // Например:
      // DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      // _userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>, userId);
      // notifyListeners();
    }
  }

  Future<void> login(UserModel user) async {
    _userModel = user;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.uid);
    notifyListeners();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    _userModel = null;
    notifyListeners();
  }
}
