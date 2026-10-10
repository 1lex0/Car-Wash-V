class BayState {
  final int id;
  final bool occupied;
  final String? vehicleId;

  const BayState({
    required this.id,
    required this.occupied,
    this.vehicleId,
  });

  factory BayState.fromJson(Map<String, dynamic> json) {
    return BayState(
      id: json['id'] as int,
      occupied: json['occupied'] as bool,
      vehicleId: json['vehicleId'] as String?,
    );
  }
}