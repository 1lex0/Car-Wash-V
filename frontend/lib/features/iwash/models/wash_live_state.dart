import 'bay_state.dart';

class WashLiveState {
  final String washId;
  final DateTime timestamp;

  final int waitingCarsCount;

  /// Индексы занятых парковочных мест.
  /// Например {1, 4, 6}.
  final Set<int> occupiedParkingSpots;

  /// Состояние 11 боксов.
  final List<BayState> bays;

  const WashLiveState({
    required this.washId,
    required this.timestamp,
    required this.waitingCarsCount,
    required this.occupiedParkingSpots,
    required this.bays,
  });

  BayState? bayById(int id) {
    for (final bay in bays) {
      if (bay.id == id) {
        return bay;
      }
    }

    return null;
  }

  bool isBayOccupied(int id) {
    return bayById(id)?.occupied ?? false;
  }

  factory WashLiveState.fromJson(Map<String, dynamic> json) {
    final baysJson = json['bays'] as List<dynamic>? ?? [];

    final parkingJson =
        json['occupiedParkingSpots'] as List<dynamic>? ?? [];

    return WashLiveState(
      washId: json['washId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),

      waitingCarsCount:
          (json['waitingCarsCount'] as int).clamp(0, 10),

      occupiedParkingSpots:
          parkingJson.map((e) => e as int).toSet(),

      bays: baysJson
          .map(
            (e) => BayState.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}