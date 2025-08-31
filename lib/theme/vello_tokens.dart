import 'package:flutter/material.dart';

/// Design Tokens Vello - Sistema Unificado de Tokens
/// Fonte única para todas as cores, espaçamentos e elevações do app
/// 
/// ETAPA 5: Consolidação completa dos tokens de design
/// - Substitui app_colors.dart, vello_colors.dart e colors.dart
/// - Zero cores hardcoded no código
/// - Material 3 ColorScheme integrado
class VelloTokens {
  // ========== BRAND COLORS ==========
  // CORREÇÃO: Remover auto-referências, usar valores literais
  static const Color brand = Color(0xFFFF6B35);  // Laranja principal
  static const Color brandLight = Color(0xFFFF8A65);
  static const Color brandDark = Color(0xFFE64A19);
  
  // Variações específicas encontradas no código
  static const Color brandOrange = Color(0xFFFF6B35);    // De app_colors.dart
  static const Color brandOrangeDark = Color(0xFFE64A19);
  static const Color brandOrangeLight = Color(0xFFFF8A65);
  static const Color brandOrangeTransparent = Color(0x80FF6B35);
  
  // ========== SECONDARY COLORS ==========
  // Cores secundárias - Azul
  static const Color secondary = Color(0xFF1976D2);
  static const Color secondaryLight = Color(0xFF42A5F5);
  static const Color secondaryDark = Color(0xFF0D47A1);
  
  // Variações azul encontradas
  static const Color brandBlue = Color(0xFF1976D2);      // De app_colors.dart
  static const Color brandBlueDark = Color(0xFF0D47A1);
  static const Color brandBlueLight = Color(0xFF42A5F5);
  static const Color brandBlueAlt = Color(0xFF2196F3);   // Variação encontrada

  // ========== SEMANTIC COLORS ==========
  // Cores semânticas padronizadas
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  static const Color successContainer = Color(0xFFE8F5E8);
  static const Color onSuccessContainer = Color(0xFF1B5E20);
  
  // Variações de sucesso
  static const Color successGreen = Color(0xFF28A745);    // De app_colors.dart
  static const Color successAlt = Color(0xFF4CAF50);      // De vello_colors.dart

  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color warningDark = Color(0xFFF57F17);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color onWarningContainer = Color(0xFFE65100);
  
  // Variações de warning
  static const Color warningYellow = Color(0xFFFFC107);   // De app_colors.dart
  static const Color warningOrange = Color(0xFFFF9800);   // De vello_colors.dart

  static const Color danger = Color(0xFFE53935);
  static const Color dangerLight = Color(0xFFEF5350);
  static const Color dangerDark = Color(0xFFC62828);
  static const Color dangerContainer = Color(0xFFFFDAD4);
  static const Color onDangerContainer = Color(0xFF410002);
  
  // Variações de erro
  static const Color error = Color(0xFFE53935);           // Principal
  static const Color errorRed = Color(0xFFDC3545);        // De app_colors.dart
  static const Color errorEmergency = Color(0xFFD32F2F);  // Emergência

  // CORREÇÃO: Definir 'info' apenas uma vez para evitar duplicata
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1565C0);
  
  // Variações de info
  static const Color infoCyan = Color(0xFF17A2B8);        // De app_colors.dart

  // ========== NEUTRAL COLORS ==========
  // Escala de cinza padronizada
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);
  
  // Variações de cinza encontradas no código
  static const Color grayLight = Color(0xFFF5F5F5);       // De app_colors.dart
  static const Color grayAlt = Color(0xFF9E9E9E);         // De vello_colors.dart
  static const Color grayDisabled = Color(0xFFBDBDBD);
  static const Color grayShadow = Color(0xFF424242);
  static const Color grayScrim = Color(0x80000000);
  static const Color grayTransparent = Color(0x80000000); // pretoTransparente
  
  // Escala adicional encontrada
  static const Color gray_100 = Color(0xFFF5F5F5);        // app_colors format
  static const Color gray_200 = Color(0xFFE9ECEF);
  static const Color gray_300 = Color(0xFFDEE2E6);
  static const Color gray_400 = Color(0xFFCED4DA);
  static const Color gray_500 = Color(0xFFADB5BD);
  static const Color gray_600 = Color(0xFF6C757D);
  static const Color gray_700 = Color(0xFF616161);
  static const Color gray_800 = Color(0xFF343A40);
  static const Color gray_900 = Color(0xFF212121);

  // ========== SURFACE COLORS ==========
  // Cores de superfície Material 3
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerLow = Color(0xFFF8F9FB);
  static const Color surfaceContainerHigh = Color(0xFFE8EBF0);
  static const Color surfaceContainerHighest = Color(0xFFE0E0E0);
  
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF757575);
  static const Color onBackground = Color(0xFF212121);
  
  // Backgrounds
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF5F5F5);
  static const Color backgroundCream = Color(0xFFFFFBF0);    // creme

  // ========== DARK THEME COLORS ==========
  static const Color darkSurface = Color(0xFF0A0A0B);
  static const Color darkSurfaceVariant = Color(0xFF1A1A1D);
  static const Color darkOnSurface = Color(0xFFF9F9F9);
  static const Color darkOnSurfaceVariant = Color(0xFFBBBBBB);

  // ========== SPECIAL COLORS ==========
  // Cores especiais e utilitárias
  static const Color rating = Color(0xFFFFC107);          // Estrelas de avaliação
  static const Color divider = Color(0xFFE0E0E0);         // Divisores
  static const Color emergencyLight = Color(0xFFFFDAD4);  // Fundo emergência
  
  // Glass Effect
  static const Color glassBackground = Color(0x80FFFFFF);
  static const Color glassBackgroundDark = Color(0x80000000);
  
  // CORREÇÃO: Definir cores faltantes como white70 etc.
  static const Color white70 = Color(0xB3FFFFFF); // 70% opacidade do branco
  static const Color white54 = Color(0x8AFFFFFF); // 54% opacidade do branco

  // ========== GRADIENTS ==========
  // Gradientes padronizados
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientSecondary = LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientSuccess = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientEmergency = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========== LEGACY ALIASES ==========
  // Aliases para compatibilidade com código existente
  // Estes devem ser gradualmente substituídos pelos tokens principais
  
  // Cores principais
  static const Color laranja = Color(0xFFFF6B35);
  static const Color laranjaClaro = Color(0xFFFF8A65);
  static const Color laranjaEscuro = Color(0xFFE64A19);
  static const Color laranjaTransparente = Color(0x80FF6B35);
  
  static const Color azul = Color(0xFF1976D2);
  static const Color azulClaro = Color(0xFF42A5F5);
  static const Color azulEscuro = Color(0xFF0D47A1);
  
  static const Color branco = Color(0xFFFFFFFF);
  static const Color preto = Color(0xFF000000);
  static const Color cinza = Color(0xFF9E9E9E);
  static const Color cinzaClaro = Color(0xFFF5F5F5);
  static const Color cinza700 = Color(0xFF616161);
  static const Color cinza600 = Color(0xFF757575);
  static const Color creme = Color(0xFFFFFBF0);
  static const Color pretoTransparente = Color(0x80000000);
  
  // Cores semânticas
  static const Color sucesso = Color(0xFF28A745);
  static const Color erro = Color(0xFFDC3545);
  static const Color aviso = Color(0xFFFFC107);
  static const Color emergencia = Color(0xFFD32F2F);
  static const Color emergenciaClaro = Color(0xFFFFDAD4);

  // ========== ELEVATION SHADOWS ==========
  // Sombras padronizadas Material 3
  static List<BoxShadow> get elevationLow => [
    BoxShadow(
      color: black.withOpacity(0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevationMedium => [
    BoxShadow(
      color: black.withOpacity(0.12),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevationHigh => [
    BoxShadow(
      color: black.withOpacity(0.16),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Sombras legadas
  static BoxShadow get shadowDefault => BoxShadow(
    color: black.withOpacity(0.1),
    blurRadius: 10,
    offset: const Offset(0, 2),
  );
  
  static BoxShadow get shadowElevated => BoxShadow(
    color: black.withOpacity(0.15),
    blurRadius: 20,
    offset: const Offset(0, 4),
  );

  // CORREÇÃO: Adicionar aliases faltantes para compatibilidade
  static BoxShadow get sombraPadrao => shadowDefault;
  static LinearGradient get gradientePrimario => gradientPrimary;

  // ========== BORDER RADIUS ==========
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(4));
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusMedium = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusXLarge = BorderRadius.all(Radius.circular(24));
  static const BorderRadius radiusXXLarge = BorderRadius.all(Radius.circular(32));

  // ========== SPACING ==========
  static const double spaceXS = 4;
  static const double spaceS = 8;
  static const double spaceM = 16;
  static const double spaceL = 24;
  static const double spaceXL = 32;
  static const double spaceXXL = 48;
  static const double spaceXXXL = 64;

  // Touch Targets
  static const double minTouchTarget = 44;
  static const double minTouchTargetAndroid = 48;

  // ========== ANIMATION DURATIONS ==========
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);
  static const Duration animationXSlow = Duration(milliseconds: 500);

  // ========== UTILITY METHODS ==========
  /// Obtém cor por nome (compatibilidade com código legado)
  static Color getColorByName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'azul':
        return azul;
      case 'laranja':
        return laranja;
      case 'cinza_claro':
        return cinzaClaro;
      case 'sucesso':
        return sucesso;
      case 'erro':
        return erro;
      case 'aviso':
        return aviso;
      case 'info':
        return info;
      case 'emergencia':
        return emergencia;
      default:
        return brand;
    }
  }
  
  /// Aplica opacidade à cor
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // ========== DEPRECATED - TO BE REMOVED ==========
  // Manter apenas por compatibilidade durante transição
  @deprecated
  static const Color surfacePrimary = surface;
  @deprecated  
  static const Color surfaceSecondary = surfaceVariant;
  @deprecated
  static const Color surfaceBackground = backgroundSecondary;
  @deprecated
  static const Color colorGreen = success;
  @deprecated
  static const Color colorOrange = warning;
  @deprecated
  static const Color colorRed = danger;
  @deprecated
  static const Color green500 = success;
  @deprecated
  static const Color red500 = danger;
}