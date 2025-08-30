import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';

/// Tipos de card Vello Premium
enum VelloCardType {
  standard,
  elevated,
  outlined,
  gradient,
  glass, // Novo tipo glass
}

/// Card padronizado do Vello Passageiro Premium
/// Implementa design system consistente com glass effect
class VelloCard extends StatelessWidget {
  final Widget child;
  final VelloCardType type;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Border? border;
  final bool glass;

  const VelloCard({
    Key? key,
    required this.child,
    this.type = VelloCardType.standard,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.gradient,
    this.border,
    this.glass = false,
  }) : super(key: key);

  /// Card padrão premium
  const VelloCard.standard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
  }) : type = VelloCardType.standard,
       elevation = null,
       borderRadius = null,
       gradient = null,
       border = null,
       glass = false,
       super(key: key);

  /// Card elevado premium
  const VelloCard.elevated({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation = 4,
  }) : type = VelloCardType.elevated,
       borderRadius = null,
       gradient = null,
       border = null,
       glass = false,
       super(key: key);

  /// Card com borda premium
  const VelloCard.outlined({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.border,
  }) : type = VelloCardType.outlined,
       elevation = null,
       borderRadius = null,
       gradient = null,
       glass = false,
       super(key: key);

  /// Card com gradiente premium
  const VelloCard.gradient({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.gradient,
  }) : type = VelloCardType.gradient,
       backgroundColor = null,
       elevation = null,
       borderRadius = null,
       border = null,
       glass = false,
       super(key: key);

  /// Card glass (para HUD sobre mapa)
  const VelloCard.glass({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  }) : type = VelloCardType.glass,
       backgroundColor = null,
       elevation = null,
       borderRadius = null,
       gradient = null,
       border = null,
       glass = true,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBorderRadius = borderRadius ?? VelloTokens.radiusLarge;
    final cardPadding = padding ?? const EdgeInsets.all(VelloTokens.spaceM);
    final cardMargin = margin ?? EdgeInsets.zero;

    Widget cardContent = Container(
      padding: cardPadding,
      decoration: _getDecoration(theme),
      child: child,
    );

    // Aplicar glass effect se necessário
    if (glass || type == VelloCardType.glass) {
      cardContent = ClipRRect(
        borderRadius: cardBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: cardPadding,
            decoration: _getGlassDecoration(theme),
            child: child,
          ),
        ),
      );
    }

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: cardBorderRadius,
          child: cardContent,
        ),
      );
    }

    return Container(
      margin: cardMargin,
      child: _wrapWithElevation(cardContent, cardBorderRadius, theme),
    );
  }

  Widget _wrapWithElevation(Widget content, BorderRadius borderRadius, ThemeData theme) {
    if (type == VelloCardType.elevated && elevation != null && elevation! > 0) {
      return Material(
        elevation: elevation!,
        borderRadius: borderRadius,
        shadowColor: theme.colorScheme.shadow,
        surfaceTintColor: Colors.transparent,
        color: Colors.transparent,
        child: content,
      );
    }
    return content;
  }

  BoxDecoration _getDecoration(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    switch (type) {
      case VelloCardType.standard:
        return BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.surface,
          borderRadius: borderRadius ?? VelloTokens.radiusLarge,
          boxShadow: VelloTokens.elevationLow,
        );

      case VelloCardType.elevated:
        return BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.surface,
          borderRadius: borderRadius ?? VelloTokens.radiusLarge,
          boxShadow: VelloTokens.elevationMedium,
        );

      case VelloCardType.outlined:
        return BoxDecoration(
          color: backgroundColor ?? theme.colorScheme.surface,
          borderRadius: borderRadius ?? VelloTokens.radiusLarge,
          border: border ?? Border.all(
            color: theme.colorScheme.outline.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: VelloTokens.elevationLow,
        );

      case VelloCardType.gradient:
        return BoxDecoration(
          gradient: gradient ?? LinearGradient(
            colors: [VelloTokens.brand, VelloTokens.brandLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: borderRadius ?? VelloTokens.radiusLarge,
          boxShadow: [
            BoxShadow(
              color: VelloTokens.brand.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case VelloCardType.glass:
        return _getGlassDecoration(theme);
    }
  }

  BoxDecoration _getGlassDecoration(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return BoxDecoration(
      color: isDark 
        ? VelloTokens.glassBackgroundDark.withOpacity(0.85)
        : VelloTokens.glassBackground.withOpacity(0.85),
      borderRadius: borderRadius ?? VelloTokens.radiusLarge,
      border: Border.all(
        color: (isDark ? VelloTokens.white : VelloTokens.black).withOpacity(0.1),
        width: 1,
      ),
      boxShadow: VelloTokens.elevationMedium,
    );
  }
}

/// Card específico premium para informações do passageiro
class VelloPassengerCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDivider;
  final VelloCardType cardType;

  const VelloPassengerCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.onTap,
    this.trailing,
    this.showDivider = false,
    this.cardType = VelloCardType.standard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return VelloCard(
      type: cardType,
      onTap: onTap,
      padding: const EdgeInsets.all(VelloTokens.spaceL),
      child: Column(
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (iconColor ?? VelloTokens.brand).withOpacity(0.15),
                        (iconColor ?? VelloTokens.brand).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: VelloTokens.radiusMedium,
                    border: Border.all(
                      color: (iconColor ?? VelloTokens.brand).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? VelloTokens.brand,
                    size: 24,
                  ),
                ),
                const SizedBox(width: VelloTokens.spaceM),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: VelloTokens.spaceM),
                trailing!,
              ],
              if (onTap != null) ...[
                const SizedBox(width: VelloTokens.spaceS),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: VelloTokens.spaceL),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.outline.withOpacity(0),
                    theme.colorScheme.outline.withOpacity(0.5),
                    theme.colorScheme.outline.withOpacity(0),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}