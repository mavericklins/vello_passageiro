import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/passenger_meta_inteligente.dart';
import '../models/passenger_goals.dart';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

class PassengerGoalsService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<PassengerMetaInteligente> _metas = [];
  Map<String, dynamic> _performance = {};
  Map<String, dynamic> _previsoes = {};
  bool _isLoading = false;

  List<PassengerMetaInteligente> get metas => _metas;
  Map<String, dynamic> get performance => _performance;
  Map<String, dynamic> get previsoes => _previsoes;
  bool get isLoading => _isLoading;

  // Referências para coleções Firestore
  CollectionReference get _passengersCollection => _firestore.collection('passengers');
  CollectionReference get _passengerGoalsCollection => _firestore.collection('passenger_goals');

  /// Carrega metas do passageiro atual
  Future<void> carregarMetas() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) return;

      // Buscar metas ativas do passageiro
      final metasSnapshot = await _passengerGoalsCollection
          .where('passengerId', isEqualTo: user.uid)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      _metas = metasSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PassengerMetaInteligente.fromFirestore(doc.id, data);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      LoggerService.error(' Erro ao carregar metas: $e', context: 'passenger_goals_service');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gera metas personalizadas baseadas no histórico do passageiro
  Future<void> gerarMetasPersonalizadas() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) return;

      // Obter estatísticas do passageiro para gerar metas inteligentes
      final statistics = await _getPassengerStatistics(user.uid);

      final totalRides = statistics['totalRides'] ?? 0;
      final totalSpent = statistics['totalSpent'] ?? 0.0;
      final averageRating = statistics['averageRating'] ?? 0.0;

      // Gerar meta de corridas semanais baseada no histórico
      if (totalRides > 0) {
        await _criarMetaCorridasSemanais(user.uid, totalRides);
      }

      // Gerar meta de economia mensal
      if (totalSpent > 0) {
        await _criarMetaEconomiaMensal(user.uid, totalSpent);
      }

      // Gerar meta de avaliação
      await _criarMetaAvaliacao(user.uid);

      // Gerar meta de uso sustentável
      await _criarMetaEcoFriendly(user.uid);

      // Recarregar metas após criação
      await carregarMetas();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      LoggerService.error(' Erro ao gerar metas personalizadas: $e', context: 'passenger_goals_service');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cria meta de corridas semanais
  Future<void> _criarMetaCorridasSemanais(String passengerId, int totalRides) async {
    final weeklyTarget = ((totalRides / 30) * 7 * 1.1).round(); // 10% de aumento
    
    final metaData = {
      'passengerId': passengerId,
      'title': 'Corridas Semanais',
      'description': 'Meta adaptativa baseada no seu histórico de uso',
      'type': 'rides',
      'category': 'productivity',
      'targetValue': weeklyTarget.toDouble(),
      'currentValue': 0.0,
      'reward': 'Desconto de 15% na próxima corrida',
      'startDate': FieldValue.serverTimestamp(),
      'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      'isActive': true,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final metaId = await _passengerGoalsCollection.add(metaData);
    LoggerService.success(' Meta de corridas semanais criada: ${metaId.id}', context: 'passenger_goals_service');
  }

  /// Cria meta de economia mensal
  Future<void> _criarMetaEconomiaMensal(String passengerId, double totalSpent) async {
    final monthlyAverage = totalSpent / 30;
    final savingsTarget = (monthlyAverage * 0.2).roundToDouble(); // 20% de economia
    
    final metaData = {
      'passengerId': passengerId,
      'title': 'Economia Mensal',
      'description': 'Economize dinheiro usando corridas compartilhadas e promoções',
      'type': 'savings',
      'category': 'economy',
      'targetValue': savingsTarget,
      'currentValue': 0.0,
      'reward': 'Cashback de R\$ ${(savingsTarget * 0.1).toStringAsFixed(2)}',
      'startDate': FieldValue.serverTimestamp(),
      'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
      'isActive': true,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final metaId = await _passengerGoalsCollection.add(metaData);
    LoggerService.success(' Meta de economia mensal criada: ${metaId.id}', context: 'passenger_goals_service');
  }

  /// Cria meta de avaliação
  Future<void> _criarMetaAvaliacao(String passengerId) async {
    final metaData = {
      'passengerId': passengerId,
      'title': 'Avaliações Consistentes',
      'description': 'Avalie todas as suas corridas para ajudar outros passageiros',
      'type': 'rating',
      'category': 'quality',
      'targetValue': 10.0, // 10 avaliações
      'currentValue': 0.0,
      'reward': '50 pontos no sistema de recompensas',
      'startDate': FieldValue.serverTimestamp(),
      'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      'isActive': true,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final metaId = await _passengerGoalsCollection.add(metaData);
    LoggerService.success(' Meta de avaliação criada: ${metaId.id}', context: 'passenger_goals_service');
  }

  /// Cria meta eco-friendly
  Future<void> _criarMetaEcoFriendly(String passengerId) async {
    final metaData = {
      'passengerId': passengerId,
      'title': 'Mobilidade Sustentável',
      'description': 'Use corridas compartilhadas para reduzir o impacto ambiental',
      'type': 'eco_friendly',
      'category': 'sustainability',
      'targetValue': 5.0, // 5 corridas compartilhadas
      'currentValue': 0.0,
      'reward': 'Badge Eco-Friendly + 20% desconto',
      'startDate': FieldValue.serverTimestamp(),
      'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 14))),
      'isActive': true,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final metaId = await _passengerGoalsCollection.add(metaData);
    LoggerService.success(' Meta eco-friendly criada: ${metaId.id}', context: 'passenger_goals_service');
  }

  /// Atualiza progresso das metas baseado nas ações do passageiro
  Future<void> atualizarProgressoMetas() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      for (final meta in _metas) {
        if (!meta.isAtiva || meta.completada) continue;

        double novoProgresso = 0.0;

        switch (meta.tipo) {
          case TipoMetaPassageiro.corridas:
            novoProgresso = await _calcularProgressoCorridas(meta);
            break;
          case TipoMetaPassageiro.economia:
            novoProgresso = await _calcularProgressoEconomia(meta);
            break;
          case TipoMetaPassageiro.avaliacao:
            novoProgresso = await _calcularProgressoAvaliacao(meta);
            break;
          case TipoMetaPassageiro.eco_friendly:
            novoProgresso = await _calcularProgressoEcoFriendly(meta);
            break;
          default:
            continue;
        }

        // Atualizar progresso no Firestore
        await _atualizarProgressoMeta(meta.id, novoProgresso);

        // Adicionar ao histórico de progresso
        await _adicionarHistoricoProgresso(meta.id, novoProgresso);

        // Verificar se meta foi completada
        if (novoProgresso >= meta.valorObjetivo && !meta.completada) {
          await _completarMeta(meta.id);
        }
      }

      // Recarregar metas após atualização
      await carregarMetas();
    } catch (e) {
      LoggerService.error(' Erro ao atualizar progresso das metas: $e', context: 'passenger_goals_service');
    }
  }

  /// Calcula progresso de meta de corridas
  Future<double> _calcularProgressoCorridas(PassengerMetaInteligente meta) async {
    final user = _auth.currentUser;
    if (user == null) return 0.0;

    final stats = await _getRideStatistics(
      user.uid,
      startDate: meta.dataInicio,
      endDate: DateTime.now(),
    );

    return (stats['totalRides'] ?? 0).toDouble();
  }

  /// Calcula progresso de meta de economia
  Future<double> _calcularProgressoEconomia(PassengerMetaInteligente meta) async {
    final user = _auth.currentUser;
    if (user == null) return 0.0;

    final stats = await _getRideStatistics(
      user.uid,
      startDate: meta.dataInicio,
      endDate: DateTime.now(),
    );

    return (stats['totalSavings'] ?? 0.0).toDouble();
  }

  /// Calcula progresso de meta de avaliação
  Future<double> _calcularProgressoAvaliacao(PassengerMetaInteligente meta) async {
    final user = _auth.currentUser;
    if (user == null) return 0.0;

    final stats = await _getRideStatistics(
      user.uid,
      startDate: meta.dataInicio,
      endDate: DateTime.now(),
    );

    return (stats['ratingsGiven'] ?? 0).toDouble();
  }

  /// Calcula progresso de meta eco-friendly
  Future<double> _calcularProgressoEcoFriendly(PassengerMetaInteligente meta) async {
    final user = _auth.currentUser;
    if (user == null) return 0.0;

    final stats = await _getRideStatistics(
      user.uid,
      startDate: meta.dataInicio,
      endDate: DateTime.now(),
    );

    return (stats['sharedRides'] ?? 0).toDouble();
  }

  /// Atualiza progresso da meta no Firestore
  Future<void> _atualizarProgressoMeta(String metaId, double novoProgresso) async {
    await _passengerGoalsCollection.doc(metaId).update({
      'currentValue': novoProgresso,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Adiciona registro ao histórico de progresso
  Future<void> _adicionarHistoricoProgresso(String metaId, double progresso) async {
    await _passengerGoalsCollection.doc(metaId).collection('progressHistory').add({
      'progress': progresso,
      'timestamp': FieldValue.serverTimestamp(),
      'description': 'Progresso atualizado automaticamente',
    });
  }

  /// Completa uma meta
  Future<void> _completarMeta(String metaId) async {
    await _passengerGoalsCollection.doc(metaId).update({
      'isCompleted': true,
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    LoggerService.info('🎉 Meta $metaId completada!', context: 'passenger_goals_service');
  }

  /// Cria meta personalizada
  Future<void> criarMeta(PassengerMetaInteligente meta) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final metaData = {
        'passengerId': user.uid,
        'title': meta.titulo,
        'description': meta.descricao,
        'type': meta.tipo.toString().split('.').last,
        'category': meta.categoria.toString().split('.').last,
        'targetValue': meta.valorObjetivo,
        'currentValue': meta.valorAtual,
        'reward': meta.recompensa,
        'startDate': Timestamp.fromDate(meta.dataInicio),
        'endDate': Timestamp.fromDate(meta.dataFim),
        'isActive': meta.isAtiva,
        'isCompleted': meta.completada,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _passengerGoalsCollection.add(metaData);
      await carregarMetas();
    } catch (e) {
      LoggerService.error(' Erro ao criar meta: $e', context: 'passenger_goals_service');
    }
  }

  /// Completa meta manualmente
  Future<void> completarMeta(String metaId) async {
    await _completarMeta(metaId);
    await carregarMetas();
  }

  /// Stream de metas em tempo real
  Stream<List<PassengerMetaInteligente>> getMetasStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _passengerGoalsCollection
        .where('passengerId', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PassengerMetaInteligente.fromFirestore(doc.id, data);
      }).toList();
    });
  }

  /// Stream de dados do passageiro
  Stream<PassengerGoals?> getPassengerGoals() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    return _passengersCollection
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return PassengerGoals.fromFirestore(snapshot);
      }
      return null;
    });
  }

  // ========== MÉTODOS AUXILIARES ==========

  /// Obtém estatísticas do passageiro
  Future<Map<String, dynamic>> _getPassengerStatistics(String passengerId) async {
    try {
      // Buscar dados de corridas do passageiro
      final ridesQuery = await _firestore
          .collection('rides')
          .where('passengerId', isEqualTo: passengerId)
          .where('status', isEqualTo: 'completed')
          .get();

      double totalSpent = 0.0;
      double totalSavings = 0.0;
      int totalRides = ridesQuery.docs.length;
      int ratingsGiven = 0;
      int sharedRides = 0;

      for (final doc in ridesQuery.docs) {
        final data = doc.data();
        totalSpent += (data['fare'] ?? 0.0);
        totalSavings += (data['discount'] ?? 0.0);
        
        if (data['passengerRating'] != null) {
          ratingsGiven++;
        }
        
        if (data['isShared'] == true) {
          sharedRides++;
        }
      }

      return {
        'totalRides': totalRides,
        'totalSpent': totalSpent,
        'totalSavings': totalSavings,
        'averageSpentPerRide': totalRides > 0 ? totalSpent / totalRides : 0.0,
        'ratingsGiven': ratingsGiven,
        'sharedRides': sharedRides,
      };
    } catch (e) {
      LoggerService.error(' Erro ao obter estatísticas: $e', context: 'passenger_goals_service');
      return {};
    }
  }

  /// Obtém estatísticas de corridas em período específico
  Future<Map<String, dynamic>> _getRideStatistics(String passengerId, 
      {required DateTime startDate, DateTime? endDate}) async {
    try {
      endDate ??= DateTime.now();

      final ridesQuery = await _firestore
          .collection('rides')
          .where('passengerId', isEqualTo: passengerId)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      double totalSpent = 0.0;
      double totalSavings = 0.0;
      int totalRides = ridesQuery.docs.length;
      int ratingsGiven = 0;
      int sharedRides = 0;

      for (final doc in ridesQuery.docs) {
        final data = doc.data();
        totalSpent += (data['fare'] ?? 0.0);
        totalSavings += (data['discount'] ?? 0.0);
        
        if (data['passengerRating'] != null) {
          ratingsGiven++;
        }
        
        if (data['isShared'] == true) {
          sharedRides++;
        }
      }

      return {
        'totalRides': totalRides,
        'totalSpent': totalSpent,
        'totalSavings': totalSavings,
        'ratingsGiven': ratingsGiven,
        'sharedRides': sharedRides,
      };
    } catch (e) {
      LoggerService.error(' Erro ao obter estatísticas de período: $e', context: 'passenger_goals_service');
      return {};
    }
  }
}