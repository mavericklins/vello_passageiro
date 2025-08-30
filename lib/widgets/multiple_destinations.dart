import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

/// Modelo para um destino individual
class Destination {
  final String id;
  final String address;
  final double lat;
  final double lng;
  final int order; // Ordem na rota (0 = origem, 1 = primeira parada, etc.)
  final DestinationType type;
  final String? notes; // Observações opcionais
  final Duration? estimatedStayTime; // Tempo estimado de parada

  Destination({
    required this.id,
    required this.address,
    required this.lat,
    required this.lng,
    required this.order,
    required this.type,
    this.notes,
    this.estimatedStayTime,
  });

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'] ?? '',
      address: map['address'] ?? '',
      lat: (map['lat'] ?? 0.0).toDouble(),
      lng: (map['lng'] ?? 0.0).toDouble(),
      order: map['order'] ?? 0,
      type: DestinationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DestinationType.stop,
      ),
      notes: map['notes'],
      estimatedStayTime: map['estimatedStayTime'] != null 
          ? Duration(minutes: map['estimatedStayTime']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'address': address,
      'lat': lat,
      'lng': lng,
      'order': order,
      'type': type.name,
      'notes': notes,
      'estimatedStayTime': estimatedStayTime?.inMinutes,
    };
  }

  LatLng toLatLng() => LatLng(lat, lng);

  Destination copyWith({
    String? id,
    String? address,
    double? lat,
    double? lng,
    int? order,
    DestinationType? type,
    String? notes,
    Duration? estimatedStayTime,
  }) {
    return Destination(
      id: id ?? this.id,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      order: order ?? this.order,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      estimatedStayTime: estimatedStayTime ?? this.estimatedStayTime,
    );
  }
}

/// Tipos de destino
enum DestinationType {
  origin,     // Ponto de origem
  stop,       // Parada intermediária
  destination // Destino final
}

extension DestinationTypeExtension on DestinationType {
  String get displayName {
    switch (this) {
      case DestinationType.origin:
        return 'Origem';
      case DestinationType.stop:
        return 'Parada';
      case DestinationType.destination:
        return 'Destino';
    }
  }

  String get icon {
    switch (this) {
      case DestinationType.origin:
        return '🏠';
      case DestinationType.stop:
        return '📍';
      case DestinationType.destination:
        return '🎯';
    }
  }
}

/// Modelo para rota com múltiplos destinos
class MultipleDestinationsRoute {
  final String id;
  final List<Destination> destinations;
  final double totalDistance; // em metros
  final Duration totalDuration; // tempo total estimado
  final double estimatedPrice; // preço estimado total
  final List<RouteSegment> segments; // segmentos da rota
  final DateTime createdAt;
  final DateTime? updatedAt;

  MultipleDestinationsRoute({
    required this.id,
    required this.destinations,
    required this.totalDistance,
    required this.totalDuration,
    required this.estimatedPrice,
    required this.segments,
    required this.createdAt,
    this.updatedAt,
  });

  factory MultipleDestinationsRoute.fromMap(Map<String, dynamic> map) {
    return MultipleDestinationsRoute(
      id: map['id'] ?? '',
      destinations: (map['destinations'] as List<dynamic>?)
              ?.map((dest) => Destination.fromMap(dest))
              .toList() ??
          [],
      totalDistance: (map['totalDistance'] ?? 0.0).toDouble(),
      totalDuration: Duration(seconds: map['totalDuration'] ?? 0),
      estimatedPrice: (map['estimatedPrice'] ?? 0.0).toDouble(),
      segments: (map['segments'] as List<dynamic>?)
              ?.map((seg) => RouteSegment.fromMap(seg))
              .toList() ??
          [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'destinations': destinations.map((dest) => dest.toMap()).toList(),
      'totalDistance': totalDistance,
      'totalDuration': totalDuration.inSeconds,
      'estimatedPrice': estimatedPrice,
      'segments': segments.map((seg) => seg.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Obter origem da rota
  Destination? get origin => destinations
      .where((dest) => dest.type == DestinationType.origin)
      .isNotEmpty
      ? destinations.firstWhere((dest) => dest.type == DestinationType.origin)
      : null;

  /// Obter destino final da rota
  Destination? get finalDestination => destinations
      .where((dest) => dest.type == DestinationType.destination)
      .isNotEmpty
      ? destinations.firstWhere((dest) => dest.type == DestinationType.destination)
      : null;

  /// Obter paradas intermediárias
  List<Destination> get stops => destinations
      .where((dest) => dest.type == DestinationType.stop)
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));

  /// Obter destinos ordenados
  List<Destination> get orderedDestinations {
    final sorted = List<Destination>.from(destinations);
    sorted.sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }

  /// Verificar se a rota tem paradas intermediárias
  bool get hasStops => stops.isNotEmpty;

  /// Obter número total de paradas (incluindo origem e destino)
  int get totalStops => destinations.length;

  /// Obter preço formatado
  String get formattedPrice => 'R\$ ${estimatedPrice.toStringAsFixed(2).replaceAll('.', ',')}';

  /// Obter duração formatada
  String get formattedDuration {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  /// Obter distância formatada
  String get formattedDistance {
    if (totalDistance >= 1000) {
      return '${(totalDistance / 1000).toStringAsFixed(1)} km';
    } else {
      return '${totalDistance.toInt()} m';
    }
  }
}

/// Modelo para segmento de rota entre dois pontos
class RouteSegment {
  final String fromDestinationId;
  final String toDestinationId;
  final double distance; // em metros
  final Duration duration; // tempo estimado
  final double price; // preço deste segmento
  final List<LatLng>? polylinePoints; // pontos da rota (opcional)

  RouteSegment({
    required this.fromDestinationId,
    required this.toDestinationId,
    required this.distance,
    required this.duration,
    required this.price,
    this.polylinePoints,
  });

  factory RouteSegment.fromMap(Map<String, dynamic> map) {
    return RouteSegment(
      fromDestinationId: map['fromDestinationId'] ?? '',
      toDestinationId: map['toDestinationId'] ?? '',
      distance: (map['distance'] ?? 0.0).toDouble(),
      duration: Duration(seconds: map['duration'] ?? 0),
      price: (map['price'] ?? 0.0).toDouble(),
      polylinePoints: (map['polylinePoints'] as List<dynamic>?)
          ?.map((point) => LatLng(point['lat'], point['lng']))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromDestinationId': fromDestinationId,
      'toDestinationId': toDestinationId,
      'distance': distance,
      'duration': duration.inSeconds,
      'price': price,
      'polylinePoints': polylinePoints
          ?.map((point) => {'lat': point.latitude, 'lng': point.longitude})
          .toList(),
    };
  }

  /// Obter preço formatado
  String get formattedPrice => 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  /// Obter duração formatada
  String get formattedDuration {
    final minutes = duration.inMinutes;
    return '${minutes}min';
  }

  /// Obter distância formatada
  String get formattedDistance {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    } else {
      return '${distance.toInt()} m';
    }
  }
}

/// Configurações para cálculo de rota com múltiplos destinos
class RouteCalculationConfig {
  final bool optimizeRoute; // Otimizar ordem das paradas
  final bool avoidTolls; // Evitar pedágios
  final bool avoidHighways; // Evitar rodovias
  final double pricePerKm; // Preço por quilômetro
  final double baseFare; // Tarifa base
  final double timeMultiplier; // Multiplicador por tempo

  const RouteCalculationConfig({
    this.optimizeRoute = true,
    this.avoidTolls = false,
    this.avoidHighways = false,
    this.pricePerKm = 2.50,
    this.baseFare = 5.00,
    this.timeMultiplier = 0.30,
  });

  Map<String, dynamic> toMap() {
    return {
      'optimizeRoute': optimizeRoute,
      'avoidTolls': avoidTolls,
      'avoidHighways': avoidHighways,
      'pricePerKm': pricePerKm,
      'baseFare': baseFare,
      'timeMultiplier': timeMultiplier,
    };
  }

  factory RouteCalculationConfig.fromMap(Map<String, dynamic> map) {
    return RouteCalculationConfig(
      optimizeRoute: map['optimizeRoute'] ?? true,
      avoidTolls: map['avoidTolls'] ?? false,
      avoidHighways: map['avoidHighways'] ?? false,
      pricePerKm: (map['pricePerKm'] ?? 2.50).toDouble(),
      baseFare: (map['baseFare'] ?? 5.00).toDouble(),
      timeMultiplier: (map['timeMultiplier'] ?? 0.30).toDouble(),
    );
  }
}

