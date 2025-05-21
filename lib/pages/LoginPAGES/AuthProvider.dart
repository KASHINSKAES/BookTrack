import 'package:booktrack/models/userModels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProviders with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  AuthProviders() {
    // Следим за изменениями статуса аутентификации
    _auth.authStateChanges().listen(_updateUserFromFirebase);
  }

  Future<void> _updateUserFromFirebase(User? firebaseUser) async {
    if (firebaseUser == null) {
      _userModel = null;
      notifyListeners();
      return;
    }

    // Достаём дополнительные данные из Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (userDoc.exists) {
      _userModel = UserModel(
        uid: firebaseUser.uid,
        name: userDoc.data()?['name'] ?? 'No name',
        email: firebaseUser.email ?? userDoc.data()?['email'],
        phone: userDoc.data()?['phone'],
        selectedPaymentMethod: userDoc.data()?['selectedPaymentMethod'],
      );
      notifyListeners();
    }
  }

  Future<void> updateSelectedPaymentMethod(
      String? userId, String? cardId) async {
    if (userId == null) {
      _userModel = null;
      notifyListeners();
      return;
    }

    // Достаём дополнительные данные из Firestore
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      _userModel = UserModel(
        uid: userId,
        name: userDoc.data()?['name'] ?? 'No name',
        email: userDoc.data()?['email'] ?? 'No email',
        phone: userDoc.data()?['phone'],
        selectedPaymentMethod: cardId,
      );
      notifyListeners();
    }
  }

  Future<void> login(UserModel user) async {
    _userModel = user;
    notifyListeners();
  }

  void setUser(UserModel? user) {
    _userModel = user;
    debugPrint("[AuthProviders] User updated: ${user?.name ?? 'null'}"); // 🔥
    notifyListeners();
  }

  void clearUser() {
    _userModel = null;
    debugPrint("[AuthProviders] User cleared"); // 🔥
    notifyListeners();
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

  Future<void> logout() async {
    await _clearUserData();
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }
}
