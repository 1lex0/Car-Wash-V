import 'car_wash.dart';
import 'car_wash_repository.dart';
import 'mock_car_washes.dart';
import 'result.dart';

class MockCarWashRepository implements CarWashRepository {
  final List<CarWash> _washes = List.of(mockCarWashes);
  int _nextId = 1000;

  bool simulateError = false;

  static const _latency = Duration(milliseconds: 800);
  static const _errNetwork = 'Server is not responding — please try again';
  static const _errNotFound = 'Car wash does not exist';

  @override
  Future<Result<List<CarWash>>> fetchAll() async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    return Ok(List.of(_washes));
  }

  @override
  Future<Result<CarWash>> fetchById(int id) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final index = _washes.indexWhere((w) => w.id == id);
    if (index == -1) return const Err(_errNotFound);
    return Ok(_washes[index]);
  }

  @override
  Future<Result<CarWash>> create(CarWash wash) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final created = wash.copyWith(id: _nextId++);
    _washes.add(created);
    return Ok(created);
  }

  @override
  Future<Result<CarWash>> update(CarWash wash) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final index = _washes.indexWhere((w) => w.id == wash.id);
    if (index == -1) return const Err(_errNotFound);
    _washes[index] = wash;
    return Ok(wash);
  }

  @override
  Future<Result<void>> delete(int id) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final index = _washes.indexWhere((w) => w.id == id);
    if (index == -1) return const Err(_errNotFound);
    _washes.removeAt(index);
    return const Ok(null);
  }
}
