import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';

/// Estados de viagem para StatusChip
enum RideStatus {
  waiting,
  searching,
  found,
  inProgress,
  completed,
  cancelled,
}

/// Estados do passageiro para StatusChip
enum PassengerStatus {
  online,
  offline,
  inRide,
  waiting,
}

/// Chip de status do passageiro Premium
/// Exibe estado atual com cores semânticas
class StatusChip extends StatelessWidget {
  final String? text;
  final String? label;
  final IconData? icon;
  final String? value;
  final Color? valueColor;
  final Color? labelColor;
  final Color? iconColor;
  final StatusChipType type;
  final StatusChipSize size;
  final RideStatus? rideStatus;
  final PassengerStatus? passengerStatus;
  final bool showIcon;
  final bool isCompact;
  final VoidCallback? onTap;

  const StatusChip({
    super.key,
    this.text,
    this.label,
    this.icon,
    this.value,
    this.valueColor,
    this.labelColor,
    this.iconColor,
    this.type = StatusChipType.info,
    this.size = StatusChipSize.medium,
    this.rideStatus,
    this.passengerStatus,
    this.showIcon = true,
    this.isCompact = false,
    this.onTap,
  });

  /// Chip aguardando corrida
  const StatusChip.waiting({
    Key? key,
    this.showIcon = true,
    this.isCompact = false,
    this.onTap,
  }) : text = 'Aguardando',
       label = null,
       icon = null,
       value = null,
       valueColor = null,
       labelColor = null,
       iconColor = null,
       type = StatusChipType.info,
       size = StatusChipSize.medium,
       rideStatus = RideStatus.waiting,
       passengerStatus = null,
       super(key: key);

  /// Chip buscando motorista
  const StatusChip.searching({
    Key? key,
    this.showIcon = true,
    this.isCompact = false,
    this.onTap,
  }) : text = 'Buscando Motorista',
       label = null,
       icon = null,
       value = null,
       valueColor = null,
       labelColor = null,
       iconColor = null,
       type = StatusChipType.warning,
       size = StatusChipSize.medium,
       rideStatus = RideStatus.searching,
       passengerStatus = null,
       super(key: key);

  /// Chip motorista encontrado
  const StatusChip.found({
    Key? key,
    this.showIcon = true,
    this.isCompact = false,
    this.onTap,
  }) : text = 'Motorista Encontrado',
       label = null,
       icon = null,
       value = null,
       valueColor = null,
       labelColor = null,
       iconColor = null,
       type = StatusChipType.success,
       size = StatusChipSize.medium,
       rideStatus = RideStatus.found,
       passengerStatus = null,
       super(key: key);

  /// Chip corrida em andamento
  const StatusChip.inProgress({
    Key? key,
    this.showIcon = true,
    this.isCompact = false,
    this.onTap,
  }) : text = 'Em Viagem',
       label = null,
       icon = null,
       value = null,
       valueColor = null,
       labelColor = null,
       iconColor = null,
       type = StatusChipType.success,
       size = StatusChipSize.medium,
       rideStatus = RideStatus.inProgress,
       passengerStatus = null,
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor;
    Color textColor;

    switch (type) {
      case StatusChipType.success:
        backgroundColor = VelloTokens.success.withOpacity(0.1);
        textColor = VelloTokens.success;
        break;
      case StatusChipType.warning:
        backgroundColor = VelloTokens.warning.withOpacity(0.1);
        textColor = VelloTokens.warning;
        break;
      case StatusChipType.error:
        backgroundColor = VelloTokens.danger.withOpacity(0.1);
        textColor = VelloTokens.danger;
        break;
      case StatusChipType.info:
      default:
        backgroundColor = VelloTokens.info.withOpacity(0.1);
        textColor = VelloTokens.info;
        break;
    }

    double fontSize;
    EdgeInsetsGeometry padding;

    switch (size) {
      case StatusChipSize.small:
        fontSize = 11;
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
        break;
      case StatusChipSize.large:
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        break;
      case StatusChipSize.medium:
      default:
        fontSize = 12;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
        break;
    }

    // Se é um chip com icon/label/value (formato complexo)
    if (icon != null || label != null || value != null) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: VelloTokens.radiusSmall,
          border: Border.all(
            color: textColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor ?? textColor,
                size: fontSize + 2,
              ),
              const SizedBox(width: 4),
            ],
            if (label != null) ...[
              Text(
                label!,
                style: TextStyle(
                  color: labelColor ?? textColor.withOpacity(0.7),
                  fontSize: fontSize - 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (value != null) const SizedBox(width: 4),
            ],
            if (value != null)
              Text(
                value!,
                style: TextStyle(
                  color: valueColor ?? textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      );
    }

    // Formato simples com texto/label
    final displayText = text ?? label ?? _getStatusText();
    final colors = _getStatusColors();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: colors?['background'] ?? backgroundColor,
          borderRadius: VelloTokens.radiusSmall,
          border: Border.all(
            color: (colors?['border'] ?? textColor).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon && !isCompact && _hasStatus()) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors?['indicator'] ?? textColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              displayText,
              style: TextStyle(
                color: colors?['text'] ?? textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasStatus() {
    return rideStatus != null || passengerStatus != null;
  }

  Map<String, Color>? _getStatusColors() {
    if (rideStatus != null) {
      return _getRideStatusColors();
    }
    if (passengerStatus != null) {
      return _getPassengerStatusColors();
    }
    return null;
  }

  Map<String, Color> _getRideStatusColors() {
    switch (rideStatus!) {
      case RideStatus.waiting:
        return {
          'background': VelloTokens.info.withOpacity(0.1),
          'border': VelloTokens.info,
          'text': VelloTokens.info,
          'indicator': VelloTokens.info,
        };
      case RideStatus.searching:
        return {
          'background': VelloTokens.warning.withOpacity(0.1),
          'border': VelloTokens.warning,
          'text': VelloTokens.warning,
          'indicator': VelloTokens.warning,
        };
      case RideStatus.found:
      case RideStatus.inProgress:
        return {
          'background': VelloTokens.success.withOpacity(0.1),
          'border': VelloTokens.success,
          'text': VelloTokens.success,
          'indicator': VelloTokens.success,
        };
      case RideStatus.completed:
        return {
          'background': VelloTokens.success.withOpacity(0.1),
          'border': VelloTokens.success,
          'text': VelloTokens.success,
          'indicator': VelloTokens.success,
        };
      case RideStatus.cancelled:
        return {
          'background': VelloTokens.danger.withOpacity(0.1),
          'border': VelloTokens.danger,
          'text': VelloTokens.danger,
          'indicator': VelloTokens.danger,
        };
    }
  }

  Map<String, Color> _getPassengerStatusColors() {
    switch (passengerStatus!) {
      case PassengerStatus.online:
        return {
          'background': VelloTokens.success.withOpacity(0.1),
          'border': VelloTokens.success,
          'text': VelloTokens.success,
          'indicator': VelloTokens.success,
        };
      case PassengerStatus.offline:
        return {
          'background': VelloTokens.gray300.withOpacity(0.3),
          'border': VelloTokens.gray400,
          'text': VelloTokens.gray600,
          'indicator': VelloTokens.gray400,
        };
      case PassengerStatus.inRide:
        return {
          'background': VelloTokens.brand.withOpacity(0.1),
          'border': VelloTokens.brand,
          'text': VelloTokens.brand,
          'indicator': VelloTokens.brand,
        };
      case PassengerStatus.waiting:
        return {
          'background': VelloTokens.info.withOpacity(0.1),
          'border': VelloTokens.info,
          'text': VelloTokens.info,
          'indicator': VelloTokens.info,
        };
    }
  }

  String _getStatusText() {
    if (rideStatus != null) {
      switch (rideStatus!) {
        case RideStatus.waiting:
          return 'Aguardando';
        case RideStatus.searching:
          return 'Buscando Motorista';
        case RideStatus.found:
          return 'Motorista Encontrado';
        case RideStatus.inProgress:
          return 'Em Viagem';
        case RideStatus.completed:
          return 'Concluída';
        case RideStatus.cancelled:
          return 'Cancelada';
      }
    }

    if (passengerStatus != null) {
      switch (passengerStatus!) {
        case PassengerStatus.online:
          return 'Online';
        case PassengerStatus.offline:
          return 'Offline';
        case PassengerStatus.inRide:
          return 'Em Viagem';
        case PassengerStatus.waiting:
          return 'Aguardando';
      }
    }

    return '';
  }
}

/// Widget premium para exibir múltiplos status
class StatusChipGroup extends StatelessWidget {
  final List<RideStatus> rideStatuses;
  final List<PassengerStatus> passengerStatuses;
  final bool isCompact;
  final Axis direction;
  final double spacing;
  final Function(RideStatus)? onRideStatusTap;
  final Function(PassengerStatus)? onPassengerStatusTap;

  const StatusChipGroup({
    Key? key,
    this.rideStatuses = const [],
    this.passengerStatuses = const [],
    this.isCompact = false,
    this.direction = Axis.horizontal,
    this.spacing = VelloTokens.spaceS,
    this.onRideStatusTap,
    this.onPassengerStatusTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = [];

    // Adicionar chips de ride status
    for (final status in rideStatuses) {
      chips.add(
        StatusChip(
          rideStatus: status,
          isCompact: isCompact,
          onTap: onRideStatusTap != null ? () => onRideStatusTap!(status) : null,
        ),
      );
    }

    // Adicionar chips de passenger status
    for (final status in passengerStatuses) {
      chips.add(
        StatusChip(
          passengerStatus: status,
          isCompact: isCompact,
          onTap: onPassengerStatusTap != null ? () => onPassengerStatusTap!(status) : null,
        ),
      );
    }

    if (direction == Axis.horizontal) {
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: chips,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: chips.map((chip) => 
        Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: chip,
        ),
      ).toList(),
    );
  }
}

/// Badge numérico premium para contadores
class VelloBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final double? size;

  const VelloBadge({
    Key? key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeSize = size ?? 20;

    if (count == 0) return const SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(
        minWidth: badgeSize,
        minHeight: badgeSize,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor ?? VelloTokens.danger,
        borderRadius: BorderRadius.circular(badgeSize / 2),
        boxShadow: VelloTokens.elevationLow,
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: textColor ?? VelloTokens.white,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Enum for StatusChip types
enum StatusChipType {
  success,
  warning,
  error,
  info,
}

// Enum for StatusChip sizes
enum StatusChipSize {
  small,
  medium,
  large,
}