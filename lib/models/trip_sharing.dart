import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

/// Modelo principal para compartilhamento de viagem
class TripSharingData {
  final String tripId;
  final String passengerId;
  final String driverId;
  final List<SharedContact> sharedContacts;
  final TripData tripData;
  final String status;
  final String trackingLink;
  final DateTime createdAt;
  final DateTime updatedAt;

  TripSharingData({
    required this.tripId,
    required this.passengerId,
    required this.driverId,
    required this.sharedContacts,
    required this.tripData,
    required this.status,
    required this.trackingLink,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripSharingData.fromMap(Map<String, dynamic> map) {
    return TripSharingData(
      tripId: map['tripId'] ?? '',
      passengerId: map['passengerId'] ?? '',
      driverId: map['driverId'] ?? '',
      sharedContacts: (map['sharedContacts'] as List<dynamic>?)
              ?.map((contact) => SharedContact.fromMap(contact))
              .toList() ??
          [],
      tripData: TripData.fromMap(map['tripData'] ?? {}),
      status: map['status'] ?? 'waiting',
      trackingLink: map['trackingLink'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'passengerId': passengerId,
      'driverId': driverId,
      'sharedContacts': sharedContacts.map((contact) => contact.toMap()).toList(),
      'tripData': tripData.toMap(),
      'status': status,
      'trackingLink': trackingLink,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// Modelo para contatos compartilhados
class SharedContact {
  final String name;
  final String phone;
  final String relationship;
  final bool notificationSent;
  final DateTime? lastViewed;

  SharedContact({
    required this.name,
    required this.phone,
    required this.relationship,
    this.notificationSent = false,
    this.lastViewed,
  });

  factory SharedContact.fromMap(Map<String, dynamic> map) {
    return SharedContact(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      relationship: map['relationship'] ?? 'Contato',
      notificationSent: map['notificationSent'] ?? false,
      lastViewed: (map['lastViewed'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'relationship': relationship,
      'notificationSent': notificationSent,
      'lastViewed': lastViewed != null ? Timestamp.fromDate(lastViewed!) : null,
    };
  }
}

/// Modelo para dados da viagem
class TripData {
  final TripLocation startLocation;
  final TripLocation endLocation;
  final TripLocation currentLocation;
  final DateTime estimatedArrival;
  final DriverInfo driverInfo;

  TripData({
    required this.startLocation,
    required this.endLocation,
    required this.currentLocation,
    required this.estimatedArrival,
    required this.driverInfo,
  });

  factory TripData.fromMap(Map<String, dynamic> map) {
    return TripData(
      startLocation: TripLocation.fromMap(map['startLocation'] ?? {}),
      endLocation: TripLocation.fromMap(map['endLocation'] ?? {}),
      currentLocation: TripLocation.fromMap(map['currentLocation'] ?? {}),
      estimatedArrival: (map['estimatedArrival'] as Timestamp?)?.toDate() ?? 
          DateTime.now().add(Duration(minutes: 20)),
      driverInfo: DriverInfo.fromMap(map['driverInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startLocation': startLocation.toMap(),
      'endLocation': endLocation.toMap(),
      'currentLocation': currentLocation.toMap(),
      'estimatedArrival': Timestamp.fromDate(estimatedArrival),
      'driverInfo': driverInfo.toMap(),
    };
  }
}

/// Modelo para localização
class TripLocation {
  final double lat;
  final double lng;
  final String address;
  final DateTime? timestamp;

  TripLocation({
    required this.lat,
    required this.lng,
    required this.address,
    this.timestamp,
  });

  factory TripLocation.fromMap(Map<String, dynamic> map) {
    return TripLocation(
      lat: (map['lat'] ?? 0.0).toDouble(),
      lng: (map['lng'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
    };
  }

  LatLng toLatLng() => LatLng(lat, lng);
}

/// Modelo para informações do motorista
class DriverInfo {
  final String name;
  final String photo;
  final VehicleInfo vehicle;
  final double rating;

  DriverInfo({
    required this.name,
    required this.photo,
    required this.vehicle,
    required this.rating,
  });

  factory DriverInfo.fromMap(Map<String, dynamic> map) {
    return DriverInfo(
      name: map['name'] ?? 'Motorista',
      photo: map['photo'] ?? '',
      vehicle: VehicleInfo.fromMap(map['vehicle'] ?? {}),
      rating: (map['rating'] ?? 5.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photo': photo,
      'vehicle': vehicle.toMap(),
      'rating': rating,
    };
  }
}

/// Modelo para informações do veículo
class VehicleInfo {
  final String model;
  final String plate;
  final String color;

  VehicleInfo({
    required this.model,
    required this.plate,
    required this.color,
  });

  factory VehicleInfo.fromMap(Map<String, dynamic> map) {
    return VehicleInfo(
      model: map['model'] ?? 'Veículo',
      plate: map['plate'] ?? 'ABC-0000',
      color: map['color'] ?? 'Branco',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'plate': plate,
      'color': color,
    };
  }
}

/// Enum para status da viagem
enum TripSharingStatus {
  waiting,
  inProgress,
  completed,
  cancelled,
}

extension TripSharingStatusExtension on TripSharingStatus {
  String get value {
    switch (this) {
      case TripSharingStatus.waiting:
        return 'waiting';
      case TripSharingStatus.inProgress:
        return 'in_progress';
      case TripSharingStatus.completed:
        return 'completed';
      case TripSharingStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case TripSharingStatus.waiting:
        return 'Aguardando';
      case TripSharingStatus.inProgress:
        return 'Em andamento';
      case TripSharingStatus.completed:
        return 'Concluída';
      case TripSharingStatus.cancelled:
        return 'Cancelada';
    }
  }
}

