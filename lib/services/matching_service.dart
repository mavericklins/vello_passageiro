import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math' as math;
import '../core/logger_service.dart';
import '../core/error_handler.dart';

/// Serviço de matching para conectar passageiros com motoristas
class MatchingService {
  static final MatchingService _instance = MatchingService._internal();
  factory MatchingService() => _instance;
  MatchingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  StreamSubscription<DocumentSnapshot>? _corridaSubscription;
  String? _currentCorridaId;
  
  // Callbacks para atualizações
  Function(String status, Map<String, dynamic>? motoristaData)? onStatusUpdate;
  Function(String message)? onError;

  /// Iniciar monitoramento de uma corrida específica
  void startMonitoring(String corridaId) {
    _currentCorridaId = corridaId;
    
    LoggerService.info('🔍 MatchingService: Iniciando monitoramento da corrida $corridaId', context: context ?? 'UNKNOWN');
    
    // Cancelar monitoramento anterior se existir
    _corridaSubscription?.cancel();
    
    // Monitorar mudanças na corrida em tempo real
    _corridaSubscription = _firestore
        .collection('corridas')
        .doc(corridaId)
        .snapshots()
        .listen(
          _onCorridaUpdate,
          onError: (error) {
            LoggerService.error(' Erro no monitoramento da corrida: $error', context: context ?? 'UNKNOWN');
            onError?.call('Erro ao monitorar corrida: $error');
          },
        );
  }

  /// Parar monitoramento
  void stopMonitoring() {
    LoggerService.info('🛑 MatchingService: Parando monitoramento', context: context ?? 'UNKNOWN');
    _corridaSubscription?.cancel();
    _corridaSubscription = null;
    _currentCorridaId = null;
  }

  /// Quando há atualização na corrida
  void _onCorridaUpdate(DocumentSnapshot snapshot) {
    if (!snapshot.exists) {
      LoggerService.error(' Corrida não encontrada', context: context ?? 'UNKNOWN');
      onError?.call('Corrida não encontrada');
      return;
    }

    final data = snapshot.data() as Map<String, dynamic>;
    final status = data['status'] as String;
    final motoristaId = data['motoristaId'] as String?;
    
    LoggerService.info('📱 MatchingService: Status atualizado para $status', context: context ?? 'UNKNOWN');
    
    Map<String, dynamic>? motoristaData;
    
    // Se motorista foi atribuído, buscar dados dele
    if (motoristaId != null && motoristaId.isNotEmpty) {
      _buscarDadosMotorista(motoristaId).then((dados) {
        motoristaData = dados;
        onStatusUpdate?.call(status, motoristaData);
      });
    } else {
      onStatusUpdate?.call(status, null);
    }
  }

  /// Buscar dados do motorista
  Future<Map<String, dynamic>?> _buscarDadosMotorista(String motoristaId) async {
    try {
      LoggerService.info('👤 Buscando dados do motorista $motoristaId', context: context ?? 'UNKNOWN');
      
      final motoristaDoc = await _firestore
          .collection('motoristas')
          .doc(motoristaId)
          .get();
      
      if (motoristaDoc.exists) {
        final dados = motoristaDoc.data()!;
        LoggerService.success('Dados do motorista encontrados: ${dados['nome']}', context: 'MATCHING');
        return dados;
      } else {
        LoggerService.error(' Motorista não encontrado', context: context ?? 'UNKNOWN');
        return null;
      }
    } catch (e) {
      LoggerService.error(' Erro ao buscar dados do motorista: $e', context: context ?? 'UNKNOWN');
      return null;
    }
  }

  /// Notificar motoristas próximos sobre nova corrida
  static Future<void> notifyNearbyDrivers(String corridaId) async {
    try {
      LoggerService.info('📢 Notificando motoristas sobre corrida $corridaId', context: context ?? 'UNKNOWN');
      
      // Buscar dados da corrida
      final corridaDoc = await FirebaseFirestore.instance
          .collection('corridas')
          .doc(corridaId)
          .get();
      
      if (!corridaDoc.exists) {
        LoggerService.error(' Corrida não encontrada para notificação', context: context ?? 'UNKNOWN');
        return;
      }
      
      final corridaData = corridaDoc.data()!;
      final origem = corridaData['origem'] as Map<String, dynamic>;
      final origemLat = origem['latitude'] as double;
      final origemLng = origem['longitude'] as double;
      
      // Buscar motoristas online próximos (raio de 10km)
      final motoristasQuery = await FirebaseFirestore.instance
          .collection('motoristas')
          .where('status', isEqualTo: 'online')
          .get();
      
      final batch = FirebaseFirestore.instance.batch();
      int notificacoesEnviadas = 0;
      
      for (final motoristaDoc in motoristasQuery.docs) {
        final motoristaData = motoristaDoc.data();
        final motoristaId = motoristaDoc.id;
        
        // Verificar se motorista tem localização
        if (motoristaData['latitude'] != null && motoristaData['longitude'] != null) {
          final motoristaLat = motoristaData['latitude'] as double;
          final motoristaLng = motoristaData['longitude'] as double;
          
          // Calcular distância (aproximada)
          final distancia = _calcularDistancia(
            origemLat, origemLng, 
            motoristaLat, motoristaLng
          );
          
          // Se está dentro do raio de 10km
          if (distancia <= 10.0) {
            // Verificar se motorista não rejeitou esta corrida
            final rejeitados = corridaData['motoristasRejeitados'] as List<dynamic>? ?? [];
            if (!rejeitados.contains(motoristaId)) {
              // Criar notificação para o motorista
              final notificacaoRef = FirebaseFirestore.instance
                  .collection('notificacoes_motorista')
                  .doc();
              
              batch.set(notificacaoRef, {
                'motoristaId': motoristaId,
                'corridaId': corridaId,
                'tipo': 'nova_corrida',
                'lida': false,
                'criadaEm': FieldValue.serverTimestamp(),
                'distancia': distancia,
                'origem': origem,
                'destino': corridaData['destino'],
                'valor': corridaData['valor'],
                'nomePassageiro': corridaData['nomePassageiro'],
              });
              
              notificacoesEnviadas++;
            }
          }
        }
      }
      
      // Executar batch de notificações
      if (notificacoesEnviadas > 0) {
        await batch.commit();
        LoggerService.success(' $notificacoesEnviadas notificações enviadas para motoristas', context: context ?? 'UNKNOWN');
      } else {
        LoggerService.warning(' Nenhum motorista disponível encontrado', context: context ?? 'UNKNOWN');
      }
      
    } catch (e) {
      LoggerService.error(' Erro ao notificar motoristas: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Calcular distância aproximada entre dois pontos (em km)
  static double _calcularDistancia(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // Raio da Terra em km
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);
    
    final double a = 
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) * 
        math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final double c = 2 * math.asin(math.sqrt(a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Cancelar corrida
  Future<void> cancelRide(String corridaId, String motivo) async {
    try {
      LoggerService.error(' Cancelando corrida $corridaId', context: context ?? 'UNKNOWN');
      
      await _firestore.collection('corridas').doc(corridaId).update({
        'status': 'cancelada',
        'motivoCancelamento': motivo,
        'canceladaEm': FieldValue.serverTimestamp(),
        'atualizadaEm': FieldValue.serverTimestamp(),
      });
      
      // Parar monitoramento
      stopMonitoring();
      
      LoggerService.success(' Corrida cancelada com sucesso', context: context ?? 'UNKNOWN');
    } catch (e) {
      LoggerService.error(' Erro ao cancelar corrida: $e', context: context ?? 'UNKNOWN');
      onError?.call('Erro ao cancelar corrida: $e');
    }
  }

  /// Dispose do serviço
  void dispose() {
    stopMonitoring();
  }
}

