import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/car_wash.dart';
import 'package:frontend/data/http_car_wash_repository.dart';
import 'package:frontend/data/result.dart';
import 'package:frontend/data/token_store.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _wash = {
  'id': 7,
  'name': 'Lux Wash',
  'area': 'Centru',
  'city': 'Chișinău',
  'logoAsset': null,
  'createdAt': '2026-11-19T10:00:00Z',
};

String _error(String code) => jsonEncode({
  'error': {'code': code, 'message': 'english text'},
});

Future<T> _with<T>(
  Future<http.Response> Function(http.Request) handler,
  Future<T> Function() body,
) => http.runWithClient(body, () => MockClient(handler));

http.Response _json(Object body, int status) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  late TokenStore tokens;
  late HttpCarWashRepository repo;
  late int unauthorizedCalls;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'auth_token': 'tok123'});
    tokens = TokenStore();
    unauthorizedCalls = 0;
    repo = HttpCarWashRepository(
      'http://api',
      tokens,
      onUnauthorized: () => unauthorizedCalls++,
    );
  });

  test('fetchAll: Bearer в заголовке, items из конверта → Ok', () async {
    final result = await _with((req) async {
      expect(req.url.toString(), 'http://api/carwashes?page=1&limit=20');
      expect(req.headers['Authorization'], 'Bearer tok123');
      return _json({
        'items': [_wash],
        'page': 1,
        'limit': 20,
        'total': 1,
      }, 200);
    }, repo.fetchAll);
    expect((result as Ok<List<CarWash>>).value.single.name, 'Lux Wash');
  });

  test('create: тело без id, хороший статус 201, id даёт сервер', () async {
    final result = await _with(
      (req) async {
        final sent = jsonDecode(req.body) as Map<String, dynamic>;
        expect(req.method, 'POST');
        expect(sent.containsKey('id'), isFalse);
        return _json(_wash, 201);
      },
      () => repo.create(
        const CarWash(
          id: 0,
          name: 'Lux Wash',
          area: 'Centru',
          city: 'Chișinău',
        ),
      ),
    );
    expect((result as Ok<CarWash>).value.id, 7);
  });

  test('delete: 204 с пустым телом → Ok, без jsonDecode', () async {
    final result = await _with(
      (req) async => http.Response('', 204),
      () => repo.delete(7),
    );
    expect(result, isA<Ok<void>>());
  });

  test('fetchById: 404 → русское сообщение из конверта', () async {
    final result = await _with(
      (req) async => http.Response(_error('NOT_FOUND'), 404),
      () => repo.fetchById(99),
    );
    expect((result as Err).msg, 'Запись не существует');
  });

  test('create: 400 → «Отправленные данные недействительны»', () async {
    final result = await _with(
      (req) async => http.Response(_error('VALIDATION_ERROR'), 400),
      () => repo.create(const CarWash(id: 0, name: '', area: '', city: '')),
    );
    expect((result as Err).msg, 'Отправленные данные недействительны');
  });

  test('401: token стёрт из prefs + callback onUnauthorized', () async {
    final result = await _with(
      (req) async => http.Response(_error('UNAUTHORIZED'), 401),
      repo.fetchAll,
    );
    expect((result as Err).msg, 'Сессия истекла — войдите снова');
    expect(await tokens.read(), isNull);
    expect(unauthorizedCalls, 1);
  });

  test('500 с HTML (не JSON) → «Ошибка сервера (500)»', () async {
    final result = await _with(
      (req) async => http.Response('<html>oops</html>', 500),
      repo.fetchAll,
    );
    expect((result as Err).msg, 'Ошибка сервера (500)');
  });

  test(
    '200, но тело HTML → FormatException → «Ответ не тот, что обещан»',
    () async {
      final result = await _with(
        (req) async => http.Response('<html>proxy</html>', 200),
        repo.fetchAll,
      );
      expect((result as Err).msg, 'Ответ не тот, что обещан');
    },
  );

  test(
    '200, но JSON не той формы → TypeError → «Ответ не тот, что обещан»',
    () async {
      final result = await _with(
        (req) async => _json({'items': 'не список'}, 200),
        repo.fetchAll,
      );
      expect((result as Err).msg, 'Ответ не тот, что обещан');
    },
  );

  test('сервер недоступен (SocketException) → «Нет сети»', () async {
    final result = await _with(
      (req) async => throw const SocketException('Connection refused'),
      repo.fetchAll,
    );
    expect((result as Err).msg, 'Нет сети — повторите попытку');
  });

  test('сервер молчит → TimeoutException → «Сервер не отвечает»', () async {
    final result = await _with(
      (req) async => throw TimeoutException('slow'),
      repo.fetchAll,
    );
    expect((result as Err).msg, 'Сервер не отвечает');
  });
}
