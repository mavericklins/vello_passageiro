import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

/// Serviço de solicitação de corridas para o app passageiro
class RideRequestService {
  static final RideRequestService _instance = RideRequestService._internal();
  factory RideRequestService() => _instance;
  RideRequestService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Estado da solicitação atual
  String? _currentRideId;
  StreamSubscription<DocumentSnapshot>? _rideSubscription;
  
  // Callbacks para atualizações
  Function(String rideId, String status)? onRideStatusUpdate;
  Function(Map<String, dynamic> driverInfo)? onDriverAssigned;
  Function(LatLng driverLocation)? onDriverLocationUpdate;
  Function(String message)? onRideError;
  Function()? onRideCompleted;

  /// Solicita uma nova corrida APÓS confirmação do pagamento
  Future<String?> requestRide({
    required String origem,
    required String destino,
    required LatLng origemCoords,
    required LatLng destinoCoords,
    required double estimatedFare,
    required String paymentMethod,
    required String paymentTransactionId,
    List<String>? additionalStops,
    List<LatLng>? additionalStopsCoords,
    bool isSharedRide = false,
    int maxPassengers = 1,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        onRideError?.call('Usuário não autenticado');
        return null;
      }

      // Calcula distância total
      double totalDistance = _calculateDistance(origemCoords, destinoCoords);
      
      // Adiciona distância das paradas extras
      if (additionalStops != null && additionalStopsCoords != null) {
        LatLng currentPoint = origemCoords;
        for (final stop in additionalStopsCoords) {
          totalDistance += _calculateDistance(currentPoint, stop);
          currentPoint = stop;
        }
        totalDistance += _calculateDistance(currentPoint, destinoCoords);
      }

      // Cria documento da corrida
      final rideData = {
        'passageiroId': user.uid,
        'passageiroNome': user.displayName ?? 'Usuário',
        'passageiroEmail': user.email,
        'passageiroTelefone': user.phoneNumber ?? '',
        
        // Localização
        'origem': origem,
        'destino': destino,
        'origemLat': origemCoords.latitude,
        'origemLon': origemCoords.longitude,
        'destinoLat': destinoCoords.latitude,
        'destinoLon': destinoCoords.longitude,
        
        // Paradas extras
        'paradasExtras': additionalStops ?? [],
        'paradasExtrasCoords': additionalStopsCoords?.map((coord) => {
          'lat': coord.latitude,
          'lon': coord.longitude,
        }).toList() ?? [],
        
        // Informações da corrida
        'distanciaEstimada': totalDistance,
        'valorEstimado': estimatedFare,
        'isCorridaCompartilhada': isSharedRide,
        'maxPassageiros': maxPassengers,
        
        // Pagamento
        'metodoPagamento': paymentMethod,
        'transacaoPagamentoId': paymentTransactionId,
        'pagamentoConfirmado': true,
        
        // Status e timestamps
        'status': 'pendente', // pendente -> aceita -> iniciada -> em_andamento -> concluida
        'criadaEm': FieldValue.serverTimestamp(),
        'motoristaId': '', // Será preenchido quando motorista aceitar
        'motoristasRejeitados': [], // Lista de motoristas que rejeitaram
        
        // Metadados
        'versaoApp': '1.0.0',
        'plataforma': 'android',
      };

      // Salva no Firestore
      final docRef = await _firestore.collection('corridas').add(rideData);
      _currentRideId = docRef.id;

      // Inicia monitoramento da corrida
      _startRideMonitoring(docRef.id);

      // Busca motoristas disponíveis
      await _findAvailableDrivers(origemCoords, estimatedFare, docRef.id);

      return docRef.id;
    } catch (e) {
      LoggerService.info('Erro ao solicitar corrida: $e', context: context ?? 'UNKNOWN');
      onRideError?.call('Erro ao solicitar corrida: $e');
      return null;
    }
  }

  /// Busca motoristas disponíveis próximos
  Future<void> _findAvailableDrivers(LatLng origin, double fare, String rideId) async {
    try {
      // Busca motoristas online em um raio de 10km
      final driversSnapshot = await _firestore
          .collection('motoristas')
          .where('status', isEqualTo: 'online')
          .where('corridaAtiva', isEqualTo: null)
          .get();

      final availableDrivers = <Map<String, dynamic>>[];

      for (final driverDoc in driversSnapshot.docs) {
        final driverData = driverDoc.data();
        final driverLocation = driverData['location'];
        
        if (driverLocation != null) {
          final driverCoords = LatLng(
            driverLocation['latitude'],
            driverLocation['longitude'],
          );
          
          final distance = _calculateDistance(origin, driverCoords);
          
          // Motorista dentro do raio de 10km
          if (distance <= 10.0) {
            availableDrivers.add({
              'id': driverDoc.id,
              'data': driverData,
              'distance': distance,
            });
          }
        }
      }

      // Ordena por distância
      availableDrivers.sort((a, b) => a['distance'].compareTo(b['distance']));

      // Notifica os 5 motoristas mais próximos
      final driversToNotify = availableDrivers.take(5).toList();
      
      if (driversToNotify.isEmpty) {
        // Nenhum motorista disponível
        await _updateRideStatus(rideId, 'sem_motoristas');
        onRideError?.call('Nenhum motorista disponível no momento');
        return;
      }

      // Envia notificações para os motoristas
      for (final driver in driversToNotify) {
        await _notifyDriver(
          driverId: driver['id'],
          rideId: rideId,
          origin: origin,
          fare: fare,
          distance: driver['distance'],
        );
      }

      // Inicia timeout para buscar mais motoristas se necessário
      _startDriverSearchTimeout(rideId, origin, fare);
      
    } catch (e) {
      LoggerService.info('Erro ao buscar motoristas: $e', context: context ?? 'UNKNOWN');
      onRideError?.call('Erro ao buscar motoristas disponíveis');
    }
  }

  /// Notifica um motorista sobre nova corrida
  Future<void> _notifyDriver({
    required String driverId,
    required String rideId,
    required LatLng origin,
    required double fare,
    required double distance,
  }) async {
    try {
      // Aqui você integraria com o serviço de notificações
      // Por enquanto, apenas registra no Firestore para o motorista ver
      await _firestore.collection('notificacoes_motorista').add({
        'motoristaId': driverId,
        'corridaId': rideId,
        'tipo': 'nova_corrida',
        'origem': origin,
        'valor': fare,
        'distancia': distance,
        'criadaEm': FieldValue.serverTimestamp(),
        'lida': false,
      });
    } catch (e) {
      LoggerService.info('Erro ao notificar motorista: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Inicia timeout para buscar mais motoristas
  void _startDriverSearchTimeout(String rideId, LatLng origin, double fare) {
    Timer(const Duration(minutes: 2), () async {
      // Verifica se a corrida ainda está pendente
      final rideDoc = await _firestore.collection('corridas').doc(rideId).get();
      if (rideDoc.exists && rideDoc.data()!['status'] == 'pendente') {
        // Busca motoristas em um raio maior (15km)
        await _findAvailableDriversExtended(origin, fare, rideId);
      }
    });
  }

  /// Busca motoristas em raio estendido
  Future<void> _findAvailableDriversExtended(LatLng origin, double fare, String rideId) async {
    try {
      // Implementação similar à _findAvailableDrivers mas com raio de 15km
      // e possivelmente aumentando o valor da corrida para atrair motoristas
      
      final driversSnapshot = await _firestore
          .collection('motoristas')
          .where('status', isEqualTo: 'online')
          .get();

      bool foundDrivers = false;

      for (final driverDoc in driversSnapshot.docs) {
        final driverData = driverDoc.data();
        final driverLocation = driverData['location'];
        
        if (driverLocation != null) {
          final driverCoords = LatLng(
            driverLocation['latitude'],
            driverLocation['longitude'],
          );
          
          final distance = _calculateDistance(origin, driverCoords);
          
          if (distance <= 15.0) {
            await _notifyDriver(
              driverId: driverDoc.id,
              rideId: rideId,
              origin: origin,
              fare: fare * 1.2, // Aumenta 20% no valor
              distance: distance,
            );
            foundDrivers = true;
          }
        }
      }

      if (!foundDrivers) {
        // Cancela a corrida por falta de motoristas
        await _updateRideStatus(rideId, 'cancelada_sem_motoristas');
        onRideError?.call('Não foi possível encontrar motoristas disponíveis');
      }
    } catch (e) {
      LoggerService.info('Erro na busca estendida: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Inicia monitoramento da corrida
  void _startRideMonitoring(String rideId) {
    _rideSubscription = _firestore
        .collection('corridas')
        .doc(rideId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final status = data['status'] as String;
        
        onRideStatusUpdate?.call(rideId, status);
        
        switch (status) {
          case 'aceita':
            _handleRideAccepted(data);
            break;
          case 'iniciada':
            _handleRideStarted(data);
            break;
          case 'em_andamento':
            _handleRideInProgress(data);
            break;
          case 'concluida':
            _handleRideCompleted(data);
            break;
          case 'cancelada':
            _handleRideCancelled(data);
            break;
        }
      }
    });
  }

  /// Manipula corrida aceita
  void _handleRideAccepted(Map<String, dynamic> rideData) {
    final driverId = rideData['motoristaId'] as String;
    
    // Busca informações do motorista
    _firestore.collection('motoristas').doc(driverId).get().then((driverDoc) {
      if (driverDoc.exists) {
        onDriverAssigned?.call(driverDoc.data()!);
        
        // Inicia monitoramento da localização do motorista
        _startDriverLocationMonitoring(driverId);
      }
    });
  }

  /// Manipula corrida iniciada
  void _handleRideStarted(Map<String, dynamic> rideData) {
    // Motorista chegou ao local de origem
    // Pode mostrar notificação ou atualizar UI
  }

  /// Manipula corrida em andamento
  void _handleRideInProgress(Map<String, dynamic> rideData) {
    // Corrida em andamento
    // Continua monitorando localização
  }

  /// Manipula corrida concluída
  void _handleRideCompleted(Map<String, dynamic> rideData) {
    _stopMonitoring();
    onRideCompleted?.call();
  }

  /// Manipula corrida cancelada
  void _handleRideCancelled(Map<String, dynamic> rideData) {
    _stopMonitoring();
    final motivo = rideData['motivoCancelamento'] ?? 'Motivo não informado';
    onRideError?.call('Corrida cancelada: $motivo');
  }

  /// Inicia monitoramento da localização do motorista
  void _startDriverLocationMonitoring(String driverId) {
    _firestore
        .collection('motoristas')
        .doc(driverId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final location = data['location'];
        
        if (location != null) {
          final driverLocation = LatLng(
            location['latitude'],
            location['longitude'],
          );
          onDriverLocationUpdate?.call(driverLocation);
        }
      }
    });
  }

  /// Cancela a corrida atual
  Future<bool> cancelRide(String reason) async {
    if (_currentRideId == null) return false;

    try {
      await _firestore.collection('corridas').doc(_currentRideId).update({
        'status': 'cancelada',
        'canceladaEm': FieldValue.serverTimestamp(),
        'motivoCancelamento': reason,
        'canceladaPor': 'passageiro',
      });

      _stopMonitoring();
      return true;
    } catch (e) {
      LoggerService.info('Erro ao cancelar corrida: $e', context: context ?? 'UNKNOWN');
      return false;
    }
  }

  /// Avalia o motorista
  Future<bool> rateDriver(String rideId, double rating, String comment) async {
    try {
      await _firestore.collection('avaliacoes').add({
        'corridaId': rideId,
        'passageiroId': _auth.currentUser?.uid,
        'motoristaId': '', // Será preenchido com base na corrida
        'nota': rating,
        'comentario': comment,
        'tipo': 'passageiro_para_motorista',
        'criadaEm': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      LoggerService.info('Erro ao avaliar motorista: $e', context: context ?? 'UNKNOWN');
      return false;
    }
  }

  /// Atualiza status da corrida
  Future<void> _updateRideStatus(String rideId, String status) async {
    await _firestore.collection('corridas').doc(rideId).update({
      'status': status,
      'atualizadaEm': FieldValue.serverTimestamp(),
    });
  }

  /// Para todos os monitoramentos
  void _stopMonitoring() {
    _rideSubscription?.cancel();
    _currentRideId = null;
  }

  /// Calcula distância entre dois pontos em km
  double _calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    ) / 1000; // Converte para km
  }

  /// Estima tempo de chegada do motorista
  Duration estimateDriverArrival(LatLng driverLocation, LatLng pickupLocation) {
    final distance = _calculateDistance(driverLocation, pickupLocation);
    const averageSpeed = 25.0; // km/h velocidade média na cidade
    final timeInHours = distance / averageSpeed;
    return Duration(minutes: (timeInHours * 60).round());
  }

  /// Obtém histórico de corridas do usuário
  Future<List<Map<String, dynamic>>> getRideHistory({int limit = 20}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('corridas')
          .where('passageiroId', isEqualTo: user.uid)
          .orderBy('criadaEm', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      LoggerService.info('Erro ao obter histórico: $e', context: context ?? 'UNKNOWN');
      return [];
    }
  }

  /// Obtém corrida ativa do usuário
  Future<Map<String, dynamic>?> getActiveRide() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final snapshot = await _firestore
          .collection('corridas')
          .where('passageiroId', isEqualTo: user.uid)
          .where('status', whereIn: ['pendente', 'aceita', 'iniciada', 'em_andamento'])
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }

      return null;
    } catch (e) {
      LoggerService.info('Erro ao obter corrida ativa: $e', context: context ?? 'UNKNOWN');
      return null;
    }
  }

  /// Getters
  String? get currentRideId => _currentRideId;
  bool get hasActiveRide => _currentRideId != null;

  /// Limpa recursos
  void dispose() {
    _stopMonitoring();
  }
}

