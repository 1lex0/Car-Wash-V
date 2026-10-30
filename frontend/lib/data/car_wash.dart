class CarWash {
  final int id;
  final String name;
  final String area;
  final String city;
  final String? logoAsset;

  const CarWash({
    required this.id,
    required this.name,
    required this.area,
    required this.city,
    this.logoAsset,
  });

  CarWash copyWith({int? id}) => CarWash(
    id: id ?? this.id,
    name: name,
    area: area,
    city: city,
    logoAsset: logoAsset,
  );
}
