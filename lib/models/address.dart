class Address {
  final int? id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final bool isHome;
  final bool isWork;
  final bool isCustom;

  Address({
    this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.isHome = false,
    this.isWork = false,
    this.isCustom = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      isHome: json['isHome'] ?? json['is_home'] ?? false,
      isWork: json['isWork'] ?? json['is_work'] ?? false,
      isCustom: json['isCustom'] ?? json['is_custom'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'is_home': isHome,
      'is_work': isWork,
      'is_custom': isCustom,
    };
  }

  Address copyWith({
    int? id,
    String? name,
    String? address,
    double? lat,
    double? lng,
    bool? isHome,
    bool? isWork,
    bool? isCustom,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isHome: isHome ?? this.isHome,
      isWork: isWork ?? this.isWork,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}