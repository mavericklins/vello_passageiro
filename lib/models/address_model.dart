class AddressModel {
  final String id;
  final String fullAddress;
  final String street;
  final String neighborhood;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String? placeType;
  
  AddressModel({
    required this.id,
    required this.fullAddress,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    this.placeType,
  });
  
  factory AddressModel.fromGeoapify(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;
    
    return AddressModel(
      id: feature['id'] ?? '',
      fullAddress: properties['formatted'] ?? '',
      street: properties['address_line1'] ?? properties['street'] ?? '',
      neighborhood: properties['district'] ?? properties['suburb'] ?? '',
      city: properties['city'] ?? '',
      state: properties['state'] ?? '',
      country: properties['country'] ?? 'Brasil',
      postalCode: properties['postcode'] ?? '',
      latitude: coordinates[1].toDouble(),
      longitude: coordinates[0].toDouble(),
      placeType: properties['category'] ?? properties['result_type'],
    );
  }
  
  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] ?? '',
      fullAddress: map['fullAddress'] ?? '',
      street: map['street'] ?? '',
      neighborhood: map['neighborhood'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? 'Brasil',
      postalCode: map['postalCode'] ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      placeType: map['placeType'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullAddress': fullAddress,
      'street': street,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'placeType': placeType,
    };
  }
  
  String get shortAddress {
    if (street.isNotEmpty && neighborhood.isNotEmpty) {
      return '$street, $neighborhood';
    } else if (street.isNotEmpty) {
      return street;
    } else if (neighborhood.isNotEmpty) {
      return '$neighborhood, $city';
    }
    return fullAddress;
  }
  
  String get displayName {
    List<String> parts = [];
    if (street.isNotEmpty) parts.add(street);
    if (neighborhood.isNotEmpty) parts.add(neighborhood);
    if (city.isNotEmpty) parts.add(city);
    
    return parts.join(', ');
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressModel &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }
  
  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
  
  @override
  String toString() => fullAddress;
}