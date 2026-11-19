// Тестовые двойники: бывшие mock-и L4 переехали из lib/ в test/ (L5).
// В приложении их больше нет; тест сам собирает свой корень композиции.
import 'package:frontend/data/car_wash.dart';
import 'package:frontend/data/car_wash_repository.dart';
import 'package:frontend/data/result.dart';
import 'package:frontend/features/iwash/models/bay_state.dart';
import 'package:frontend/features/iwash/models/wash_live_state.dart';
import 'package:frontend/features/iwash/repositories/iwash_repository.dart';

const List<CarWash> fakeCarWashes = [
  CarWash(
    id: 1,
    name: 'Lux Wash',
    area: 'Centru',
    city: 'Chișinău',
    logoAsset: 'assets/logos/Lux-wash.png',
  ),
  CarWash(
    id: 2,
    name: 'E-Wash',
    area: 'Rîșcani',
    city: 'Chișinău',
    logoAsset: 'assets/logos/E-wash.png',
  ),
  CarWash(
    id: 3,
    name: 'I-Wash',
    area: 'Botanica',
    city: 'Chișinău',
    logoAsset: 'assets/logos/I-wash.png',
  ),
];

class FakeCarWashRepository implements CarWashRepository {
  final List<CarWash> _washes = List.of(fakeCarWashes);
  int _nextId = 1000;

  bool simulateError = false;

  static const _latency = Duration(milliseconds: 800);
  static const _errNetwork = 'Server is not responding — please try again';
  static const _errNotFound = 'Car wash does not exist';

  @override
  Future<Result<List<CarWash>>> fetchAll({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    final q = search?.toLowerCase() ?? '';
    final found = _washes.where(
      (w) =>
          w.name.toLowerCase().contains(q) || w.area.toLowerCase().contains(q),
    );
    return Ok(found.skip((page - 1) * limit).take(limit).toList());
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

class FakeIWashRepository implements IWashRepository {
  bool simulateError = false;

  static const _latency = Duration(milliseconds: 800);
  static const _errNetwork = 'Server is not responding — please try again';
  static const _errNoMap = 'Live map is not available for this car wash';

  static const _iWashId = 3;

  @override
  Future<Result<WashLiveState>> fetchLiveState(int washId) async {
    await Future.delayed(_latency);
    if (simulateError) return const Err(_errNetwork);
    if (washId != _iWashId) return const Err(_errNoMap);

    return Ok(
      WashLiveState(
        washId: 'iwash',
        timestamp: DateTime.now(),

        waitingCarsCount: 5,
        occupiedParkingSpots: const {1, 4, 6},
        bays: const [
          BayState(id: 1, occupied: false),
          BayState(id: 2, occupied: false),
          BayState(id: 3, occupied: true),
          BayState(id: 4, occupied: false),

          BayState(id: 5, occupied: false),
          BayState(id: 6, occupied: true),
          BayState(id: 7, occupied: false),

          BayState(id: 8, occupied: false),
          BayState(id: 9, occupied: false),
          BayState(id: 10, occupied: true),
          BayState(id: 11, occupied: false),
        ],
      ),
    );
  }
}
