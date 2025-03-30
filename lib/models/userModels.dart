class UserModel {
  final String uid;
  final String? name;
  final String? subname;
  final String? email;
  final String? phone;
  final String? password;
  final DateTime? birthDate;
  final int totalBonuses;
  final int pagesReadTotal;
  final List<String> savedBooks;
  final List<String> readBooks;
  final List<String> subcollections;

  UserModel({
    required this.uid,
    this.name,
    this.subname,
    this.email,
    this.phone,
    this.password,
    this.birthDate,
    this.totalBonuses = 0,
    this.pagesReadTotal = 0,
    this.savedBooks = const [],
    this.readBooks = const [],
    this.subcollections = const [
      'reading_progress',
      'reading_goals',
      'quotes',
      'purchase_history',
      'payments',
      'levels',
      'bonus_history'
    ],
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'],
      subname: data['subname'],
      email: data['email'],
      phone: data['phone'],
      password: data['password'],
      birthDate: data['birthDate'] != null ? DateTime.parse(data['birthDate']) : null,
      totalBonuses: data['totalBonuses'] ?? 0,
      pagesReadTotal: data['pagesReadTotal'] ?? 0,
      savedBooks: List<String>.from(data['saved_books'] ?? []),
      readBooks: List<String>.from(data['read_books'] ?? []),
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
      'birthDate': birthDate?.toIso8601String(),
      'totalBonuses': totalBonuses,
      'pagesReadTotal': pagesReadTotal,
      'saved_books': savedBooks,
      'read_books': readBooks,
      'subcollections': subcollections,
    };
  }
}