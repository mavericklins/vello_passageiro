import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vello_points.dart';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

class VelloPointsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collections
  static const String _walletsCollection = 'wallets';
  static const String _pointsTransactionsCollection = 'points_transactions';

  // Obter carteira do usuário
  Future<VelloWallet?> getUserWallet(String userId) async {
    try {
      final doc = await _firestore
          .collection(_walletsCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return VelloWallet.fromMap(doc.data()!);
      }
      
      // Se não existe, criar nova carteira
      return await _createNewWallet(userId);
    } catch (e) {
      LoggerService.info('Erro ao obter carteira: $e', context: context ?? 'UNKNOWN');
      return null;
    }
  }

  // Criar nova carteira
  Future<VelloWallet> _createNewWallet(String userId) async {
    final wallet = VelloWallet(
      userId: userId,
      totalPoints: 0.0,
      totalEarned: 0.0,
      totalRedeemed: 0.0,
      lastUpdated: DateTime.now(),
      recentTransactions: [],
    );

    await _firestore
        .collection(_walletsCollection)
        .doc(userId)
        .set(wallet.toMap());

    return wallet;
  }

  // Adicionar pontos (viagem, avaliação, indicação)
  Future<bool> addPoints(VelloPoints points) async {
    try {
      final batch = _firestore.batch();

      // Adicionar transação
      final transactionRef = _firestore
          .collection(_pointsTransactionsCollection)
          .doc(points.id);
      batch.set(transactionRef, points.toMap());

      // Atualizar carteira
      final walletRef = _firestore
          .collection(_walletsCollection)
          .doc(points.userId);
      
      batch.update(walletRef, {
        'totalEarned': FieldValue.increment(points.amount),
        'totalPoints': FieldValue.increment(points.amount),
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      await batch.commit();
      return true;
    } catch (e) {
      LoggerService.info('Erro ao adicionar pontos: $e', context: context ?? 'UNKNOWN');
      return false;
    }
  }

  // Resgatar pontos (usar para desconto)
  Future<bool> redeemPoints(VelloPoints redemption) async {
    try {
      final wallet = await getUserWallet(redemption.userId);
      if (wallet == null || wallet.availableBalance < redemption.amount.abs()) {
        return false; // Saldo insuficiente
      }

      final batch = _firestore.batch();

      // Adicionar transação de resgate
      final transactionRef = _firestore
          .collection(_pointsTransactionsCollection)
          .doc(redemption.id);
      batch.set(transactionRef, redemption.toMap());

      // Atualizar carteira
      final walletRef = _firestore
          .collection(_walletsCollection)
          .doc(redemption.userId);
      
      batch.update(walletRef, {
        'totalRedeemed': FieldValue.increment(redemption.amount.abs()),
        'totalPoints': FieldValue.increment(redemption.amount), // Negativo
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      await batch.commit();
      return true;
    } catch (e) {
      LoggerService.info('Erro ao resgatar pontos: $e', context: context ?? 'UNKNOWN');
      return false;
    }
  }

  // Obter histórico de transações
  Future<List<VelloPoints>> getTransactionHistory(String userId, {int limit = 20}) async {
    try {
      final query = await _firestore
          .collection(_pointsTransactionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => VelloPoints.fromMap(doc.data()))
          .toList();
    } catch (e) {
      LoggerService.info('Erro ao obter histórico: $e', context: context ?? 'UNKNOWN');
      return [];
    }
  }

  // Stream da carteira para atualizações em tempo real
  Stream<VelloWallet?> walletStream(String userId) {
    return _firestore
        .collection(_walletsCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return VelloWallet.fromMap(doc.data()!);
          }
          return null;
        });
  }

  // Calcular pontos por viagem baseado no valor
  double calculateRidePoints(double rideValue) {
    // 1 ponto a cada R$ 2,00 gastos + 50 pontos base
    const basePoints = 50.0;
    final valuePoints = (rideValue / 2.0).floor().toDouble();
    return basePoints + valuePoints;
  }

  // Calcular desconto baseado em pontos
  double calculateDiscount(double points) {
    // 100 pontos = R$ 5,00 de desconto
    return (points / 100.0) * 5.0;
  }

  // Processar pontos após completar viagem
  Future<void> processRideCompletion({
    required String userId,
    required String rideId,
    required double rideValue,
    double? rating,
  }) async {
    try {
      final pointsFromRide = calculateRidePoints(rideValue);
      
      // Pontos da viagem
      final ridePoints = VelloPoints.fromRide(
        id: '${rideId}_ride_points',
        userId: userId,
        rideId: rideId,
        points: pointsFromRide,
      );
      
      await addPoints(ridePoints);

      // Bônus por avaliação 5 estrelas
      if (rating != null && rating >= 5.0) {
        final ratingPoints = VelloPoints.fromRating(
          id: '${rideId}_rating_bonus',
          userId: userId,
          rideId: rideId,
          rating: rating,
        );
        
        await addPoints(ratingPoints);
      }
    } catch (e) {
      LoggerService.info('Erro ao processar pontos da viagem: $e', context: context ?? 'UNKNOWN');
    }
  }

  // Aplicar desconto usando pontos
  Future<double> applyPointsDiscount({
    required String userId,
    required String rideId,
    required double rideValue,
    required double pointsToUse,
  }) async {
    try {
      final wallet = await getUserWallet(userId);
      if (wallet == null || wallet.availableBalance < pointsToUse) {
        return 0.0; // Saldo insuficiente
      }

      final discountValue = calculateDiscount(pointsToUse);
      final finalDiscount = discountValue > rideValue ? rideValue : discountValue;
      
      final redemption = VelloPoints.fromRedemption(
        id: '${rideId}_discount',
        userId: userId,
        pointsUsed: pointsToUse,
        discountValue: finalDiscount,
        rideId: rideId,
      );

      final success = await redeemPoints(redemption);
      return success ? finalDiscount : 0.0;
    } catch (e) {
      LoggerService.info('Erro ao aplicar desconto: $e', context: context ?? 'UNKNOWN');
      return 0.0;
    }
  }
}