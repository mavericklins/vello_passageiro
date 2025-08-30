import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoMetaPassageiro {
  corridas,        // Corridas solicitadas
  economia,        // Economia em dinheiro
  avaliacao,       // Avaliações dadas
  uso_app,         // Frequência de uso do app
  tempo_espera,    // Redução de tempo de espera
  eco_friendly,    // Corridas ecológicas
  pontuacao,       // Pontos no sistema
  horario_pico,    // Evitar horários de pico
}

enum CategoriaMetaPassageiro {
  produtividade,   // Uso eficiente do app
  economia,        // Economizar dinheiro
  habito,          // Criar hábitos de uso
  qualidade,       // Qualidade da experiência
  sustentabilidade, // Impacto ambiental
  social,          // Interações sociais
}

enum DificuldadeMetaPassageiro {
  facil,
  media,
  dificil,
}

enum StatusMetaPassageiro {
  ativa,
  concluida,
  pausada,
}

class PassengerMetaInteligente {
  final String id;
  final String titulo;
  final String descricao;
  final TipoMetaPassageiro tipo;
  final CategoriaMetaPassageiro categoria;
  final double valorObjetivo;
  double valorAtual;
  final double valorAlvo;
  final String recompensa;
  final DateTime dataInicio;
  final DateTime dataFim;
  final DateTime prazo;
  final bool isAtiva;
  final bool completada;
  final DificuldadeMetaPassageiro dificuldade;
  final StatusMetaPassageiro status;

  PassengerMetaInteligente({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.categoria,
    required this.valorObjetivo,
    this.valorAtual = 0.0,
    required this.valorAlvo,
    required this.recompensa,
    required this.dataInicio,
    required this.dataFim,
    required this.prazo,
    this.isAtiva = true,
    this.completada = false,
    this.dificuldade = DificuldadeMetaPassageiro.media,
    this.status = StatusMetaPassageiro.ativa,
  });

  double get progresso {
    if (valorObjetivo <= 0) return 0.0;
    return (valorAtual / valorObjetivo).clamp(0.0, 1.0);
  }

  bool get isVencida => DateTime.now().isAfter(prazo) && !completada;

  int get diasRestantes {
    final agora = DateTime.now();
    if (agora.isAfter(prazo)) return 0;
    return prazo.difference(agora).inDays;
  }

  String get statusTexto {
    if (completada) return 'Concluída';
    if (isVencida) return 'Vencida';
    if (!isAtiva) return 'Pausada';
    return 'Ativa';
  }

  String get progressoTexto {
    return '${valorAtual.toStringAsFixed(0)}/${valorObjetivo.toStringAsFixed(0)}';
  }

  String get progressoPercentual {
    return '${(progresso * 100).toStringAsFixed(0)}%';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'tipo': tipo.toString(),
      'categoria': categoria.toString(),
      'valorObjetivo': valorObjetivo,
      'valorAtual': valorAtual,
      'valorAlvo': valorAlvo,
      'recompensa': recompensa,
      'dataInicio': dataInicio.toIso8601String(),
      'dataFim': dataFim.toIso8601String(),
      'prazo': prazo.toIso8601String(),
      'isAtiva': isAtiva,
      'completada': completada,
      'dificuldade': dificuldade.toString(),
      'status': status.toString(),
    };
  }

  factory PassengerMetaInteligente.fromJson(Map<String, dynamic> json) {
    return PassengerMetaInteligente(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      tipo: TipoMetaPassageiro.values.firstWhere((e) => e.toString() == json['tipo']),
      categoria: CategoriaMetaPassageiro.values.firstWhere((e) => e.toString() == json['categoria']),
      valorObjetivo: json['valorObjetivo'].toDouble(),
      valorAtual: json['valorAtual']?.toDouble() ?? 0.0,
      valorAlvo: json['valorAlvo']?.toDouble() ?? 0.0,
      recompensa: json['recompensa'],
      dataInicio: DateTime.parse(json['dataInicio']),
      dataFim: DateTime.parse(json['dataFim']),
      prazo: DateTime.parse(json['prazo']),
      isAtiva: json['isAtiva'] ?? true,
      completada: json['completada'] ?? false,
      dificuldade: DificuldadeMetaPassageiro.values.firstWhere((e) => e.toString() == json['dificuldade']),
      status: StatusMetaPassageiro.values.firstWhere((e) => e.toString() == (json['status'] ?? 'StatusMetaPassageiro.ativa')),
    );
  }

  factory PassengerMetaInteligente.fromFirestore(String docId, Map<String, dynamic> data) {
    return PassengerMetaInteligente(
      id: docId,
      titulo: data['title'] ?? '',
      descricao: data['description'] ?? '',
      tipo: _parseTipoMeta(data['type']),
      categoria: _parseCategoriaMeta(data['category']),
      valorObjetivo: (data['targetValue'] ?? 0.0).toDouble(),
      valorAtual: (data['currentValue'] ?? 0.0).toDouble(),
      valorAlvo: (data['targetValue'] ?? 0.0).toDouble(),
      recompensa: data['reward'] ?? '',
      dataInicio: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dataFim: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(Duration(days: 7)),
      prazo: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(Duration(days: 7)),
      isAtiva: data['isActive'] ?? true,
      completada: data['isCompleted'] ?? false,
      dificuldade: DificuldadeMetaPassageiro.media,
      status: data['isCompleted'] == true ? StatusMetaPassageiro.concluida : StatusMetaPassageiro.ativa,
    );
  }

  static TipoMetaPassageiro _parseTipoMeta(String? type) {
    switch (type) {
      case 'rides':
        return TipoMetaPassageiro.corridas;
      case 'savings':
        return TipoMetaPassageiro.economia;
      case 'rating':
        return TipoMetaPassageiro.avaliacao;
      case 'app_usage':
        return TipoMetaPassageiro.uso_app;
      case 'wait_time':
        return TipoMetaPassageiro.tempo_espera;
      case 'eco_friendly':
        return TipoMetaPassageiro.eco_friendly;
      case 'points':
        return TipoMetaPassageiro.pontuacao;
      case 'peak_hours':
        return TipoMetaPassageiro.horario_pico;
      default:
        return TipoMetaPassageiro.corridas;
    }
  }

  static CategoriaMetaPassageiro _parseCategoriaMeta(String? category) {
    switch (category) {
      case 'productivity':
        return CategoriaMetaPassageiro.produtividade;
      case 'economy':
        return CategoriaMetaPassageiro.economia;
      case 'habit':
        return CategoriaMetaPassageiro.habito;
      case 'quality':
        return CategoriaMetaPassageiro.qualidade;
      case 'sustainability':
        return CategoriaMetaPassageiro.sustentabilidade;
      case 'social':
        return CategoriaMetaPassageiro.social;
      default:
        return CategoriaMetaPassageiro.produtividade;
    }
  }

  PassengerMetaInteligente copyWith({
    String? id,
    String? titulo,
    String? descricao,
    TipoMetaPassageiro? tipo,
    CategoriaMetaPassageiro? categoria,
    double? valorObjetivo,
    double? valorAtual,
    double? valorAlvo,
    String? recompensa,
    DateTime? dataInicio,
    DateTime? dataFim,
    DateTime? prazo,
    bool? isAtiva,
    bool? completada,
    DificuldadeMetaPassageiro? dificuldade,
    StatusMetaPassageiro? status,
  }) {
    return PassengerMetaInteligente(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
      valorObjetivo: valorObjetivo ?? this.valorObjetivo,
      valorAtual: valorAtual ?? this.valorAtual,
      valorAlvo: valorAlvo ?? this.valorAlvo,
      recompensa: recompensa ?? this.recompensa,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      prazo: prazo ?? this.prazo,
      isAtiva: isAtiva ?? this.isAtiva,
      completada: completada ?? this.completada,
      dificuldade: dificuldade ?? this.dificuldade,
      status: status ?? this.status,
    );
  }
}