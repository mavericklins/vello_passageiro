import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/passenger_achievement.dart';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

/// Service de gamificação para passageiros baseado em corridas realizadas
class PassengerGamificationService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Estado básico esperado pelas telas
  int _currentLevel = 1;
  int _currentXP = 0;
  double _levelProgress = 0.0; // 0.0..1.0
  int _xpToNextLevel = 100;

  int _currentRank = 0;
  int _totalPassengers = 0;

  // Listas/estruturas usadas nas telas
  final List<Map<String, dynamic>> _achievements = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> _topPassengers = <Map<String, dynamic>>[];
  final List<Map<String, dynamic>> _weeklyChallenges = <Map<String, dynamic>>[];

  Map<String, dynamic> _dailyChallenge = <String, dynamic>{
    'title': 'Sem desafio ativo',
    'progress': 0.0,
    'current': 0,
    'target': 1,
    'reward': 0,
  };

  bool _isLoading = false;

  // Getters esperados pelas telas
  int get currentLevel => _currentLevel;
  int get currentXP => _currentXP;
  double get levelProgress => _levelProgress;
  int get xpToNextLevel => _xpToNextLevel;

  int get currentRank => _currentRank;
  int get totalPassengers => _totalPassengers;

  List<Map<String, dynamic>> get achievements => _achievements;
  List<Map<String, dynamic>> get topPassengers => _topPassengers;
  List<Map<String, dynamic>> get weeklyChallenges => _weeklyChallenges;
  Map<String, dynamic> get dailyChallenge => _dailyChallenge;
  bool get isLoading => _isLoading;

  /// Inicializa sistema de gamificação
  Future<void> initialize() async {
    return await ErrorHandler.safeAsync(() async {
      _isLoading = true;
      notifyListeners();

      await _loadPassengerGoals();
      await _loadAchievements();
      await _loadRanking();
      await _loadChallenges();

      _isLoading = false;
      notifyListeners();
      LoggerService.success('Sistema de gamificação inicializado', context: 'GAMIFICATION');
    }, context: 'gamification_initialize');
  }

  /// Carrega metas e XP do passageiro
  Future<void> _loadPassengerGoals() async {
    return await ErrorHandler.safeAsync(() async {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('passenger_goals')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _currentXP = (data['totalXP'] ?? 0);
        _currentLevel = (data['level'] ?? 1);
        _calculateLevelProgress();
      } else {
        // Criar documento inicial de metas
        await _createInitialPassengerGoals(user.uid);
      }
    }, context: 'load_passenger_goals');
  }

  /// Cria documento inicial de metas para novo passageiro
  Future<void> _createInitialPassengerGoals(String passengerId) async {
    await _firestore.collection('passenger_goals').doc(passengerId).set({
      'totalXP': 0,
      'level': 1,
      'totalTrips': 0,
      'totalSpent': 0.0,
      'achievements': [],
      'weeklyTrips': 0,
      'weeklySpent': 0.0,
      'monthlyTrips': 0,
      'monthlySpent': 0.0,
      'avgRating': 0.0,
      'favoriteDestinations': [],
      'lastResetDate': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    LoggerService.success('Metas iniciais criadas para passageiro $passengerId', context: 'GAMIFICATION');
  }

  /// Carrega conquistas do passageiro
  Future<void> _loadAchievements() async {
    return await ErrorHandler.safeAsync(() async {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('passenger_goals')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final achievementIds = List<String>.from(data['achievements'] ?? []);
        
        _achievements.clear();
        for (final achievementId in achievementIds) {
          if (availableAchievements.containsKey(achievementId)) {
            _achievements.add({
              'id': achievementId,
              ...availableAchievements[achievementId]!,
              'unlocked': true,
            });
          }
        }

        // Adicionar conquistas disponíveis não desbloqueadas
        for (final entry in availableAchievements.entries) {
          if (!achievementIds.contains(entry.key)) {
            _achievements.add({
              'id': entry.key,
              ...entry.value,
              'unlocked': false,
            });
          }
        }
      }
    }, context: 'load_achievements');
  }

  /// Carrega ranking de passageiros
  Future<void> _loadRanking() async {
    return await ErrorHandler.safeAsync(() async {
      // Buscar top 10 passageiros por XP
      final snapshot = await _firestore.collection('passenger_goals')
          .orderBy('totalXP', descending: true)
          .limit(10)
          .get();

      _topPassengers.clear();
      int rank = 1;
      final user = _auth.currentUser;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Buscar nome do passageiro
        final passengerDoc = await _firestore.collection('passengers')
            .doc(doc.id)
            .get();
        
        final passengerData = passengerDoc.data() as Map<String, dynamic>?;
        final name = passengerData?['name'] ?? 'Passageiro';

        _topPassengers.add({
          'id': doc.id,
          'nome': name,
          'xp': data['totalXP'] ?? 0,
          'rank': rank,
          'level': data['level'] ?? 1,
          'trips': data['totalTrips'] ?? 0,
        });

        // Verificar se é o passageiro atual
        if (user != null && doc.id == user.uid) {
          _currentRank = rank;
        }

        rank++;
      }

      _totalPassengers = snapshot.docs.length;
    }, context: 'load_ranking');
  }

  /// Carrega desafios semanais e diários
  Future<void> _loadChallenges() async {
    return await ErrorHandler.safeAsync(() async {
      final user = _auth.currentUser;
      if (user == null) return;

      // Obter estatísticas da semana atual
      final weekStats = await _getTripStatistics(
        passengerId: user.uid,
        startDate: _getStartOfWeek(DateTime.now()),
      );

      // Obter estatísticas do dia atual
      final dayStats = await _getTripStatistics(
        passengerId: user.uid,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      // Configurar desafio diário
      final dailyTrips = dayStats['totalTrips'] ?? 0;
      _dailyChallenge = {
        'title': 'Faça 3 viagens hoje',
        'progress': (dailyTrips / 3).clamp(0.0, 1.0),
        'current': dailyTrips,
        'target': 3,
        'reward': 25,
      };

      // Configurar desafios semanais
      final weeklyTrips = weekStats['totalTrips'] ?? 0;
      final weeklySpent = weekStats['totalSpent'] ?? 0.0;

      _weeklyChallenges.clear();
      _weeklyChallenges.addAll([
        {
          'title': 'Complete 10 viagens esta semana',
          'progress': (weeklyTrips / 10).clamp(0.0, 1.0),
          'current': weeklyTrips,
          'target': 10,
          'reward': 100,
        },
        {
          'title': 'Gaste R\$ 200 em viagens esta semana',
          'progress': (weeklySpent / 200).clamp(0.0, 1.0),
          'current': weeklySpent.toInt(),
          'target': 200,
          'reward': 75,
        },
        {
          'title': 'Mantenha avaliação acima de 4.5',
          'progress': ((weekStats['avgRating'] ?? 0.0) / 5.0).clamp(0.0, 1.0),
          'current': (weekStats['avgRating'] ?? 0.0).toInt(),
          'target': 5,
          'reward': 50,
        },
      ]);
    }, context: 'load_challenges');
  }

  /// Obtém estatísticas de viagens do passageiro
  Future<Map<String, dynamic>> _getTripStatistics({
    required String passengerId,
    DateTime? startDate,
  }) async {
    return await ErrorHandler.safeAsync(() async {
      Query query = _firestore.collection('trips')
          .where('passengerId', isEqualTo: passengerId)
          .where('status', isEqualTo: 'completed');

      if (startDate != null) {
        query = query.where('completedAt', isGreaterThan: startDate);
      }

      final snapshot = await query.get();
      
      int totalTrips = snapshot.docs.length;
      double totalSpent = 0.0;
      double totalRating = 0.0;
      int ratedTrips = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalSpent += (data['amount'] ?? 0.0).toDouble();
        
        final rating = (data['passengerRating'] ?? 0.0).toDouble();
        if (rating > 0) {
          totalRating += rating;
          ratedTrips++;
        }
      }

      return {
        'totalTrips': totalTrips,
        'totalSpent': totalSpent,
        'avgRating': ratedTrips > 0 ? totalRating / ratedTrips : 0.0,
      };
    }, context: 'get_trip_statistics', fallback: {
      'totalTrips': 0,
      'totalSpent': 0.0,
      'avgRating': 0.0,
    }) ?? {
      'totalTrips': 0,
      'totalSpent': 0.0,
      'avgRating': 0.0,
    };
  }

  /// Adiciona XP ao passageiro
  Future<void> addXP(int xp, String reason) async {
    return await ErrorHandler.safeAsync(() async {
      final user = _auth.currentUser;
      if (user == null) return;

      _currentXP += xp;
      
      // Verificar se subiu de nível
      final oldLevel = _currentLevel;
      _calculateLevelProgress();
      
      // Atualizar no Firestore
      await _firestore.collection('passenger_goals').doc(user.uid).update({
        'totalXP': _currentXP,
        'level': _currentLevel,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Se subiu de nível, verificar conquistas
      if (_currentLevel > oldLevel) {
        await _checkLevelAchievements();
      }

      notifyListeners();
      LoggerService.success('+$xp XP adicionado: $reason', context: 'GAMIFICATION');
    }, context: 'add_xp');
  }

  /// Calcula progresso do nível atual
  void _calculateLevelProgress() {
    final xpForCurrentLevel = _getXPForLevel(_currentLevel);
    final xpForNextLevel = _getXPForLevel(_currentLevel + 1);
    
    if (_currentXP >= xpForNextLevel) {
      _currentLevel++;
      _calculateLevelProgress(); // Recursivo para múltiplos níveis
      return;
    }
    
    final xpInCurrentLevel = _currentXP - xpForCurrentLevel;
    final xpNeededForLevel = xpForNextLevel - xpForCurrentLevel;
    
    _levelProgress = (xpInCurrentLevel / xpNeededForLevel).clamp(0.0, 1.0);
    _xpToNextLevel = xpForNextLevel - _currentXP;
  }

  /// Calcula XP necessário para um nível
  int _getXPForLevel(int level) {
    return (level - 1) * 100 + ((level - 1) * (level - 2) * 25);
  }

  /// Verifica conquistas de nível
  Future<void> _checkLevelAchievements() async {
    final achievementsToUnlock = <String>[];

    if (_currentLevel >= 5 && !_hasAchievement('level_5')) {
      achievementsToUnlock.add('level_5');
    }
    if (_currentLevel >= 10 && !_hasAchievement('level_10')) {
      achievementsToUnlock.add('level_10');
    }
    if (_currentLevel >= 25 && !_hasAchievement('level_25')) {
      achievementsToUnlock.add('level_25');
    }

    for (final achievement in achievementsToUnlock) {
      await _unlockAchievement(achievement);
    }
  }

  /// Verifica se passageiro tem conquista
  bool _hasAchievement(String achievementId) {
    return _achievements.any((a) => a['id'] == achievementId && a['unlocked'] == true);
  }

  /// Desbloqueia conquista
  Future<void> _unlockAchievement(String achievementId) async {
    return await ErrorHandler.safeAsync(() async {
      final user = _auth.currentUser;
      if (user == null) return;

      // Atualizar no Firestore
      await _firestore.collection('passenger_goals').doc(user.uid).update({
        'achievements': FieldValue.arrayUnion([achievementId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Atualizar localmente
      final achievement = _achievements.firstWhere((a) => a['id'] == achievementId);
      achievement['unlocked'] = true;

      // Adicionar XP da conquista
      final xpReward = availableAchievements[achievementId]?['pontos'] ?? 0;
      if (xpReward > 0) {
        await addXP(xpReward, 'Conquista: ${achievement['titulo']}');
      }

      notifyListeners();
      LoggerService.success('Conquista desbloqueada: ${achievement['titulo']}', context: 'GAMIFICATION');
    }, context: 'unlock_achievement');
  }

  /// Processa eventos de viagem para gamificação
  Future<void> processTripEvent(String eventType, Map<String, dynamic> tripData) async {
    switch (eventType) {
      case 'trip_completed':
        await _processTripCompleted(tripData);
        break;
      case 'trip_requested':
        await addXP(5, 'Viagem solicitada');
        break;
      case 'high_rating':
        await addXP(10, 'Boa avaliação dada ao motorista');
        break;
    }
  }

  /// Processa conclusão de viagem
  Future<void> _processTripCompleted(Map<String, dynamic> tripData) async {
    // XP base por viagem
    await addXP(15, 'Viagem concluída');

    // XP bônus por distância
    final distance = (tripData['distance'] ?? 0.0).toDouble();
    if (distance > 10) {
      await addXP(10, 'Viagem longa (+10km)');
    }

    // XP bônus por valor
    final amount = (tripData['amount'] ?? 0.0).toDouble();
    if (amount > 50) {
      await addXP(15, 'Viagem premium (+R\$50)');
    }

    // Verificar conquistas de viagens
    await _checkTripAchievements();
  }

  /// Verifica conquistas relacionadas a viagens
  Future<void> _checkTripAchievements() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final stats = await _getTripStatistics(passengerId: user.uid);
    final totalTrips = stats['totalTrips'] ?? 0;

    final achievementsToCheck = [
      {'id': 'first_trip', 'threshold': 1},
      {'id': 'regular_passenger', 'threshold': 10},
      {'id': 'veteran_passenger', 'threshold': 50},
      {'id': 'master_passenger', 'threshold': 100},
    ];

    for (final achievement in achievementsToCheck) {
      final id = achievement['id'] as String;
      final threshold = achievement['threshold'] as int;
      
      if (totalTrips >= threshold && !_hasAchievement(id)) {
        await _unlockAchievement(id);
      }
    }
  }

  /// Stream de metas do passageiro
  Stream<PassengerGoals?> getPassengerGoals() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }

    return _firestore.collection('passenger_goals')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return PassengerGoals.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Conquistas disponíveis para passageiros
  static const Map<String, Map<String, dynamic>> availableAchievements = {
    'first_trip': {
      'icone': '🚖',
      'titulo': 'Primeira Viagem',
      'descricao': 'Complete sua primeira viagem',
      'pontos': 10,
    },
    'regular_passenger': {
      'icone': '🎯',
      'titulo': 'Passageiro Regular',
      'descricao': 'Complete 10 viagens',
      'pontos': 25,
    },
    'veteran_passenger': {
      'icone': '⭐',
      'titulo': 'Passageiro Veterano',
      'descricao': 'Complete 50 viagens',
      'pontos': 50,
    },
    'master_passenger': {
      'icone': '🏆',
      'titulo': 'Mestre das Viagens',
      'descricao': 'Complete 100 viagens',
      'pontos': 100,
    },
    'level_5': {
      'icone': '🌟',
      'titulo': 'Nível 5',
      'descricao': 'Alcance o nível 5',
      'pontos': 50,
    },
    'level_10': {
      'icone': '💎',
      'titulo': 'Nível 10',
      'descricao': 'Alcance o nível 10',
      'pontos': 100,
    },
    'level_25': {
      'icone': '🚀',
      'titulo': 'Nível 25',
      'descricao': 'Alcance o nível 25',
      'pontos': 250,
    },
    'perfect_week': {
      'icone': '🎊',
      'titulo': 'Semana perfeita',
      'descricao': 'Complete todas as metas semanais',
      'pontos': 150,
    },
    'five_star_passenger': {
      'icone': '⭐',
      'titulo': 'Passageiro 5 Estrelas',
      'descricao': 'Mantenha avaliação 5.0 por uma semana',
      'pontos': 75,
    },
  };

  // Método auxiliar para obter início da semana
  DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysFromMonday));
  }
}