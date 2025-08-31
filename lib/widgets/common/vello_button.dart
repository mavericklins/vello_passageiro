import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/vello_tokens.dart';

/// Tipos de botão Vello Premium
enum VelloButtonType {
  primary,
  secondary,
  success,
  warning,
  error,
  ghost,
  outlined,
  danger, // Added danger type
}

/// Tamanhos de botão Vello Premium
enum VelloButtonSize {
  small,
  medium,
  large,
}

/// Estados do botão Vello Premium
enum VelloButtonState {
  normal,
  loading,
  success,
  error,
}

/// Botão padronizado do Vello Passageiro Premium
/// Implementa design system consistente com estados visuais
class VelloButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final VelloButtonType type;
  final VelloButtonSize size;
  final VelloButtonState state;
  final bool isFullWidth;
  final IconData? icon;
  final Widget? child;
  final bool hapticFeedback;
  final Color? backgroundColor; // Added backgroundColor property
  final Color? color; // Added color parameter
  final BorderRadius? borderRadius; // Added borderRadius parameter
  final Widget? label; // Added label parameter

  const VelloButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = VelloButtonType.primary,
    this.size = VelloButtonSize.medium,
    this.state = VelloButtonState.normal,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.hapticFeedback = true,
    this.backgroundColor, // Added backgroundColor parameter
    this.color, // Added color parameter
    this.borderRadius, // Added borderRadius parameter
    this.label, // Added label parameter
  }) : super(key: key);

  /// Botão primário (padrão)
  const VelloButton.primary({
    Key? key,
    required this.text,
    this.onPressed,
    this.size = VelloButtonSize.medium,
    this.state = VelloButtonState.normal,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.hapticFeedback = true,
    this.backgroundColor,
    this.color,
    this.borderRadius,
    this.label,
  }) : type = VelloButtonType.primary, super(key: key);

  /// Botão secundário
  const VelloButton.secondary({
    Key? key,
    required this.text,
    this.onPressed,
    this.size = VelloButtonSize.medium,
    this.state = VelloButtonState.normal,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.hapticFeedback = true,
    this.backgroundColor,
    this.color,
    this.borderRadius,
    this.label,
  }) : type = VelloButtonType.secondary, super(key: key);

  /// Botão outlined
  const VelloButton.outlined({
    Key? key,
    required this.text,
    this.onPressed,
    this.size = VelloButtonSize.medium,
    this.state = VelloButtonState.normal,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.hapticFeedback = true,
    this.backgroundColor,
    this.color,
    this.borderRadius,
    this.label,
  }) : type = VelloButtonType.outlined, super(key: key);

  /// Botão ghost
  const VelloButton.ghost({
    Key? key,
    required this.text,
    this.onPressed,
    this.size = VelloButtonSize.medium,
    this.state = VelloButtonState.normal,
    this.isFullWidth = false,
    this.icon,
    this.child,
    this.hapticFeedback = true,
    this.backgroundColor,
    this.color,
    this.borderRadius,
    this.label,
  }) : type = VelloButtonType.ghost, super(key: key);

  /// Botão com ícone
  const VelloButton.icon({
    Key? key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.size = VelloButtonSize.medium,
    this.state = VelloButtonState.normal,
    this.isFullWidth = false,
    this.child,
    this.hapticFeedback = true,
    this.backgroundColor,
    this.color,
    this.borderRadius,
    this.label,
  }) : type = VelloButtonType.primary, super(key: key);

  @override
  State<VelloButton> createState() => _VelloButtonState();
}

class _VelloButtonState extends State<VelloButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: VelloTokens.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.isFullWidth ? double.infinity : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildButton(context),
          );
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    final buttonStyle = _getButtonStyle(context);
    final content = _buildContent(context);

    Widget button;

    switch (widget.type) {
      case VelloButtonType.primary:
      case VelloButtonType.success:
      case VelloButtonType.warning:
      case VelloButtonType.error:
      case VelloButtonType.danger:
        button = ElevatedButton(
          onPressed: _getOnPressed(),
          style: buttonStyle,
          child: content,
        );
        break;
      case VelloButtonType.secondary:
      case VelloButtonType.outlined:
        button = OutlinedButton(
          onPressed: _getOnPressed(),
          style: buttonStyle,
          child: content,
        );
        break;
      case VelloButtonType.ghost:
        button = TextButton(
          onPressed: _getOnPressed(),
          style: buttonStyle,
          child: content,
        );
        break;
    }

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: button,
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSwitcher(
      duration: VelloTokens.animationMedium,
      child: _buildContentByState(context, theme),
    );
  }

  Widget _buildContentByState(BuildContext context, ThemeData theme) {
    switch (widget.state) {
      case VelloButtonState.loading:
        return SizedBox(
          key: const ValueKey('loading'),
          height: _getIconSize(),
          width: _getIconSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_getLoadingColor(theme)),
          ),
        );

      case VelloButtonState.success:
        return Row(
          key: const ValueKey('success'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: _getIconSize()),
            const SizedBox(width: VelloTokens.spaceS),
            Text('Sucesso'),
          ],
        );

      case VelloButtonState.error:
        return Row(
          key: const ValueKey('error'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, size: _getIconSize()),
            const SizedBox(width: VelloTokens.spaceS),
            Text('Erro'),
          ],
        );

      case VelloButtonState.normal:
      default:
        if (widget.child != null) {
          return KeyedSubtree(
            key: const ValueKey('custom'),
            child: widget.child!,
          );
        }

        if (widget.icon != null) {
          return Row(
            key: const ValueKey('icon'),
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: _getIconSize()),
              const SizedBox(width: VelloTokens.spaceS),
              Text(widget.text),
            ],
          );
        }

        return KeyedSubtree(
          key: const ValueKey('text'),
          child: Text(widget.text),
        );
    }
  }

  VoidCallback? _getOnPressed() {
    if (widget.state == VelloButtonState.loading) return null;
    if (widget.onPressed == null) return null;

    return () {
      if (widget.hapticFeedback) {
        HapticFeedback.lightImpact();
      }
      widget.onPressed!();
    };
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return theme.colorScheme.surfaceVariant;
        }
        if (states.contains(MaterialState.pressed)) {
          return colors['backgroundPressed'];
        }
        return widget.backgroundColor ?? colors['background'];
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return theme.colorScheme.onSurfaceVariant;
        }
        return colors['foreground'];
      }),
      side: _needsBorder()
          ? MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.disabled)) {
                return BorderSide(color: theme.colorScheme.outline, width: 1);
              }
              return BorderSide(color: colors['border']!, width: 1);
            })
          : null,
      padding: MaterialStateProperty.all(padding),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: _getBorderRadius()),
      ),
      elevation: _getElevation(),
      textStyle: MaterialStateProperty.all(textStyle),
      minimumSize: MaterialStateProperty.all(_getMinimumSize()),
      animationDuration: VelloTokens.animationMedium,
    );
  }

  Map<String, Color> _getColors(ThemeData theme) {
    switch (widget.type) {
      case VelloButtonType.primary:
        return {
          'background': VelloTokens.brand,
          'backgroundPressed': VelloTokens.brandDark,
          'foreground': VelloTokens.white,
          'border': VelloTokens.brand,
        };
      case VelloButtonType.secondary:
        return {
          'background': VelloTokens.gray200,
          'backgroundPressed': VelloTokens.gray300,
          'foreground': VelloTokens.gray700,
          'border': VelloTokens.gray200,
        };
      case VelloButtonType.success:
        return {
          'background': VelloTokens.success,
          'backgroundPressed': VelloTokens.successDark,
          'foreground': VelloTokens.white,
          'border': VelloTokens.success,
        };
      case VelloButtonType.warning:
        return {
          'background': VelloTokens.warning,
          'backgroundPressed': VelloTokens.warningDark,
          'foreground': VelloTokens.white,
          'border': VelloTokens.warning,
        };
      case VelloButtonType.error:
        return {
          'background': VelloTokens.danger,
          'backgroundPressed': VelloTokens.dangerDark,
          'foreground': VelloTokens.white,
          'border': VelloTokens.danger,
        };
      case VelloButtonType.ghost:
        return {
          'background': Colors.transparent,
          'backgroundPressed': theme.colorScheme.primary.withOpacity(0.08),
          'foreground': theme.colorScheme.primary,
          'border': Colors.transparent,
        };
      case VelloButtonType.outlined:
        return {
          'background': Colors.transparent,
          'backgroundPressed': theme.colorScheme.surfaceVariant,
          'foreground': theme.colorScheme.onSurface,
          'border': theme.colorScheme.outline,
        };
      case VelloButtonType.danger:
        return {
          'background': VelloTokens.danger,
          'backgroundPressed': VelloTokens.dangerDark,
          'foreground': VelloTokens.white,
          'border': VelloTokens.danger,
        };
    }
  }

  bool _needsBorder() {
    return widget.type == VelloButtonType.secondary ||
           widget.type == VelloButtonType.outlined;
  }

  BorderRadius _getBorderRadius() {
    return widget.borderRadius ?? 
      switch (widget.size) {
        VelloButtonSize.small => VelloTokens.radiusSmall,
        VelloButtonSize.medium => VelloTokens.radiusMedium,
        VelloButtonSize.large => VelloTokens.radiusLarge,
      };
  }

  EdgeInsetsGeometry _getPadding() {
    switch (widget.size) {
      case VelloButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: VelloTokens.spaceM, vertical: VelloTokens.spaceS);
      case VelloButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: VelloTokens.spaceL, vertical: VelloTokens.spaceM);
      case VelloButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: VelloTokens.spaceXL, vertical: VelloTokens.spaceL);
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case VelloButtonSize.small:
        return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
      case VelloButtonSize.medium:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
      case VelloButtonSize.large:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    }
  }

  Size _getMinimumSize() {
    switch (widget.size) {
      case VelloButtonSize.small:
        return const Size(64, 36);
      case VelloButtonSize.medium:
        return const Size(64, VelloTokens.minTouchTarget);
      case VelloButtonSize.large:
        return const Size(64, 56);
    }
  }

  MaterialStateProperty<double?> _getElevation() {
    if (widget.type == VelloButtonType.ghost ||
        widget.type == VelloButtonType.secondary ||
        widget.type == VelloButtonType.outlined) {
      return MaterialStateProperty.all(0);
    }

    return MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.pressed)) return 1;
      if (states.contains(MaterialState.hovered)) return 4;
      if (states.contains(MaterialState.disabled)) return 0;
      return 2;
    });
  }

  double _getIconSize() {
    switch (widget.size) {
      case VelloButtonSize.small:
        return 16;
      case VelloButtonSize.medium:
        return 18;
      case VelloButtonSize.large:
        return 20;
    }
  }

  Color _getLoadingColor(ThemeData theme) {
    switch (widget.type) {
      case VelloButtonType.primary:
      case VelloButtonType.success:
      case VelloButtonType.warning:
      case VelloButtonType.error:
      case VelloButtonType.danger:
        return VelloTokens.white;
      case VelloButtonType.secondary:
      case VelloButtonType.ghost:
      case VelloButtonType.outlined:
        return theme.colorScheme.primary;
    }
  }
}