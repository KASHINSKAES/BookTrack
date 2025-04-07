// auth_enums.dart
enum VerificationStatus {
  invalidCode,  // Неверный код
  newUser,      // Новый пользователь
  existingUser, // Существующий пользователь
  error         // Ошибка сервера
}