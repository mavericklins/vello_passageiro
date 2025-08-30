// ============================================================================
// ETAPA 5: UNIFICAÇÃO DE DESIGN TOKENS
// ============================================================================
// 
// ⚠️  ARQUIVO DEPRECIADO - USE VelloTokens EM VEZ DE VelloColors
// 
// Este arquivo foi COMPLETAMENTE SUBSTITUÍDO por vello_tokens.dart
// 
// MIGRAÇÃO OBRIGATÓRIA:
// Substitua: import 'vello_colors.dart'  
// Por:       import 'vello_tokens.dart'
// 
// E troque VelloColors por VelloTokens em todo o código
// ============================================================================

import 'package:flutter/material.dart';
import 'vello_tokens.dart';

/// Classe de compatibilidade temporária  
/// Forwards para VelloTokens para evitar quebras durante a migração
@deprecated
class VelloColors {
  // Core brand → VelloTokens
  @deprecated
  static const Color primary = VelloTokens.brand;
  @deprecated
  static const Color primaryLight = VelloTokens.brandLight;
  @deprecated
  static const Color primaryDark = VelloTokens.brandDark;
  @deprecated
  static const Color onPrimary = VelloTokens.white;

  @deprecated
  static const Color secondary = VelloTokens.secondary;
  @deprecated
  static const Color secondaryLight = VelloTokens.secondaryLight;
  @deprecated
  static const Color secondaryDark = VelloTokens.secondaryDark;
  @deprecated
  static const Color onSecondary = VelloTokens.white;

  // Surfaces & background → VelloTokens
  @deprecated
  static const Color background = VelloTokens.background;
  @deprecated
  static const Color surface = VelloTokens.surfaceVariant;
  @deprecated
  static const Color onSurface = VelloTokens.onSurface;
  @deprecated
  static const Color surfaceVariant = VelloTokens.surfaceContainerHighest;
  @deprecated
  static const Color onSurfaceVariant = VelloTokens.onSurfaceVariant;
  @deprecated
  static const Color onBackground = VelloTokens.onBackground;

  // Error → VelloTokens
  @deprecated
  static const Color error = VelloTokens.error;
  @deprecated
  static const Color onError = VelloTokens.white;
  @deprecated
  static const Color errorContainer = VelloTokens.dangerContainer;
  @deprecated
  static const Color onErrorContainer = VelloTokens.onDangerContainer;

  // Misc → VelloTokens
  @deprecated
  static const Color rating = VelloTokens.rating;
  @deprecated
  static const Color divider = VelloTokens.divider;
  @deprecated
  static const Color shadow = VelloTokens.grayShadow;
  @deprecated
  static const Color scrim = VelloTokens.grayScrim;
  @deprecated
  static const Color disabled = VelloTokens.grayDisabled;
  @deprecated
  static const Color surfaceContainerHighest = VelloTokens.surfaceContainerHighest;

  // Aliases legados → VelloTokens  
  @deprecated
  static const Color laranja = VelloTokens.laranja;
  @deprecated
  static const Color laranjaClaro = VelloTokens.laranjaClaro;
  @deprecated
  static const Color laranjaTransparente = VelloTokens.laranjaTransparente;
  @deprecated
  static const Color creme = VelloTokens.creme;
  @deprecated
  static const Color branco = VelloTokens.branco;
  @deprecated
  static const Color azul = VelloTokens.azul;
  @deprecated
  static const Color cinza = VelloTokens.cinza;
  @deprecated
  static const Color pretoTransparente = VelloTokens.pretoTransparente;

  @deprecated
  static const LinearGradient gradienteLaranja = VelloTokens.gradientPrimary;
  @deprecated
  static const Color erro = VelloTokens.erro;
  
  // Success colors → VelloTokens
  @deprecated
  static const Color success = VelloTokens.successAlt;
  @deprecated
  static const Color onSuccess = VelloTokens.white;
  @deprecated
  static const Color successContainer = VelloTokens.successContainer;
  @deprecated
  static const Color onSuccessContainer = VelloTokens.onSuccessContainer;
  
  // Warning colors → VelloTokens
  @deprecated
  static const Color warning = VelloTokens.warningOrange;
  @deprecated
  static const Color onWarning = VelloTokens.white;
  @deprecated
  static const Color warningContainer = VelloTokens.warningContainer;
  @deprecated
  static const Color onWarningContainer = VelloTokens.onWarningContainer;
  
  // Additional surface colors → VelloTokens
  @deprecated
  static const Color surfaceContainer = VelloTokens.surfaceContainer;
  @deprecated
  static const Color surfaceContainerLow = VelloTokens.surfaceContainerLow;
  @deprecated
  static const Color surfaceContainerHigh = VelloTokens.surfaceContainerHigh;
  
  // Additional gradients → VelloTokens
  @deprecated
  static const LinearGradient primaryGradient = VelloTokens.gradientPrimary;
  
  @deprecated
  static const LinearGradient secondaryGradient = VelloTokens.gradientSecondary;
  
  @deprecated
  static const LinearGradient successGradient = VelloTokens.gradientSuccess;
}