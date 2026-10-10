import '../models/bay_state.dart';
import '../models/wash_live_state.dart';

class IWashRepository {
  const IWashRepository();

  WashLiveState getCurrentState() {
    return WashLiveState(
      washId: 'iwash',
      timestamp: DateTime.now(),

      // Сейчас временное значение.
      // Позже оно будет приходить из .NET API / YOLO.
      waitingCarsCount: 5,

      // Временно занятые парковочные места.
      occupiedParkingSpots: const {
        1,
        4,
        6,
      },

      // Временное состояние боксов.
      // Потом эти значения придут из backend JSON.
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
    );
  }
}