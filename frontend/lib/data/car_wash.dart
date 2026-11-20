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

  factory CarWash.fromJson(Map<String, dynamic> j) => CarWash(
    id: j['id'] as int,
    name: j['name'] as String,
    area: j['area'] as String? ?? '',
    city: j['city'] as String? ?? '',
    logoAsset: j['logoAsset'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'area': area,
    'city': city,
    'logoAsset': logoAsset,
  };

  CarWash copyWith({int? id}) => CarWash(
    id: id ?? this.id,
    name: name,
    area: area,
    city: city,
    logoAsset: logoAsset,
  );
}
