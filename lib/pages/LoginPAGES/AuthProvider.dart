import 'package:booktrack/models/userModels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProviders with ChangeNotifier {
  UserModel? _userModel;
  bool _isLoading = true;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await loadUserData();
      }
    } catch (e) {
      debugPrint('Auth init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _userModel = null;
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data()!, doc.id);

        // Сохраняем ID для будущих запусков
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.uid);
      } else {
        await _clearUserData();
      }
    } catch (e) {
      debugPrint('Load user error: $e');
      await _clearUserData();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _clearUserData() async {
    _userModel = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  Future<void> login(UserModel user) async {
    _userModel = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.uid);
    notifyListeners();
  }

  Future<void> logout() async {
    await _clearUserData();
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }
}
