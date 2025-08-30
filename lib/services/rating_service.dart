import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

class RideRating {
  final String id;
  final String rideId;
  final String passengerId;
  final String driverId;
  final int rating; // 1-5 estrelas
  final String? comment;
  final List<String> tags; // ex: ["Pontual", "Educado", "Carro limpo"]
  final DateTime createdAt;
  final bool wouldRecommend;
  
  RideRating({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.driverId,
    required this.rating,
    this.comment,
    required this.tags,
    required this.createdAt,
    required this.wouldRecommend,
  });
  
  factory RideRating.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RideRating(
      id: doc.id,
      rideId: data['rideId'] ?? '',
      passengerId: data['passengerId'] ?? '',
      driverId: data['driverId'] ?? '',
      rating: data['rating'] ?? 5,
      comment: data['comment'],
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      wouldRecommend: data['wouldRecommend'] ?? true,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'rideId': rideId,
      'passengerId': passengerId,
      'driverId': driverId,
      'rating': rating,
      'comment': comment,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'wouldRecommend': wouldRecommend,
    };
  }
  
  String get ratingText {
    switch (rating) {
      case 1:
        return 'Muito ruim';
      case 2:
        return 'Ruim';
      case 3:
        return 'Regular';
      case 4:
        return 'Bom';
      case 5:
        return 'Excelente';
      default:
        return 'Sem avaliação';
    }
  }
}

class RatingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static String get _userId => _auth.currentUser!.uid;
  
  static CollectionReference get _ratingsCollection =>
      _firestore.collection('avaliacoes');
  
  // Tags pré-definidas para avaliação
  static const List<String> availableTags = [
    'Pontual',
    'Educado',
    'Carro limpo',
    'Direção segura',
    'Música boa',
    'Ar condicionado',
    'Conversação agradável',
    'Silencioso',
    'Profissional',
    'Prestativo',
  ];
  
  // Avaliar motorista
  static Future<bool> rateDriver({
    required String rideId,
    required String driverId,
    required int rating,
    String? comment,
    required List<String> tags,
    required bool wouldRecommend,
  }) async {
    try {
      final rideRating = RideRating(
        id: '',
        rideId: rideId,
        passengerId: _userId,
        driverId: driverId,
        rating: rating,
        comment: comment,
        tags: tags,
        createdAt: DateTime.now(),
        wouldRecommend: wouldRecommend,
      );
      
      await _ratingsCollection.add(rideRating.toFirestore());
      
      // Atualizar status da corrida para incluir avaliação
      await _firestore.collection('corridas').doc(rideId).update({
        'rated': true,
        'rating': rating,
      });
      
      return true;
    } catch (e) {
      LoggerService.info('Erro ao avaliar motorista: $e', context: context ?? 'UNKNOWN');
      return false;
    }
  }
  
  // Verificar se corrida já foi avaliada
  static Future<bool> hasRatedRide(String rideId) async {
    try {
      final query = await _ratingsCollection
          .where('rideId', isEqualTo: rideId)
          .where('passengerId', isEqualTo: _userId)
          .get();
          
      return query.docs.isNotEmpty;
    } catch (e) {
      LoggerService.info('Erro ao verificar avaliação: $e', context: context ?? 'UNKNOWN');
      return false;
    }
  }
  
  // Obter avaliação de uma corrida
  static Future<RideRating?> getRideRating(String rideId) async {
    try {
      final query = await _ratingsCollection
          .where('rideId', isEqualTo: rideId)
          .where('passengerId', isEqualTo: _userId)
          .limit(1)
          .get();
          
      if (query.docs.isNotEmpty) {
        return RideRating.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      LoggerService.info('Erro ao buscar avaliação: $e', context: context ?? 'UNKNOWN');
      return null;
    }
  }
  
  // Listar todas as avaliações do usuário
  static Stream<List<RideRating>> getUserRatings() {
    return _ratingsCollection
        .where('passengerId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RideRating.fromFirestore(doc))
            .toList());
  }
  
  // Obter estatísticas das avaliações do usuário
  static Future<RatingStats> getUserRatingStats() async {
    try {
      final query = await _ratingsCollection
          .where('passengerId', isEqualTo: _userId)
          .get();
          
      if (query.docs.isEmpty) {
        return RatingStats(
          totalRatings: 0,
          averageRating: 0,
          ratingDistribution: {},
          commonTags: [],
        );
      }
      
      final ratings = query.docs.map((doc) => RideRating.fromFirestore(doc)).toList();
      
      // Calcular distribuição das avaliações
      Map<int, int> distribution = {};
      double totalRating = 0;
      Map<String, int> tagCount = {};
      
      for (final rating in ratings) {
        distribution[rating.rating] = (distribution[rating.rating] ?? 0) + 1;
        totalRating += rating.rating;
        
        for (final tag in rating.tags) {
          tagCount[tag] = (tagCount[tag] ?? 0) + 1;
        }
      }
      
      // Tags mais comuns
      final commonTags = tagCount.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value))
          ..take(5);
      
      return RatingStats(
        totalRatings: ratings.length,
        averageRating: totalRating / ratings.length,
        ratingDistribution: distribution,
        commonTags: commonTags.map((e) => e.key).toList(),
      );
    } catch (e) {
      LoggerService.info('Erro ao calcular estatísticas: $e', context: context ?? 'UNKNOWN');
      return RatingStats(
        totalRatings: 0,
        averageRating: 0,
        ratingDistribution: {},
        commonTags: [],
      );
    }
  }
}

class RatingStats {
  final int totalRatings;
  final double averageRating;
  final Map<int, int> ratingDistribution;
  final List<String> commonTags;
  
  RatingStats({
    required this.totalRatings,
    required this.averageRating,
    required this.ratingDistribution,
    required this.commonTags,
  });
  
  String get formattedAverage => averageRating.toStringAsFixed(1);
}