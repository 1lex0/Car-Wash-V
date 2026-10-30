import 'package:flutter/foundation.dart';

class FavoritesModel extends ChangeNotifier {
  final List<int> _ids = [];

  List<int> get ids => List.unmodifiable(_ids);
  int get count => _ids.length;

  bool contains(int id) => _ids.contains(id);

  void add(int id) {
    if (!_ids.contains(id)) _ids.add(id);
    notifyListeners();
  }

  void remove(int id) {
    _ids.remove(id);
    notifyListeners();
  }

  void toggle(int id) {
    if (!_ids.remove(id)) _ids.add(id);
    notifyListeners();
  }
}
