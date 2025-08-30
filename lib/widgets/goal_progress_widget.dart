import 'package:flutter/material.dart';
import '../models/passenger_meta_inteligente.dart';
import '../theme/vello_tokens.dart';

class GoalProgressWidget extends StatelessWidget {
  final PassengerMetaInteligente meta;
  final bool isCompleted;

  const GoalProgressWidget({
    super.key,
    required this.meta,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = meta.valorAlvo == 0 ? 0.0 : (meta.valorAtual / meta.valorAlvo).clamp(0.0, 1.0);
    final progressColor = isCompleted
        ? Colors.green
        : progress >= 0.8
            ? Colors.green
            : progress >= 0.5
                ? Colors.orange
                : VelloTokens.brandBlueDark;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VelloTokens.brandBlue,
        borderRadius: BorderRadius.circular(12),
        border: isCompleted
            ? Border.all(color: Colors.green, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _getGoalIcon(meta.tipo),
                    color: isCompleted ? Colors.green : VelloTokens.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      meta.titulo,
                      style: TextStyle(
                        color: VelloTokens.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (isCompleted)
                Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
          SizedBox(height: 8),
          Text(
            meta.descricao,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(height: 12),
          Text(
            '${_formatMetaValue(meta.tipo, meta.valorAtual)} / ${_formatMetaValue(meta.tipo, meta.valorAlvo)}',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% completo',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                'Prazo: ${_formatDeadline(meta.prazo)}',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.card_giftcard, color: Colors.amber, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recompensa: ${meta.recompensa}',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGoalIcon(TipoMetaPassageiro tipo) {
    switch (tipo) {
      case TipoMetaPassageiro.corridas:
        return Icons.local_taxi;
      case TipoMetaPassageiro.economia:
        return Icons.savings;
      case TipoMetaPassageiro.avaliacao:
        return Icons.star;
      case TipoMetaPassageiro.uso_app:
        return Icons.smartphone;
      case TipoMetaPassageiro.tempo_espera:
        return Icons.schedule;
      case TipoMetaPassageiro.eco_friendly:
        return Icons.eco;
      case TipoMetaPassageiro.pontuacao:
        return Icons.emoji_events;
      case TipoMetaPassageiro.horario_pico:
        return Icons.traffic;
    }
  }

  String _formatMetaValue(TipoMetaPassageiro tipo, double valor) {
    switch (tipo) {
      case TipoMetaPassageiro.corridas:
        return '${valor.toInt()} corridas';
      case TipoMetaPassageiro.economia:
        return 'R\$ ${valor.toStringAsFixed(2)}';
      case TipoMetaPassageiro.avaliacao:
        return '${valor.toInt()} avaliações';
      case TipoMetaPassageiro.uso_app:
        return '${valor.toInt()} dias';
      case TipoMetaPassageiro.tempo_espera:
        return '${valor.toInt()} min';
      case TipoMetaPassageiro.eco_friendly:
        return '${valor.toInt()} corridas';
      case TipoMetaPassageiro.pontuacao:
        return '${valor.toInt()} pontos';
      case TipoMetaPassageiro.horario_pico:
        return '${valor.toInt()} evitadas';
    }
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return 'Expirado';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} dias';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inMinutes}min';
    }
  }
}