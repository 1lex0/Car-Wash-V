import 'package:flutter/foundation.dart';

import '../data/result.dart';
import '../features/iwash/models/wash_live_state.dart';
import '../features/iwash/repositories/iwash_repository.dart';

class IWashLiveModel extends ChangeNotifier {
  IWashLiveModel(this._repository);

  final IWashRepository _repository;

  bool _loading = false;
  String? _error;
  WashLiveState? _state;

  bool get isLoading => _loading;
  String? get error => _error;
  WashLiveState? get state => _state;

  Future<void> load(int washId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    switch (await _repository.fetchLiveState(washId)) {
      case Ok(:final value):
        _state = value;
      case Err(:final msg):
        _error = msg;
    }

    _loading = false;
    notifyListeners();
  }
}
