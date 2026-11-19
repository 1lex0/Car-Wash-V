// Собственный набор проверок контракта backend-а 2D Wash.
// Бьёт по серверу по HTTP, как это делает приложение, и для каждого
// запроса сравнивает статус и форму JSON с ожидаемыми.
//
// Запуск (сервер уже работает):
//   cd tools/contract_check
//   dart run bin/contract_check.dart --base-url http://localhost:8080

import 'dart:convert';
import 'dart:io';

late String base;
final client = HttpClient();
int passed = 0;
final failed = <String>[];

// ---------------------------------------------------------------- HTTP
// Ответ: статус + разобранное тело (null, если тело пустое, как у 204).
class Res {
  Res(this.status, this.raw);
  final int status;
  final String raw;
  dynamic get json => raw.isEmpty ? null : jsonDecode(raw);
}

Future<Res> call(String method, String path,
    {Object? body, String? token, Map<String, String>? query}) async {
  var uri = Uri.parse('$base$path');
  if (query != null) uri = uri.replace(queryParameters: query); // кодирует кириллицу
  final req = await client.openUrl(method, uri);
  if (token != null) req.headers.set('Authorization', 'Bearer $token');
  if (body != null) {
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(body));
  }
  final res = await req.close().timeout(const Duration(seconds: 8));
  return Res(res.statusCode, await res.transform(utf8.decoder).join());
}

// ---------------------------------------------------------------- проверки
// Одна проверка = одна строка ✓/✗. Падение внутри (не тот JSON) — тоже ✗.
Future<void> check(String name, Future<bool> Function() body) async {
  bool ok;
  String why = '';
  try {
    ok = await body();
  } catch (e) {
    ok = false;
    why = ' ($e)';
  }
  if (ok) {
    passed++;
    stdout.writeln('  ✓ $name');
  } else {
    failed.add(name);
    stdout.writeln('  ✗ $name$why');
  }
}

// Конверт ошибки: {"error":{"code":"...","message":"..."}} с нужным code.
bool isError(Res r, int status, String code) {
  if (r.status != status) return false;
  final e = (r.json as Map<String, dynamic>)['error'] as Map<String, dynamic>;
  return e['code'] == code && e['message'] is String;
}

// Пагинированный конверт: {items: [...], page, limit, total}.
bool isPage(Res r) {
  if (r.status != 200) return false;
  final j = r.json as Map<String, dynamic>;
  return j['items'] is List && j['page'] is int && j['limit'] is int && j['total'] is int;
}

// Все ли ключи есть в объекте (форма JSON).
bool hasKeys(Object? o, List<String> keys) =>
    o is Map<String, dynamic> && keys.every(o.containsKey);

List items(Res r) => (r.json as Map<String, dynamic>)['items'] as List;

void section(String title) => stdout.writeln('\n$title');

// ---------------------------------------------------------------- main
Future<void> main(List<String> args) async {
  final i = args.indexOf('--base-url');
  base = i >= 0 ? args[i + 1] : 'http://localhost:8080';
  stdout.writeln('Собственный набор проверок контракта → $base');

  // Уникальные email на каждый запуск: база может быть не пустой.
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final emailA = 'a$stamp@test.md', emailB = 'b$stamp@test.md';
  late String tokenA, tokenB;

  section('Сервер и auth');
  await check('GET /health → 200 {"status":"ok"}', () async {
    final r = await call('GET', '/health');
    return r.status == 200 && r.json['status'] == 'ok';
  });
  await check('POST /auth/register → 201 {token, user{id,email,name}}, без пароля', () async {
    final r = await call('POST', '/auth/register',
        body: {'email': emailA, 'password': 'parola123', 'name': 'Ana'});
    tokenA = r.json['token'] as String;
    return r.status == 201 &&
        hasKeys(r.json['user'], ['id', 'email', 'name']) &&
        !r.raw.contains('parola123') && // пароль никогда не возвращается
        !r.raw.contains('password');
  });
  await check('register тот же email → 409 EMAIL_TAKEN', () async {
    final r = await call('POST', '/auth/register',
        body: {'email': emailA, 'password': 'parola123', 'name': 'Ana'});
    return isError(r, 409, 'EMAIL_TAKEN');
  });
  await check('register без name → 400 VALIDATION_ERROR', () async {
    final r = await call('POST', '/auth/register',
        body: {'email': 'x$stamp@test.md', 'password': 'parola123'});
    return isError(r, 400, 'VALIDATION_ERROR');
  });
  await check('register с битым JSON → 400 VALIDATION_ERROR (не 500)', () async {
    final req = await client.postUrl(Uri.parse('$base/auth/register'));
    req.headers.contentType = ContentType.json;
    req.write('{"email": ');
    final res = await req.close();
    return isError(Res(res.statusCode, await res.transform(utf8.decoder).join()),
        400, 'VALIDATION_ERROR');
  });
  await check('POST /auth/login → 200 {token, user}', () async {
    final r = await call('POST', '/auth/login',
        body: {'email': emailA, 'password': 'parola123'});
    return r.status == 200 && r.json['token'] is String && hasKeys(r.json['user'], ['id']);
  });
  await check('login неверный пароль → 401 UNAUTHORIZED', () async {
    final r = await call('POST', '/auth/login',
        body: {'email': emailA, 'password': 'gresit'});
    return isError(r, 401, 'UNAUTHORIZED');
  });
  await check('GET /me с token-ом → 200 {id,email,name}', () async {
    final r = await call('GET', '/me', token: tokenA);
    return r.status == 200 && r.json['email'] == emailA;
  });
  // Второй пользователь — для проверок «чужая запись → 404».
  tokenB = (await call('POST', '/auth/register',
          body: {'email': emailB, 'password': 'parola123', 'name': 'Bob'}))
      .json['token'] as String;

  section('Без пропуска');
  for (final path in ['/notes', '/carwashes', '/carwashes/1/live']) {
    await check('GET $path без token-а → 401 UNAUTHORIZED', () async {
      return isError(await call('GET', path), 401, 'UNAUTHORIZED');
    });
  }
  await check('GET /carwashes с поддельным token-ом → 401', () async {
    return isError(await call('GET', '/carwashes', token: 'abc.def.ghi'), 401, 'UNAUTHORIZED');
  });
  await check('неизвестный маршрут → 404 NOT_FOUND в стандартном конверте', () async {
    return isError(await call('GET', '/nu-exista', token: tokenA), 404, 'NOT_FOUND');
  });

  // Один и тот же CRUD-сценарий для notes и для сущности темы carwashes.
  await crud(
    title: 'CRUD /notes (сущность-пример)',
    path: '/notes',
    tokenA: tokenA,
    tokenB: tokenB,
    valid: {'title': 'Покупки', 'content': 'молоко, хлеб'},
    invalid: {'title': '', 'content': 'x'},
    updated: {'title': 'Покупки на неделю', 'content': 'молоко'},
    keys: ['id', 'title', 'content', 'createdAt'],
    makeN: (n) => {'title': 'Заметка $n', 'content': ''},
    searchFor: 'Покуп',
  );
  final washId = await crud(
    title: 'CRUD /carwashes (сущность темы)',
    path: '/carwashes',
    tokenA: tokenA,
    tokenB: tokenB,
    valid: {'name': 'Мойка Ботаника', 'area': 'Botanica', 'city': 'Chișinău'},
    invalid: {'name': 'Lux', 'area': '', 'city': 'Chișinău'},
    updated: {'name': 'Мойка Ботаника 24/7', 'area': 'Botanica', 'city': 'Chișinău'},
    keys: ['id', 'name', 'area', 'city', 'logoAsset', 'createdAt'],
    makeN: (n) => {'name': 'Wash $n', 'area': 'Centru', 'city': 'Chișinău'},
    searchFor: 'Ботан',
  );

  section('Живая карта /carwashes/{id}/live (вторая сущность темы)');
  final live = {
    'waitingCarsCount': 3,
    'bayCount': 11,
    'occupiedBays': [2, 5],
    'occupiedParkingSpots': [1, 4],
  };
  await check('GET live до записи → 404 NOT_FOUND', () async {
    return isError(await call('GET', '/carwashes/$washId/live', token: tokenA), 404, 'NOT_FOUND');
  });
  await check('PUT live → 200 {washId,timestamp,waitingCarsCount,occupiedParkingSpots,bays}', () async {
    final r = await call('PUT', '/carwashes/$washId/live', token: tokenA, body: live);
    return r.status == 200 &&
        hasKeys(r.json, ['washId', 'timestamp', 'waitingCarsCount', 'occupiedParkingSpots', 'bays']) &&
        (r.json['bays'] as List).length == 11;
  });
  await check('GET live → 200, бокс 5 занят', () async {
    final r = await call('GET', '/carwashes/$washId/live', token: tokenA);
    final bay5 = (r.json['bays'] as List).firstWhere((b) => b['id'] == 5);
    return r.status == 200 && bay5['occupied'] == true;
  });
  await check('PUT live waitingCarsCount=99 → 400 VALIDATION_ERROR', () async {
    final r = await call('PUT', '/carwashes/$washId/live',
        token: tokenA, body: {...live, 'waitingCarsCount': 99});
    return isError(r, 400, 'VALIDATION_ERROR');
  });
  await check('GET live чужой мойки → 404 (не 403)', () async {
    return isError(await call('GET', '/carwashes/$washId/live', token: tokenB), 404, 'NOT_FOUND');
  });
  await check('DELETE live → 204 с пустым телом', () async {
    final r = await call('DELETE', '/carwashes/$washId/live', token: tokenA);
    return r.status == 204 && r.raw.isEmpty;
  });

  client.close();
  final total = passed + failed.length;
  stdout.writeln('');
  if (failed.isEmpty) {
    stdout.writeln('PASS — $passed/$total проверок пройдено');
  } else {
    stdout.writeln('FAIL — $passed/$total, не прошли: ${failed.length}');
    exitCode = 1;
  }
}

// CRUD-сценарий по образцу notes: 201 / 400 / 200 / 404 / чужая → 404 /
// пагинация / поиск (кириллица) / 204. Возвращает id созданной записи.
Future<int> crud({
  required String title,
  required String path,
  required String tokenA,
  required String tokenB,
  required Map<String, Object?> valid,
  required Map<String, Object?> invalid,
  required Map<String, Object?> updated,
  required List<String> keys,
  required Map<String, Object?> Function(int n) makeN,
  required String searchFor,
}) async {
  section(title);
  late int id;
  await check('POST $path → 201, id выдал сервер, форма JSON', () async {
    final r = await call('POST', path, token: tokenA, body: valid);
    id = r.json['id'] as int;
    return r.status == 201 && hasKeys(r.json, keys);
  });
  await check('POST $path с пустым обязательным полем → 400 VALIDATION_ERROR', () async {
    return isError(await call('POST', path, token: tokenA, body: invalid), 400, 'VALIDATION_ERROR');
  });
  await check('GET $path → 200 пагинированный конверт {items,page,limit,total}', () async {
    final r = await call('GET', path, token: tokenA);
    return isPage(r) && items(r).isNotEmpty && hasKeys(items(r).first, keys);
  });
  await check('GET $path/{id} → 200', () async {
    final r = await call('GET', '$path/$id', token: tokenA);
    return r.status == 200 && r.json['id'] == id;
  });
  await check('GET $path/999999 → 404 NOT_FOUND', () async {
    return isError(await call('GET', '$path/999999', token: tokenA), 404, 'NOT_FOUND');
  });
  await check('GET $path/{id} чужого пользователя → 404 (не 403)', () async {
    return isError(await call('GET', '$path/$id', token: tokenB), 404, 'NOT_FOUND');
  });
  await check('GET $path у другого пользователя → чужих записей нет в списке', () async {
    final r = await call('GET', path, token: tokenB);
    return isPage(r) && items(r).every((e) => e['id'] != id);
  });
  await check('PUT $path/{id} → 200, поля заменены', () async {
    final r = await call('PUT', '$path/$id', token: tokenA, body: updated);
    final field = updated.keys.first;
    return r.status == 200 && r.json[field] == updated[field];
  });
  await check('PUT $path/{id} невалидно → 400 VALIDATION_ERROR', () async {
    return isError(await call('PUT', '$path/$id', token: tokenA, body: invalid), 400, 'VALIDATION_ERROR');
  });
  await check('PUT $path/{id} чужого → 404', () async {
    return isError(await call('PUT', '$path/$id', token: tokenB, body: updated), 404, 'NOT_FOUND');
  });

  // Пагинация: ещё 4 записи → всего 5; limit=2 → страницы 2 + 2 + 1.
  for (var n = 1; n <= 4; n++) {
    await call('POST', path, token: tokenA, body: makeN(n));
  }
  await check('GET $path?page=1&limit=2 → 2 элемента, total=5', () async {
    final r = await call('GET', path, token: tokenA, query: {'page': '1', 'limit': '2'});
    return isPage(r) && items(r).length == 2 && r.json['total'] == 5 && r.json['limit'] == 2;
  });
  await check('GET $path?page=3&limit=2 → хвост из 1 элемента, page=3', () async {
    final r = await call('GET', path, token: tokenA, query: {'page': '3', 'limit': '2'});
    return isPage(r) && items(r).length == 1 && r.json['page'] == 3;
  });
  await check('страницы 1 и 2 не пересекаются', () async {
    final p1 = await call('GET', path, token: tokenA, query: {'page': '1', 'limit': '2'});
    final p2 = await call('GET', path, token: tokenA, query: {'page': '2', 'limit': '2'});
    final ids1 = items(p1).map((e) => e['id']).toSet();
    return items(p2).every((e) => !ids1.contains(e['id']));
  });
  await check('GET $path?search=$searchFor (кириллица) → ровно 1 элемент', () async {
    final r = await call('GET', path, token: tokenA, query: {'search': searchFor});
    return isPage(r) && items(r).length == 1 && items(r).first['id'] == id && r.json['total'] == 1;
  });
  await check('GET $path?search=нет-такого → пустой items, total=0', () async {
    final r = await call('GET', path, token: tokenA, query: {'search': 'нет-такого'});
    return isPage(r) && items(r).isEmpty && r.json['total'] == 0;
  });

  // Удаление проверяет вызывающий для carwashes после live, поэтому
  // удаляем отдельную запись, а созданная остаётся для live-проверок.
  final extra = await call('POST', path, token: tokenA, body: makeN(99));
  final extraId = extra.json['id'] as int;
  await check('DELETE $path/{id} чужого → 404', () async {
    return isError(await call('DELETE', '$path/$extraId', token: tokenB), 404, 'NOT_FOUND');
  });
  await check('DELETE $path/{id} → 204 с ПУСТЫМ телом', () async {
    final r = await call('DELETE', '$path/$extraId', token: tokenA);
    return r.status == 204 && r.raw.isEmpty;
  });
  await check('GET после DELETE → 404', () async {
    return isError(await call('GET', '$path/$extraId', token: tokenA), 404, 'NOT_FOUND');
  });
  return id;
}
