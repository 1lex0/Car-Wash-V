import '../../../data/result.dart';
import '../models/bay_state.dart';
import '../models/wash_live_state.dart';
import 'iwash_repository.dart';

class MockIWashRepository implements IWashRepository {
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
