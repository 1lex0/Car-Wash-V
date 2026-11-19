import 'dart:convert';

import 'package:http/http.dart' as http;

// Переводит конверт ошибки {"error":{"code","message"}} в русский текст.
// Английский message сервера на экран не попадает — решаем по стабильному code.
String apiMessage(http.Response res) {
  try {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final error = body['error'] as Map<String, dynamic>;
    final code = error['code'] as String;
    return switch (code) {
      'VALIDATION_ERROR' => 'Отправленные данные недействительны',
      'UNAUTHORIZED' => 'Неверный email или пароль', // 401 на login
      'EMAIL_TAKEN' => 'Аккаунт с этим email уже существует',
      'NOT_FOUND' => 'Запись не существует',
      _ => 'Ошибка сервера ($code)',
    };
  } on FormatException {
    // тело не JSON (например, 500 с HTML от прокси)
    return 'Ошибка сервера (${res.statusCode})';
  } on TypeError {
    // JSON, но не по контракту (нет error/code или другой тип)
    return 'Ошибка сервера (${res.statusCode})';
  }
}
