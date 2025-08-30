import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

/// Serviço de solicitação de corridas integrado com Firebase
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
    String? nomePassageiro,
    String? telefonePassageiro,
    List<String>? additionalStops,
    List<LatLng>? additionalStopsCoords,
    bool isSharedRide = false,
    int maxPassengers = 1,
  }) async {
    try {
      // Aguarda o usuário estar autenticado com retry
      User? user = _auth.currentUser;
      
      // Se não há usuário, aguarda um pouco e tenta novamente
      if (user == null) {
        LoggerService.info('🔄 Usuário não encontrado, aguardando autenticação...', context: context ?? 'UNKNOWN');
        await Future.delayed(Duration(milliseconds: 1000));
        user = _auth.currentUser;
      }
      
      // Se ainda não há usuário, força reautenticação
      if (user == null) {
        LoggerService.info('🔄 Forçando reautenticação...', context: context ?? 'UNKNOWN');
        await _auth.authStateChanges().first;
        user = _auth.currentUser;
      }
      
      if (user == null) {
        final errorMsg = 'Usuário não autenticado. Faça login novamente.';
        LoggerService.error(' $errorMsg', context: context ?? 'UNKNOWN');
        onRideError?.call(errorMsg);
        return null;
      }
      
      LoggerService.success(' Usuário autenticado: ${user.uid}', context: context ?? 'UNKNOWN');

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

      // Cria documento da corrida no Firebase (compatível com painel admin)
      final rideData = {
        // IDs e informações do passageiro
        'passageiroId': user.uid,
        'nomePassageiro': nomePassageiro ?? user.displayName ?? 'Usuário',
        'telefonePassageiro': telefonePassageiro ?? user.phoneNumber ?? '',
        'emailPassageiro': user.email ?? '',
        
        // Localização (formato compatível com painel)
        'origem': origem,
        'destino': destino,
        'origemLat': origemCoords.latitude,
        'origemLon': origemCoords.longitude,
        'destinoLat': destinoCoords.latitude,
        'destinoLon': destinoCoords.longitude,
        
        // Informações da corrida
        'valor': estimatedFare,
        'distanciaEstimada': totalDistance,
        'isCorridaCompartilhada': isSharedRide,
        'maxPassageiros': maxPassengers,
        
        // Pagamento
        'metodoPagamento': paymentMethod,
        'transacaoPagamentoId': paymentTransactionId,
        'pagamentoConfirmado': true,
        
        // Status (compatível com painel admin)
        'status': 'pendente', // pendente -> em_andamento -> concluida -> cancelada
        
        // Timestamps
        'dataHora': FieldValue.serverTimestamp(),
        'dataHoraSolicitacao': FieldValue.serverTimestamp(),
        'criadaEm': FieldValue.serverTimestamp(),
        
        // Motorista (será preenchido quando aceitar)
        'motoristaId': null,
        'nomeMotorista': null,
        'telefoneMotorista': null,
        'placaVeiculo': null,
        'modeloVeiculo': null,
        'dataHoraInicio': null,
        'dataHoraConclusao': null,
        
        // Controle de notificações
        'motoristasNotificados': [],
        'motoristasRejeitados': [],
        'tentativasNotificacao': 0,
        
        // Metadados
        'versaoApp': '1.0.0',
        'plataforma': 'android',
      };

      LoggerService.info('🔥 Criando corrida no Firebase...', context: context ?? 'UNKNOWN');
      
      // Salva no Firestore
      final docRef = await _firestore.collection('corridas').add(rideData);
      _currentRideId = docRef.id;

      LoggerService.success(' Corrida criada com ID: ${docRef.id}', context: context ?? 'UNKNOWN');
      LoggerService.info('📍 Origem: $origem', context: context ?? 'UNKNOWN');
      LoggerService.info('📍 Destino: $destino', context: context ?? 'UNKNOWN');
      LoggerService.info('💰 Valor: R\$ ${estimatedFare.toStringAsFixed(2)}', context: context ?? 'UNKNOWN');

      // Inicia monitoramento da corrida
      _startRideMonitoring(docRef.id);

      // Busca motoristas disponíveis
      await _findAvailableDrivers(origemCoords, estimatedFare, docRef.id);

      return docRef.id;
    } catch (e) {
      LoggerService.error(' Erro ao solicitar corrida: $e', context: context ?? 'UNKNOWN');
      onRideError?.call('Erro ao solicitar corrida: $e');
      return null;
    }
  }

  /// Busca motoristas disponíveis próximos
  Future<void> _findAvailableDrivers(LatLng origin, double fare, String rideId) async {
    try {
      LoggerService.info('🔍 Buscando motoristas disponíveis...', context: context ?? 'UNKNOWN');
      
      // Busca motoristas online
      final driversSnapshot = await _firestore
          .collection('motoristas')
          .where('isOnline', isEqualTo: true)
          .where('status', isEqualTo: 'disponivel')
          .get();

      final availableDrivers = <Map<String, dynamic>>[];

      for (final driverDoc in driversSnapshot.docs) {
        final driverData = driverDoc.data();
        final location = driverData['localizacaoAtual'];
        
        if (location != null && location['latitude'] != null && location['longitude'] != null) {
          final driverCoords = LatLng(
            location['latitude'].toDouble(),
            location['longitude'].toDouble(),
          );
          
          final distance = _calculateDistance(origin, driverCoords);
          
          // Motorista dentro do raio de 15km
          if (distance <= 15.0) {
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

      LoggerService.info('📱 Encontrados ${availableDrivers.length} motoristas próximos', context: context ?? 'UNKNOWN');

      if (availableDrivers.isEmpty) {
        // Nenhum motorista disponível
        await _updateRideStatus(rideId, 'sem_motoristas');
        onRideError?.call('Nenhum motorista disponível no momento');
        return;
      }

      // Notifica os 3 motoristas mais próximos
      final driversToNotify = availableDrivers.take(3).toList();
      
      // Atualiza lista de motoristas notificados
      await _firestore.collection('corridas').doc(rideId).update({
        'motoristasNotificados': driversToNotify.map((d) => d['id']).toList(),
        'tentativasNotificacao': FieldValue.increment(1),
      });

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

      LoggerService.info('🔔 Notificações enviadas para ${driversToNotify.length} motoristas', context: context ?? 'UNKNOWN');
      
    } catch (e) {
      LoggerService.error(' Erro ao buscar motoristas: $e', context: context ?? 'UNKNOWN');
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
      // Cria notificação na subcoleção do motorista
      await _firestore
          .collection('motoristas')
          .doc(driverId)
          .collection('notificacoes_corridas')
          .doc(rideId)
          .set({
        'corridaId': rideId,
        'tipo': 'nova_corrida',
        'valor': fare,
        'distanciaAtePassageiro': distance,
        'criadaEm': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(Duration(minutes: 2)), // Expira em 2 minutos
        'status': 'pendente', // pendente, aceita, rejeitada, expirada
      });

      LoggerService.info('🔔 Notificação enviada para motorista $driverId', context: context ?? 'UNKNOWN');
      
    } catch (e) {
      LoggerService.error(' Erro ao notificar motorista $driverId: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Inicia monitoramento da corrida
  void _startRideMonitoring(String rideId) {
    _rideSubscription?.cancel();
    
    _rideSubscription = _firestore
        .collection('corridas')
        .doc(rideId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;
      
      final data = snapshot.data()!;
      final status = data['status'] as String;
      
      LoggerService.info('📊 Status da corrida atualizado: $status', context: context ?? 'UNKNOWN');
      
      onRideStatusUpdate?.call(rideId, status);
      
      switch (status) {
        case 'em_andamento':
          // Motorista aceitou
          if (data['motoristaId'] != null) {
            onDriverAssigned?.call({
              'id': data['motoristaId'],
              'nome': data['nomeMotorista'],
              'telefone': data['telefoneMotorista'],
              'placa': data['placaVeiculo'],
              'modelo': data['modeloVeiculo'],
            });
          }
          break;
          
        case 'concluida':
          onRideCompleted?.call();
          _rideSubscription?.cancel();
          _currentRideId = null;
          break;
          
        case 'cancelada':
          onRideError?.call('Corrida cancelada');
          _rideSubscription?.cancel();
          _currentRideId = null;
          break;
      }
    });
  }

  /// Atualiza status da corrida
  Future<void> _updateRideStatus(String rideId, String status) async {
    try {
      await _firestore.collection('corridas').doc(rideId).update({
        'status': status,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LoggerService.error(' Erro ao atualizar status: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Cancela corrida atual
  Future<void> cancelCurrentRide({String? reason}) async {
    if (_currentRideId == null) return;
    
    try {
      await _firestore.collection('corridas').doc(_currentRideId!).update({
        'status': 'cancelada',
        'motivoCancelamento': reason ?? 'Cancelado pelo passageiro',
        'canceladoEm': FieldValue.serverTimestamp(),
        'dataHoraConclusao': FieldValue.serverTimestamp(),
      });
      
      _rideSubscription?.cancel();
      _currentRideId = null;
      
      LoggerService.error(' Corrida cancelada', context: context ?? 'UNKNOWN');
      
    } catch (e) {
      LoggerService.error(' Erro ao cancelar corrida: $e', context: context ?? 'UNKNOWN');
    }
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

  /// Limpa recursos
  void dispose() {
    _rideSubscription?.cancel();
  }

  /// Getters
  String? get currentRideId => _currentRideId;
  bool get hasActiveRide => _currentRideId != null;
}

