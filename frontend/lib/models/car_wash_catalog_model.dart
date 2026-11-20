import 'package:flutter/foundation.dart';

import '../data/car_wash.dart';
import '../data/car_wash_repository.dart';
import '../data/result.dart';

class CarWashCatalogModel extends ChangeNotifier {
  CarWashCatalogModel(this._repository);

  final CarWashRepository _repository;

  bool _loading = false;
  String? _error;
  List<CarWash> _washes = const [];

  static const _limit = 20;
  String _search = '';
  int _page = 1;
  bool _hasMore = false;
  bool _loadingMore = false;

  bool get isLoading => _loading;
  String? get error => _error;
  List<CarWash> get washes => List.unmodifiable(_washes);
  String get search => _search;
  bool get hasMore => _hasMore;

  Future<void> load({String? search}) async {
    _search = search ?? _search;
    _page = 1;
    _loading = true;
    _error = null;
    notifyListeners();

    switch (await _repository.fetchAll(limit: _limit, search: _search)) {
      case Ok(:final value):
        _washes = value;
        _hasMore = value.length == _limit;
      case Err(:final msg):
        _error = msg;
        _hasMore = false;
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loadingMore || _loading || !_hasMore) return;
    _loadingMore = true;

    final result = await _repository.fetchAll(
      page: _page + 1,
      limit: _limit,
      search: _search,
    );
    switch (result) {
      case Ok(:final value):
        _page += 1;
        final known = {for (final w in _washes) w.id};
        _washes = [..._washes, ...value.where((w) => !known.contains(w.id))];
        _hasMore = value.length == _limit;
      case Err():
        _hasMore = false;
    }

    _loadingMore = false;
    notifyListeners();
  }

  Future<String?> add(CarWash draft) async {
    switch (await _repository.create(draft)) {
      case Ok(:final value):
        _washes = [..._washes, value];
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  Future<String?> update(CarWash wash) async {
    switch (await _repository.update(wash)) {
      case Ok(:final value):
        _washes = [for (final w in _washes) w.id == value.id ? value : w];
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  Future<String?> remove(int id) async {
    switch (await _repository.delete(id)) {
      case Ok():
        _washes = _washes.where((w) => w.id != id).toList();
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  CarWash? byId(int id) {
    for (final wash in _washes) {
      if (wash.id == id) return wash;
    }
    return null;
  }
}
