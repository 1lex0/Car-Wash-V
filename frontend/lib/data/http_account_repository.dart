import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'account_repository.dart';
import 'api_message.dart';
import 'app_user.dart';
import 'result.dart';
import 'token_store.dart';

class HttpAccountRepository implements AccountRepository {
  HttpAccountRepository(this.baseUrl, this.tokens, {this.onUnauthorized});

  final String baseUrl;
  final TokenStore tokens;
  final void Function()? onUnauthorized;
  static const _timeout = Duration(seconds: 8);

  Future<Map<String, String>> _headers() async => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${await tokens.read() ?? ''}',
  };

  Future<String> _sessionDied() async {
    await tokens.clear();
    onUnauthorized?.call();
    return 'Сессия истекла — войдите снова';
  }

  Future<Result<T>> _guard<T>(Future<Result<T>> Function() request) async {
    try {
      return await request();
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on http.ClientException {
      return const Err('Нет сети — повторите попытку');
    } on FormatException {
      return const Err('Ответ не тот, что обещан');
    } on TypeError {
      return const Err('Ответ не тот, что обещан');
    }
  }

  AppUser _user(http.Response res) =>
      AppUser.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  @override
  Future<Result<AppUser>> fetchMe() => _guard(() async {
    final res = await http
        .get(Uri.parse('$baseUrl/me'), headers: await _headers())
        .timeout(_timeout);
    if (res.statusCode == 401) return Err(await _sessionDied());
    if (res.statusCode != 200) return Err(apiMessage(res));
    return Ok(_user(res));
  });

  @override
  Future<Result<AppUser>> updateMe({String? name, String? email}) =>
      _guard(() async {
        final res = await http
            .put(
              Uri.parse('$baseUrl/me'),
              headers: await _headers(),
              body: jsonEncode({'name': ?name, 'email': ?email}),
            )
            .timeout(_timeout);
        if (res.statusCode == 401) return Err(await _sessionDied());
        if (res.statusCode != 200) return Err(apiMessage(res));
        return Ok(_user(res));
      });

  @override
  Future<Result<void>> changePassword(
    String currentPassword,
    String newPassword,
  ) => _guard(() async {
    final res = await http
        .put(
          Uri.parse('$baseUrl/me/password'),
          headers: await _headers(),
          body: jsonEncode({
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          }),
        )
        .timeout(_timeout);
    if (res.statusCode == 401) return Err(await _sessionDied());
    if (res.statusCode != 204) return Err(apiMessage(res));
    return const Ok(null);
  });
}
