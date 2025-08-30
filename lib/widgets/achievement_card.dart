import 'package:flutter/material.dart';
import '../theme/vello_tokens.dart';
import 'common/vello_card.dart';

/// Widget de card de conquista reutilizável
class AchievementCard extends StatelessWidget {
  final Map<String, dynamic> achievement;
  final VoidCallback? onTap;

  const AchievementCard({
    Key? key,
    required this.achievement,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = achievement['unlocked'] ?? false;
    final progress = achievement['progress'] ?? 1.0;

    return VelloCard(
      type: isUnlocked ? VelloCardType.elevated : VelloCardType.standard,
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: VelloTokens.spaceM),
      child: Padding(
        padding: const EdgeInsets.all(VelloTokens.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(VelloTokens.spaceM),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? VelloTokens.success.withOpacity(0.1)
                        : VelloTokens.gray200,
                    borderRadius: VelloTokens.radiusMedium,
                    border: isUnlocked
                        ? Border.all(
                            color: VelloTokens.success.withOpacity(0.3),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Text(
                    achievement['icone'] ?? '🏆',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(width: VelloTokens.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              achievement['titulo'] ?? 'Conquista',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isUnlocked
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (isUnlocked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: VelloTokens.success,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: VelloTokens.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Concluída',
                                    style: TextStyle(
                                      color: VelloTokens.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        achievement['descricao'] ?? 'Descrição não disponível',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      if (achievement['pontos'] != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: VelloTokens.brand.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${achievement['pontos']} XP',
                            style: TextStyle(
                              color: VelloTokens.brand,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (!isUnlocked && progress < 1.0) ...[
              const SizedBox(height: VelloTokens.spaceM),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progresso',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: VelloTokens.brand,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: VelloTokens.gray200,
                      valueColor: AlwaysStoppedAnimation<Color>(VelloTokens.brand),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}