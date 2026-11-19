import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../data/api_message.dart';
import '../../../data/result.dart';
import '../../../data/token_store.dart';
import '../models/wash_live_state.dart';
import 'iwash_repository.dart';

// Живая карта по сети: GET /carwashes/{id}/live — тот же скелет, что у моек.
class HttpIWashRepository implements IWashRepository {
  HttpIWashRepository(this.baseUrl, this.tokens, {this.onUnauthorized});

  final String baseUrl;
  final TokenStore tokens;
  final void Function()? onUnauthorized; // решает корень: назад на login
  static const _timeout = Duration(seconds: 8);

  @override
  Future<Result<WashLiveState>> fetchLiveState(int washId) async {
    try {
      final res = await http
          .get(
            Uri.parse('$baseUrl/carwashes/$washId/live'),
            headers: {'Authorization': 'Bearer ${await tokens.read() ?? ''}'},
          )
          .timeout(_timeout); // слой 1
      if (res.statusCode == 401) {
        await tokens.clear(); // мёртвый пропуск (C9)
        onUnauthorized?.call();
        return const Err('Сессия истекла — войдите снова');
      }
      if (res.statusCode != 200) return Err(apiMessage(res)); // слой 2: 404
      return Ok(
        WashLiveState.fromJson(jsonDecode(res.body) as Map<String, dynamic>),
      ); // fromJson был готов ещё с L2
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on http.ClientException {
      return const Err('Нет сети — повторите попытку');
    } on FormatException {
      return const Err('Ответ не тот, что обещан'); // слой 3
    } on TypeError {
      return const Err('Ответ не тот, что обещан'); // слой 3
    }
  }
}
