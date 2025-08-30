class VelloPoints {
  final String id;
  final String userId;
  final double amount;
  final String type; // 'earned' ou 'redeemed'
  final String source; // 'ride', 'rating', 'referral', 'redemption'
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  VelloPoints({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.source,
    required this.description,
    required this.createdAt,
    this.metadata,
  });

  factory VelloPoints.fromMap(Map<String, dynamic> map) {
    return VelloPoints(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? '',
      source: map['source'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type,
      'source': source,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Factory methods para diferentes tipos de points
  factory VelloPoints.fromRide({
    required String id,
    required String userId,
    required String rideId,
    double points = 50.0,
  }) {
    return VelloPoints(
      id: id,
      userId: userId,
      amount: points,
      type: 'earned',
      source: 'ride',
      description: 'Pontos ganhos por viagem completada',
      createdAt: DateTime.now(),
      metadata: {
        'rideId': rideId,
      },
    );
  }

  factory VelloPoints.fromRating({
    required String id,
    required String userId,
    required String rideId,
    required double rating,
    double points = 20.0,
  }) {
    return VelloPoints(
      id: id,
      userId: userId,
      amount: points,
      type: 'earned',
      source: 'rating',
      description: 'Bônus por avaliação 5 estrelas',
      createdAt: DateTime.now(),
      metadata: {
        'rideId': rideId,
        'rating': rating,
      },
    );
  }

  factory VelloPoints.fromReferral({
    required String id,
    required String userId,
    required String referredUserId,
    double points = 200.0,
  }) {
    return VelloPoints(
      id: id,
      userId: userId,
      amount: points,
      type: 'earned',
      source: 'referral',
      description: 'Pontos por indicação de amigo',
      createdAt: DateTime.now(),
      metadata: {
        'referredUserId': referredUserId,
      },
    );
  }

  factory VelloPoints.fromRedemption({
    required String id,
    required String userId,
    required double pointsUsed,
    required double discountValue,
    required String rideId,
  }) {
    return VelloPoints(
      id: id,
      userId: userId,
      amount: -pointsUsed,
      type: 'redeemed',
      source: 'redemption',
      description: 'Desconto aplicado em viagem',
      createdAt: DateTime.now(),
      metadata: {
        'rideId': rideId,
        'discountValue': discountValue,
      },
    );
  }
}

class VelloWallet {
  final String userId;
  final double totalPoints;
  final double totalEarned;
  final double totalRedeemed;
  final DateTime lastUpdated;
  final List<VelloPoints> recentTransactions;

  VelloWallet({
    required this.userId,
    required this.totalPoints,
    required this.totalEarned,
    required this.totalRedeemed,
    required this.lastUpdated,
    required this.recentTransactions,
  });

  factory VelloWallet.fromMap(Map<String, dynamic> map) {
    return VelloWallet(
      userId: map['userId'] ?? '',
      totalPoints: (map['totalPoints'] ?? 0).toDouble(),
      totalEarned: (map['totalEarned'] ?? 0).toDouble(),
      totalRedeemed: (map['totalRedeemed'] ?? 0).toDouble(),
      lastUpdated: DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(),
      recentTransactions: (map['recentTransactions'] as List<dynamic>?)
          ?.map((item) => VelloPoints.fromMap(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'totalEarned': totalEarned,
      'totalRedeemed': totalRedeemed,
      'lastUpdated': lastUpdated.toIso8601String(),
      'recentTransactions': recentTransactions.map((t) => t.toMap()).toList(),
    };
  }

  double get availableBalance => totalEarned - totalRedeemed;
}