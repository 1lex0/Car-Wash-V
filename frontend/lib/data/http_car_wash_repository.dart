import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'car_wash.dart';
import 'car_wash_repository.dart';
import 'result.dart';
import 'token_store.dart';

// Вторая реализация интерфейса L4: те же 5 методов, но по сети (C8).
class HttpCarWashRepository implements CarWashRepository {
  HttpCarWashRepository(this.baseUrl, this.tokens, {this.onUnauthorized});

  final String baseUrl;
  final TokenStore tokens;
  final void Function()? onUnauthorized; // решает корень: назад на login
  static const _timeout = Duration(seconds: 8);

  Future<Map<String, String>> _headers() async => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${await tokens.read() ?? ''}', // C8: Bearer
  };

  // 401 = пропуск умер: token выбрасывается (C9), корень навигирует.
  Future<String> _sessionDied() async {
    await tokens.clear();
    onUnauthorized?.call();
    return 'Сессия истекла — войдите снова';
  }

  // Слой 1 (дорога) и слой 3 (тело-сюрприз) — одинаковы для всех методов:
  // ловим по конкретным типам, а не общим catch (e).
  Future<Result<T>> _guard<T>(Future<Result<T>> Function() request) async {
    try {
      return await request();
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on http.ClientException {
      return const Err('Нет сети — повторите попытку'); // обрыв соединения
    } on FormatException {
      return const Err('Ответ не тот, что обещан'); // тело не JSON
    } on TypeError {
      return const Err('Ответ не тот, что обещан'); // JSON не той формы
    }
  }

  CarWash _wash(http.Response res) =>
      CarWash.fromJson(jsonDecode(res.body) as Map<String, dynamic>);

  @override
  Future<Result<List<CarWash>>> fetchAll({
    int page = 1,
    int limit = 20,
    String? search,
  }) => _guard(() async {
    // query params: Uri.replace сам кодирует кириллицу
    final uri = Uri.parse('$baseUrl/carwashes').replace(
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final res = await http
        .get(uri, headers: await _headers())
        .timeout(_timeout); // слой 1: без timeout запрос может висеть вечно
    if (res.statusCode == 401) return Err(await _sessionDied());
    if (res.statusCode != 200) return Err(apiMessage(res)); // слой 2
    final data = jsonDecode(res.body) as Map<String, dynamic>; // конверт!
    return Ok(
      (data['items'] as List)
          .map((e) => CarWash.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  });

  @override
  Future<Result<CarWash>> fetchById(int id) => _guard(() async {
    final res = await http
        .get(Uri.parse('$baseUrl/carwashes/$id'), headers: await _headers())
        .timeout(_timeout);
    if (res.statusCode == 401) return Err(await _sessionDied());
    // 404 не бросает: читается из статуса → «Запись не существует»
    if (res.statusCode != 200) return Err(apiMessage(res));
    return Ok(_wash(res));
  });

  @override
  Future<Result<CarWash>> create(CarWash wash) => _guard(() async {
    final res = await http
        .post(
          Uri.parse('$baseUrl/carwashes'),
          headers: await _headers(),
          body: jsonEncode(wash.toJson()), // без id: его выдаст сервер
        )
        .timeout(_timeout);
    if (res.statusCode == 401) return Err(await _sessionDied());
    if (res.statusCode != 201) return Err(apiMessage(res)); // хороший = 201
    return Ok(_wash(res)); // ответ с настоящим id
  });

  @override
  Future<Result<CarWash>> update(CarWash wash) => _guard(() async {
    final res = await http
        .put(
          Uri.parse('$baseUrl/carwashes/${wash.id}'),
          headers: await _headers(),
          body: jsonEncode(wash.toJson()),
        )
        .timeout(_timeout);
    if (res.statusCode == 401) return Err(await _sessionDied());
    if (res.statusCode != 200) return Err(apiMessage(res));
    return Ok(_wash(res));
  });

  @override
  Future<Result<void>> delete(int id) => _guard(() async {
    final res = await http
        .delete(Uri.parse('$baseUrl/carwashes/$id'), headers: await _headers())
        .timeout(_timeout);
    if (res.statusCode == 401) return Err(await _sessionDied());
    if (res.statusCode != 204) return Err(apiMessage(res)); // хороший = 204
    return const Ok(null); // тело пустое — БЕЗ jsonDecode (ловушка C8)
  });
}
