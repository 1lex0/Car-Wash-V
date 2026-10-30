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

  bool get isLoading => _loading;
  String? get error => _error;
  List<CarWash> get washes => List.unmodifiable(_washes);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    switch (await _repository.fetchAll()) {
      case Ok(:final value):
        _washes = value;
      case Err(:final msg):
        _error = msg;
    }

    _loading = false;
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
