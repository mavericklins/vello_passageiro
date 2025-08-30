import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pricing_service.dart';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

enum PromotionType { 
  firstRide, // Primeira viagem
  referral,  // Indicação
  seasonal,  // Sazonal
  general,   // Geral
  birthday,  // Aniversário
  loyalty    // Fidelidade
}

class Promotion {
  final String id;
  final String title;
  final String description;
  final String code;
  final PromotionType type;
  final DiscountType discountType;
  final double discountValue;
  final double? maxDiscount;
  final double? minOrderValue;
  final DateTime startDate;
  final DateTime endDate;
  final int? usageLimit;
  final int usageCount;
  final bool isActive;
  final String? imageUrl;
  final List<String> targetUserIds; // Vazio = para todos
  
  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.type,
    required this.discountType,
    required this.discountValue,
    this.maxDiscount,
    this.minOrderValue,
    required this.startDate,
    required this.endDate,
    this.usageLimit,
    required this.usageCount,
    required this.isActive,
    this.imageUrl,
    required this.targetUserIds,
  });
  
  factory Promotion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Promotion(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      code: data['code'] ?? '',
      type: PromotionType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => PromotionType.general,
      ),
      discountType: DiscountType.values.firstWhere(
        (t) => t.name == data['discountType'],
        orElse: () => DiscountType.percentage,
      ),
      discountValue: (data['discountValue'] as num).toDouble(),
      maxDiscount: data['maxDiscount']?.toDouble(),
      minOrderValue: data['minOrderValue']?.toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      usageLimit: data['usageLimit'],
      usageCount: data['usageCount'] ?? 0,
      isActive: data['isActive'] ?? true,
      imageUrl: data['imageUrl'],
      targetUserIds: List<String>.from(data['targetUserIds'] ?? []),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'code': code,
      'type': type.name,
      'discountType': discountType.name,
      'discountValue': discountValue,
      'maxDiscount': maxDiscount,
      'minOrderValue': minOrderValue,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'targetUserIds': targetUserIds,
    };
  }
  
  bool get isValid {
    final now = DateTime.now();
    return isActive &&
           now.isAfter(startDate) &&
           now.isBefore(endDate) &&
           (usageLimit == null || usageCount < usageLimit!);
  }
  
  bool isValidForUser(String userId) {
    return isValid && (targetUserIds.isEmpty || targetUserIds.contains(userId));
  }
  
  String get formattedDiscount {
    if (discountType == DiscountType.percentage) {
      return '${discountValue.toInt()}% OFF';
    } else {
      return 'R\$ ${discountValue.toStringAsFixed(2).replaceAll('.', ',')} OFF';
    }
  }
  
  String get typeDisplay {
    switch (type) {
      case PromotionType.firstRide:
        return 'Primeira Viagem';
      case PromotionType.referral:
        return 'Indicação';
      case PromotionType.seasonal:
        return 'Oferta Sazonal';
      case PromotionType.general:
        return 'Promoção Geral';
      case PromotionType.birthday:
        return 'Aniversário';
      case PromotionType.loyalty:
        return 'Fidelidade';
    }
  }
}

class UserPromotion {
  final String id;
  final String userId;
  final String promotionId;
  final String promotionCode;
  final DateTime usedAt;
  final String rideId;
  final double discountApplied;
  
  UserPromotion({
    required this.id,
    required this.userId,
    required this.promotionId,
    required this.promotionCode,
    required this.usedAt,
    required this.rideId,
    required this.discountApplied,
  });
  
  factory UserPromotion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserPromotion(
      id: doc.id,
      userId: data['userId'] ?? '',
      promotionId: data['promotionId'] ?? '',
      promotionCode: data['promotionCode'] ?? '',
      usedAt: (data['usedAt'] as Timestamp).toDate(),
      rideId: data['rideId'] ?? '',
      discountApplied: (data['discountApplied'] as num).toDouble(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'promotionId': promotionId,
      'promotionCode': promotionCode,
      'usedAt': Timestamp.fromDate(usedAt),
      'rideId': rideId,
      'discountApplied': discountApplied,
    };
  }
}

class PromotionsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static String get _userId => _auth.currentUser!.uid;
  
  static CollectionReference get _promotionsCollection =>
      _firestore.collection('promocoes');
      
  static CollectionReference get _userPromotionsCollection =>
      _firestore.collection('promocoes_usuarios');
  
  // Listar promoções disponíveis para o usuário
  static Future<List<Promotion>> getAvailablePromotions() async {
    try {
      final now = DateTime.now();
      final query = await _promotionsCollection
          .where('isActive', isEqualTo: true)
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .where('endDate', isGreaterThan: Timestamp.fromDate(now))
          .get();
      
      final allPromotions = query.docs
          .map((doc) => Promotion.fromFirestore(doc))
          .toList();
      
      // Filtrar promoções válidas para o usuário
      final availablePromotions = <Promotion>[];
      
      for (final promotion in allPromotions) {
        if (promotion.isValidForUser(_userId)) {
          // Verificar se o usuário já usou esta promoção
          final hasUsed = await _hasUserUsedPromotion(promotion.id);
          if (!hasUsed || promotion.usageLimit == null) {
            availablePromotions.add(promotion);
          }
        }
      }
      
      return availablePromotions;
    } catch (e) {
      LoggerService.info('Erro ao buscar promoções: $e', context: context ?? 'UNKNOWN');
      return [];
    }
  }
  
  // Verificar se usuário já usou uma promoção
  static Future<bool> _hasUserUsedPromotion(String promotionId) async {
    try {
      final query = await _userPromotionsCollection
          .where('userId', isEqualTo: _userId)
          .where('promotionId', isEqualTo: promotionId)
          .get();
          
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // Validar código de cupom
  static Future<Promotion?> validateCouponCode(String code) async {
    try {
      final query = await _promotionsCollection
          .where('code', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();
          
      if (query.docs.isEmpty) return null;
      
      final promotion = Promotion.fromFirestore(query.docs.first);
      
      if (!promotion.isValidForUser(_userId)) return null;
      
      // Verificar se já foi usado
      final hasUsed = await _hasUserUsedPromotion(promotion.id);
      if (hasUsed && promotion.usageLimit != null) return null;
      
      return promotion;
    } catch (e) {
      LoggerService.info('Erro ao validar cupom: $e', context: context ?? 'UNKNOWN');
      return null;
    }
  }
  
  // Aplicar promoção
  static Future<bool> applyPromotion({
    required String promotionId,
    required String rideId,
    required double discountApplied,
  }) async {
    try {
      final promotion = await _getPromotion(promotionId);
      if (promotion == null) return false;
      
      final userPromotion = UserPromotion(
        id: '',
        userId: _userId,
        promotionId: promotionId,
        promotionCode: promotion.code,
        usedAt: DateTime.now(),
        rideId: rideId,
        discountApplied: discountApplied,
      );
      
      await _userPromotionsCollection.add(userPromotion.toFirestore());
      
      // Incrementar contador de uso da promoção
      await _promotionsCollection.doc(promotionId).update({
        'usageCount': FieldValue.increment(1),
      });
      
      return true;
    } catch (e) {
      LoggerService.info('Erro ao aplicar promoção: $e', context: context ?? 'UNKNOWN');
      return false;
    }
  }
  
  // Obter promoção específica
  static Future<Promotion?> _getPromotion(String promotionId) async {
    try {
      final doc = await _promotionsCollection.doc(promotionId).get();
      if (doc.exists) {
        return Promotion.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Listar promoções usadas pelo usuário
  static Stream<List<UserPromotion>> getUserPromotions() {
    return _userPromotionsCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('usedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserPromotion.fromFirestore(doc))
            .toList());
  }
  
  // Criar promoção personalizada (para primeira viagem, aniversário, etc.)
  static Future<void> createPersonalizedPromotions(String userId) async {
    try {
      // Verificar se é primeira viagem
      final ridesQuery = await _firestore
          .collection('corridas')
          .where('passageiroId', isEqualTo: userId)
          .limit(1)
          .get();
          
      if (ridesQuery.docs.isEmpty) {
        // Criar promoção de primeira viagem
        final firstRidePromotion = Promotion(
          id: '',
          title: 'Primeira Viagem',
          description: 'Ganhe 50% de desconto na sua primeira corrida!',
          code: 'PRIMEIRA${userId.substring(0, 6).toUpperCase()}',
          type: PromotionType.firstRide,
          discountType: DiscountType.percentage,
          discountValue: 50,
          maxDiscount: 20.0,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 30)),
          usageLimit: 1,
          usageCount: 0,
          isActive: true,
          targetUserIds: [userId],
        );
        
        await _promotionsCollection.add(firstRidePromotion.toFirestore());
      }
    } catch (e) {
      LoggerService.info('Erro ao criar promoções personalizadas: $e', context: context ?? 'UNKNOWN');
    }
  }
  
  // Obter estatísticas de promoções do usuário
  static Future<PromotionStats> getUserPromotionStats() async {
    try {
      final query = await _userPromotionsCollection
          .where('userId', isEqualTo: _userId)
          .get();
          
      if (query.docs.isEmpty) {
        return PromotionStats(
          totalPromotionsUsed: 0,
          totalSavings: 0,
          favoritePromotionType: null,
        );
      }
      
      final userPromotions = query.docs
          .map((doc) => UserPromotion.fromFirestore(doc))
          .toList();
      
      double totalSavings = 0;
      Map<PromotionType, int> typeCount = {};
      
      for (final userPromotion in userPromotions) {
        totalSavings += userPromotion.discountApplied;
        
        // Buscar tipo da promoção (simplificado)
        final promotion = await _getPromotion(userPromotion.promotionId);
        if (promotion != null) {
          typeCount[promotion.type] = (typeCount[promotion.type] ?? 0) + 1;
        }
      }
      
      PromotionType? favoriteType;
      if (typeCount.isNotEmpty) {
        favoriteType = typeCount.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }
      
      return PromotionStats(
        totalPromotionsUsed: userPromotions.length,
        totalSavings: totalSavings,
        favoritePromotionType: favoriteType,
      );
    } catch (e) {
      LoggerService.info('Erro ao calcular estatísticas: $e', context: context ?? 'UNKNOWN');
      return PromotionStats(
        totalPromotionsUsed: 0,
        totalSavings: 0,
        favoritePromotionType: null,
      );
    }
  }
}

class PromotionStats {
  final int totalPromotionsUsed;
  final double totalSavings;
  final PromotionType? favoritePromotionType;
  
  PromotionStats({
    required this.totalPromotionsUsed,
    required this.totalSavings,
    this.favoritePromotionType,
  });
  
  String get formattedSavings => 
      'R\$ ${totalSavings.toStringAsFixed(2).replaceAll('.', ',')}';
}