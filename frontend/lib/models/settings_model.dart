import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeChoice { light, dark, system }

enum TextSizeChoice { small, normal, large }

class SettingsModel extends ChangeNotifier {
  static const _prefix = 'settings_';

  String _vehicleModel = 'Toyota Corolla';
  String _vehiclePlate = 'ABC 123';
  AppThemeChoice _theme = AppThemeChoice.light;
  String _language = 'English';
  TextSizeChoice _textSize = TextSizeChoice.normal;
  bool _notifications = true;
  bool _location = false;
  bool _hideEmail = true;
  bool _shareUsage = false;

  String get vehicleModel => _vehicleModel;
  String get vehiclePlate => _vehiclePlate;
  AppThemeChoice get theme => _theme;
  String get language => _language;
  TextSizeChoice get textSize => _textSize;
  bool get notifications => _notifications;
  bool get location => _location;
  bool get hideEmail => _hideEmail;
  bool get shareUsage => _shareUsage;

  static const languages = ['English', 'Русский', 'Română'];

  double get textScale => switch (_textSize) {
    TextSizeChoice.small => 0.9,
    TextSizeChoice.normal => 1.0,
    TextSizeChoice.large => 1.15,
  };

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _vehicleModel = p.getString('${_prefix}vehicle_model') ?? _vehicleModel;
    _vehiclePlate = p.getString('${_prefix}vehicle_plate') ?? _vehiclePlate;
    _theme =
        AppThemeChoice.values.asNameMap()[p.getString('${_prefix}theme')] ??
        _theme;
    _language = p.getString('${_prefix}language') ?? _language;
    _textSize =
        TextSizeChoice.values.asNameMap()[p.getString('${_prefix}text_size')] ??
        _textSize;
    _notifications = p.getBool('${_prefix}notifications') ?? _notifications;
    _location = p.getBool('${_prefix}location') ?? _location;
    _hideEmail = p.getBool('${_prefix}hide_email') ?? _hideEmail;
    _shareUsage = p.getBool('${_prefix}share_usage') ?? _shareUsage;
    notifyListeners();
  }

  Future<void> _save(String key, Object value) async {
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    switch (value) {
      case String s:
        await p.setString('$_prefix$key', s);
      case bool b:
        await p.setBool('$_prefix$key', b);
    }
  }

  Future<void> setVehicleModel(String v) {
    _vehicleModel = v;
    return _save('vehicle_model', v);
  }

  Future<void> setVehiclePlate(String v) {
    _vehiclePlate = v;
    return _save('vehicle_plate', v);
  }

  Future<void> setTheme(AppThemeChoice v) {
    _theme = v;
    return _save('theme', v.name);
  }

  Future<void> setLanguage(String v) {
    _language = v;
    return _save('language', v);
  }

  Future<void> setTextSize(TextSizeChoice v) {
    _textSize = v;
    return _save('text_size', v.name);
  }

  Future<void> setNotifications(bool v) {
    _notifications = v;
    return _save('notifications', v);
  }

  Future<void> setLocation(bool v) {
    _location = v;
    return _save('location', v);
  }

  Future<void> setHideEmail(bool v) {
    _hideEmail = v;
    return _save('hide_email', v);
  }

  Future<void> setShareUsage(bool v) {
    _shareUsage = v;
    return _save('share_usage', v);
  }
}
