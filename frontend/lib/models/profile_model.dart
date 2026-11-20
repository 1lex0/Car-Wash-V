import 'package:flutter/foundation.dart';

import '../data/account_repository.dart';
import '../data/app_user.dart';
import '../data/result.dart';

class ProfileModel extends ChangeNotifier {
  ProfileModel(this._repository);

  final AccountRepository _repository;

  bool _loading = false;
  String? _error;
  AppUser? _user;

  bool get isLoading => _loading;
  String? get error => _error;
  AppUser? get user => _user;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    switch (await _repository.fetchMe()) {
      case Ok(:final value):
        _user = value;
      case Err(:final msg):
        _error = msg;
    }

    _loading = false;
    notifyListeners();
  }

  Future<String?> updateName(String name) => _update(name: name);

  Future<String?> updateEmail(String email) => _update(email: email);

  Future<String?> _update({String? name, String? email}) async {
    switch (await _repository.updateMe(name: name, email: email)) {
      case Ok(:final value):
        _user = value;
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  Future<String?> changePassword(String current, String next) async {
    switch (await _repository.changePassword(current, next)) {
      case Ok():
        return null;
      case Err(:final msg):
        return msg;
    }
  }
}
