import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address_model.dart';
import 'pricing_service.dart';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

enum ScheduleStatus { 
  scheduled, // Agendada
  confirmed, // Confirmada (motorista encontrado)
  cancelled, // Cancelada
  completed  // Finalizada
}

class ScheduledRide {
  final String id;
  final AddressModel origin;
  final AddressModel destination;
  final List<AddressModel> waypoints;
  final DateTime scheduledTime;
  final VehicleType vehicleType;
  final double estimatedPrice;
  final ScheduleStatus status;
  final DateTime createdAt;
  final String? notes;
  final String? couponCode;
  final String? driverId;
  final String? driverName;
  final DateTime? confirmedAt;

  ScheduledRide({
    required this.id,
    required this.origin,
    required this.destination,
    required this.waypoints,
    required this.scheduledTime,
    required this.vehicleType,
    required this.estimatedPrice,
    required this.status,
    required this.createdAt,
    this.notes,
    this.couponCode,
    this.driverId,
    this.driverName,
    this.confirmedAt,
  });

  factory ScheduledRide.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScheduledRide(
      id: doc.id,
      origin: AddressModel.fromMap(data['origin']),
      destination: AddressModel.fromMap(data['destination']),
      waypoints: (data['waypoints'] as List<dynamic>? ?? [])
          .map((w) => AddressModel.fromMap(w))
          .toList(),
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      vehicleType: VehicleType.values.firstWhere(
        (v) => v.name == data['vehicleType'],
        orElse: () => VehicleType.economico,
      ),
      estimatedPrice: (data['estimatedPrice'] as num).toDouble(),
      status: ScheduleStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ScheduleStatus.scheduled,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      notes: data['notes'],
      couponCode: data['couponCode'],
      driverId: data['driverId'],
      driverName: data['driverName'],
      confirmedAt: data['confirmedAt'] != null 
          ? (data['confirmedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'origin': origin.toMap(),
      'destination': destination.toMap(),
      'waypoints': waypoints.map((w) => w.toMap()).toList(),
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'vehicleType': vehicleType.name,
      'estimatedPrice': estimatedPrice,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
      'couponCode': couponCode,
      'driverId': driverId,
      'driverName': driverName,
      'confirmedAt': confirmedAt != null 
          ? Timestamp.fromDate(confirmedAt!)
          : null,
    };
  }

  String get statusDisplay {
    switch (status) {
      case ScheduleStatus.scheduled:
        return 'Agendada';
      case ScheduleStatus.confirmed:
        return 'Confirmada';
      case ScheduleStatus.cancelled:
        return 'Cancelada';
      case ScheduleStatus.completed:
        return 'Finalizada';
    }
  }

  String get formattedScheduledTime {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Agora';
    }
  }

  bool get canBeCancelled {
    return status == ScheduleStatus.scheduled && 
           scheduledTime.isAfter(DateTime.now().add(Duration(minutes: 30)));
  }
}

class ScheduleService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _userId => _auth.currentUser!.uid;

  static CollectionReference get _scheduledRidesCollection =>
      _firestore.collection('corridas_agendadas');

  // Agendar nova corrida
  static Future<String?> scheduleRide({
    required AddressModel origin,
    required AddressModel destination,
    required List<AddressModel> waypoints,
    required DateTime scheduledTime,
    required VehicleType vehicleType,
    required double estimatedPrice,
    String? notes,
    String? couponCode,
  }) async {
    try {
      final scheduledRide = ScheduledRide(
        id: '',
        origin: origin,
        destination: destination,
        waypoints: waypoints,
        scheduledTime: scheduledTime,
        vehicleType: vehicleType,
        estimatedPrice: estimatedPrice,
        status: ScheduleStatus.scheduled,
        createdAt: DateTime.now(),
        notes: notes,
        couponCode: couponCode,
      );

      final data = scheduledRide.toFirestore();
      data['passengerId'] = _userId;

      final docRef = await _scheduledRidesCollection.add(data);
      LoggerService.info('📅 Corrida agendada salva com sucesso', context: 'ScheduleService');
      return docRef.id;
    } catch (e) {
      LoggerService.error('❌ Erro ao salvar corrida agendada: $e', context: 'ScheduleService');
      return null;
    }
  }

  // Listar corridas agendadas do usuário
  static Stream<List<ScheduledRide>> getScheduledRides() {
    return _scheduledRidesCollection
        .where('passengerId', isEqualTo: _userId)
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ScheduledRide.fromFirestore(doc))
            .toList());
  }

  // Obter corridas por status
  static Stream<List<ScheduledRide>> getScheduledRidesByStatus(ScheduleStatus status) {
    return _scheduledRidesCollection
        .where('passengerId', isEqualTo: _userId)
        .where('status', isEqualTo: status.name)
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ScheduledRide.fromFirestore(doc))
            .toList());
  }

  // Cancelar corrida agendada
  static Future<bool> cancelScheduledRide(String rideId) async {
    try {
      await _scheduledRidesCollection.doc(rideId).update({
        'status': ScheduleStatus.cancelled.name,
      });
      return true;
    } catch (e) {
      LoggerService.info('Erro ao cancelar corrida: $e', context: 'ScheduleService');
      return false;
    }
  }

  // Atualizar status da corrida
  static Future<bool> updateRideStatus(String rideId, ScheduleStatus status) async {
    try {
      final updateData = {
        'status': status.name,
      };

      if (status == ScheduleStatus.confirmed) {
        updateData['confirmedAt'] = DateTime.now().toIso8601String();
      }

      await _scheduledRidesCollection.doc(rideId).update(updateData);
      return true;
    } catch (e) {
      LoggerService.info('Erro ao atualizar status: $e', context: 'ScheduleService');
      return false;
    }
  }

  // Obter corrida específica
  static Future<ScheduledRide?> getScheduledRide(String rideId) async {
    try {
      final doc = await _scheduledRidesCollection.doc(rideId).get();
      if (doc.exists) {
        return ScheduledRide.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      LoggerService.info('Erro ao buscar corrida: $e', context: 'ScheduleService');
      return null;
    }
  }

  // Obter próximas corridas (próximas 24h)
  static Future<List<ScheduledRide>> getUpcomingRides() async {
    try {
      final tomorrow = DateTime.now().add(Duration(days: 1));
      final query = await _scheduledRidesCollection
          .where('passengerId', isEqualTo: _userId)
          .where('status', isEqualTo: ScheduleStatus.scheduled.name)
          .where('scheduledTime', isLessThan: Timestamp.fromDate(tomorrow))
          .where('scheduledTime', isGreaterThan: Timestamp.fromDate(DateTime.now()))
          .orderBy('scheduledTime')
          .get();

      return query.docs.map((doc) => ScheduledRide.fromFirestore(doc)).toList();
    } catch (e) {
      LoggerService.info('Erro ao buscar próximas corridas: $e', context: 'ScheduleService');
      return [];
    }
  }
}