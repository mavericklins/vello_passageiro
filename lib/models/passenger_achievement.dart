import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de conquistas para passageiros
class PassengerAchievement {
  final String id;
  final String titulo;
  final String descricao;
  final String icone;
  final DateTime conquistadoEm;
  final int pontos;

  const PassengerAchievement({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.conquistadoEm,
    required this.pontos,
  });

  factory PassengerAchievement.fromMap(Map<String, dynamic> map) {
    return PassengerAchievement(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      icone: map['icone'] ?? '🏆',
      conquistadoEm: (map['conquistadoEm'] as Timestamp).toDate(),
      pontos: map['pontos'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'icone': icone,
      'conquistadoEm': Timestamp.fromDate(conquistadoEm),
      'pontos': pontos,
    };
  }
}

/// Modelo de metas e gamificação para passageiros
class PassengerGoals {
  final String id;
  final String passageiroId;
  final List<PassengerAchievement> conquistas;
  final int pontuacao;
  final int nivel;
  final Map<String, dynamic> estatisticas;
  final Timestamp atualizadoEm;

  const PassengerGoals({
    required this.id,
    required this.passageiroId,
    required this.conquistas,
    required this.pontuacao,
    required this.nivel,
    required this.estatisticas,
    required this.atualizadoEm,
  });

  factory PassengerGoals.empty() => PassengerGoals(
    id: '',
    passageiroId: '',
    conquistas: const [],
    pontuacao: 0,
    nivel: 1,
    estatisticas: const {},
    atualizadoEm: Timestamp.now(),
  );

  factory PassengerGoals.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PassengerGoals(
      id: doc.id,
      passageiroId: data['passengerId'] ?? '',
      conquistas: (data['achievements'] as List<dynamic>? ?? [])
          .map((achievementId) => PassengerAchievement(
                id: achievementId,
                titulo: 'Conquista',
                descricao: 'Conquista desbloqueada',
                icone: '🏆',
                conquistadoEm: DateTime.now(),
                pontos: 10,
              ))
          .toList(),
      pontuacao: data['totalXP'] ?? 0,
      nivel: data['level'] ?? 1,
      estatisticas: {
        'totalTrips': data['totalTrips'] ?? 0,
        'totalSpent': data['totalSpent'] ?? 0.0,
        'favoriteDestinations': data['favoriteDestinations'] ?? [],
        'avgRating': data['avgRating'] ?? 0.0,
      },
      atualizadoEm: data['updatedAt'] ?? Timestamp.now(),
    );
  }
}