// ignore: file_names

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class UserModel {
  String uid;
  String? name;
  String? subname;
  String? email;
  String? phone;
  String? password;
  String? selectedPaymentMethod;
  DateTime? birthDate;
  int totalBonuses;
  int pagesReadTotal;
  List<String> savedBooks;
  List<String> endBooks;
  List<String> readBooks;
  List<String> subcollections;

  String? get userId => uid;

  UserModel({
    required this.uid,
    this.name,
    this.subname,
    this.email,
    this.phone,
    this.password,
    this.selectedPaymentMethod,
    this.birthDate,
    this.totalBonuses = 0,
    this.pagesReadTotal = 0,
    this.savedBooks = const [],
    this.readBooks = const [],
    this.endBooks = const [],
    this.subcollections = const [
      'reading_progress',
      'reading_goals',
      'quotes',
      'purchase_history',
      'payments',
      'levels',
      'bonus_history'
    ],
    String? surname,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'],
      subname: data['subname'],
      email: data['email'],
      phone: data['phone'],
      password: data['password'],
      selectedPaymentMethod: data['selectedPaymentMethod'],
      birthDate:
          data['birthDate'] != null ? DateTime.parse(data['birthDate']) : null,
      totalBonuses: data['totalBonuses'] ?? 0,
      pagesReadTotal: data['pagesReadTotal'] ?? 0,
      savedBooks: List<String>.from(data['saved_books'] ?? []),
      readBooks: List<String>.from(data['read_books'] ?? []),
      endBooks: List<String>.from(data['read_books'] ?? []),
      subcollections: List<String>.from(data['subcollections'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'subname': subname,
      'email': email,
      'phone': phone,
      'password': password,
      'selectedPaymentMethod': selectedPaymentMethod,
      'birthDate': birthDate?.toIso8601String(),
      'totalBonuses': totalBonuses,
      'pagesReadTotal': pagesReadTotal,
      'saved_books': savedBooks,
      'end_books': endBooks,
      'read_books': readBooks,
      'subcollections': subcollections,
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['id'],
      name: data['name'],
    );
  }

  get displayName => null;

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'name': name,
      };
}

extension UserModelExtensions on UserModel {
  /// Конвертирует ваш UserModel в User для flutter_chat_ui
  types.User toChatUser() {
    return types.User(
      id: uid,
      firstName: name?.split(' ').first ?? 'Без имени',
      lastName: name!.split(' ').length > 1 ? name?.split(' ')[1] : '',
    );
  }
}
