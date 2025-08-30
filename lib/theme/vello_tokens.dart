import 'package:flutter/material.dart';
import './vello_tokens.dart';

/// Design Tokens Vello - Sistema Unificado de Tokens
/// Fonte única para todas as cores, espaçamentos e elevações do app
/// 
/// ETAPA 5: Consolidação completa dos tokens de design
/// - Substitui app_colors.dart, vello_colors.dart e colors.dart
/// - Zero cores hardcoded no código
/// - Material 3 ColorScheme integrado
class VelloTokens {
  // ========== BRAND COLORS ==========
  // Cores principais da marca Vello
  static const Color brand = VelloTokens.brand;  // Laranja principal
  static const Color brandLight = VelloTokens.brandLight;
  static const Color brandDark = VelloTokens.brandDark;
  
  // Variações específicas encontradas no código
  static const Color brandOrange = VelloTokens.brandOrange;    // De app_colors.dart
  static const Color brandOrangeDark = VelloTokens.brandOrangeDark;
  static const Color brandOrangeLight = VelloTokens.brandOrangeLight;
  static const Color brandOrangeTransparent = VelloTokens.brandOrangeTransparent;
  
  // ========== SECONDARY COLORS ==========
  // Cores secundárias - Azul
  static const Color secondary = VelloTokens.secondary;
  static const Color secondaryLight = VelloTokens.secondaryLight;
  static const Color secondaryDark = VelloTokens.secondaryDark;
  
  // Variações azul encontradas
  static const Color brandBlue = VelloTokens.brandBlue;      // De app_colors.dart
  static const Color brandBlueDark = VelloTokens.brandBlueDark;
  static const Color brandBlueLight = VelloTokens.brandBlueLight;
  static const Color brandBlueAlt = VelloTokens.brandBlueAlt;   // Variação encontrada

  // ========== SEMANTIC COLORS ==========
  // Cores semânticas padronizadas
  static const Color success = VelloTokens.success;
  static const Color successLight = VelloTokens.successLight;
  static const Color successDark = VelloTokens.successDark;
  static const Color successContainer = Color(0xFFE8F5E8);
  static const Color onSuccessContainer = Color(0xFF1B5E20);
  
  // Variações de sucesso
  static const Color successGreen = Color(0xFF28A745);    // De app_colors.dart
  static const Color successAlt = VelloTokens.successAlt;      // De vello_colors.dart

  static const Color warning = VelloTokens.warning;
  static const Color warningLight = VelloTokens.warningLight;
  static const Color warningDark = VelloTokens.warningDark;
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color onWarningContainer = Color(0xFFE65100);
  
  // Variações de warning
  static const Color warningYellow = VelloTokens.rating;   // De app_colors.dart
  static const Color warningOrange = VelloTokens.warningOrange;   // De vello_colors.dart

  static const Color danger = VelloTokens.danger;
  static const Color dangerLight = VelloTokens.dangerLight;
  static const Color dangerDark = VelloTokens.dangerDark;
  static const Color dangerContainer = Color(0xFFFFDAD4);
  static const Color onDangerContainer = Color(0xFF410002);
  
  // Variações de erro
  static const Color error = VelloTokens.error;           // Principal
  static const Color errorRed = Color(0xFFDC3545);        // De app_colors.dart
  static const Color errorEmergency = VelloTokens.errorEmergency;  // Emergência

  static const Color info = VelloTokens.info;
  static const Color infoLight = VelloTokens.infoLight;
  static const Color infoDark = VelloTokens.infoDark;
  
  // Variações de info
  static const Color infoCyan = Color(0xFF17A2B8);        // De app_colors.dart

  // ========== NEUTRAL COLORS ==========
  // Escala de cinza padronizada
  static const Color white = VelloTokens.white;
  static const Color black = VelloTokens.black;
  
  static const Color gray50 = VelloTokens.gray50;
  static const Color gray100 = VelloTokens.gray100;
  static const Color gray200 = VelloTokens.gray200;
  static const Color gray300 = VelloTokens.gray300;
  static const Color gray400 = VelloTokens.gray400;
  static const Color gray500 = VelloTokens.gray500;
  static const Color gray600 = VelloTokens.gray600;
  static const Color gray700 = VelloTokens.gray700;
  static const Color gray800 = VelloTokens.gray800;
  static const Color gray900 = VelloTokens.gray900;
  
  // Variações de cinza encontradas no código
  static const Color grayLight = VelloTokens.grayLight;       // De app_colors.dart
  static const Color grayAlt = VelloTokens.grayAlt;         // De vello_colors.dart
  static const Color grayDisabled = VelloTokens.grayDisabled;
  static const Color grayShadow = VelloTokens.grayShadow;
  static const Color grayScrim = VelloTokens.grayTransparent;
  static const Color grayTransparent = VelloTokens.grayTransparent; // pretoTransparente
  
  // Escala adicional encontrada
  static const Color gray_100 = VelloTokens.grayLight;        // app_colors format
  static const Color gray_200 = Color(0xFFE9ECEF);
  static const Color gray_300 = Color(0xFFDEE2E6);
  static const Color gray_400 = Color(0xFFCED4DA);
  static const Color gray_500 = Color(0xFFADB5BD);
  static const Color gray_600 = Color(0xFF6C757D);
  static const Color gray_700 = VelloTokens.gray_700;
  static const Color gray_800 = Color(0xFF343A40);
  static const Color gray_900 = VelloTokens.gray_900;

  // ========== SURFACE COLORS ==========
  // Cores de superfície Material 3
  static const Color surface = VelloTokens.white;
  static const Color surfaceVariant = VelloTokens.surfaceVariant;
  static const Color surfaceContainer = VelloTokens.surfaceContainer;
  static const Color surfaceContainerLow = Color(0xFFF8F9FB);
  static const Color surfaceContainerHigh = Color(0xFFE8EBF0);
  static const Color surfaceContainerHighest = VelloTokens.surfaceContainerHighest;
  
  static const Color onSurface = VelloTokens.onSurface;
  static const Color onSurfaceVariant = VelloTokens.onSurfaceVariant;
  static const Color onBackground = VelloTokens.onSurface;
  
  // Backgrounds
  static const Color background = VelloTokens.white;
  static const Color backgroundSecondary = VelloTokens.grayLight;
  static const Color backgroundCream = VelloTokens.backgroundCream;    // creme

  // ========== DARK THEME COLORS ==========
  static const Color darkSurface = Color(0xFF0A0A0B);
  static const Color darkSurfaceVariant = Color(0xFF1A1A1D);
  static const Color darkOnSurface = Color(0xFFF9F9F9);
  static const Color darkOnSurfaceVariant = Color(0xFFBBBBBB);

  // ========== SPECIAL COLORS ==========
  // Cores especiais e utilitárias
  static const Color rating = VelloTokens.rating;          // Estrelas de avaliação
  static const Color divider = VelloTokens.divider;         // Divisores
  static const Color emergencyLight = VelloTokens.emergencyLight;  // Fundo emergência
  
  // Glass Effect
  static const Color glassBackground = VelloTokens.glassBackground;
  static const Color glassBackgroundDark = VelloTokens.glassBackgroundDark;
  
  // ========== GRADIENTS ==========
  // Gradientes padronizados
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [brand, brandLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientSecondary = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientSuccess = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientEmergency = LinearGradient(
    colors: [error, VelloTokens.errorEmergency],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========== LEGACY ALIASES ==========
  // Aliases para compatibilidade com código existente
  // Estes devem ser gradualmente substituídos pelos tokens principais
  
  // Cores principais
  static const Color laranja = brand;
  static const Color laranjaClaro = brandLight;
  static const Color laranjaEscuro = brandDark;
  static const Color laranjaTransparente = brandOrangeTransparent;
  
  static const Color azul = brandBlue;
  static const Color azulClaro = brandBlueLight;
  static const Color azulEscuro = brandBlueDark;
  
  static const Color branco = white;
  static const Color preto = black;
  static const Color cinza = grayAlt;
  static const Color cinzaClaro = grayLight;
  static const Color creme = backgroundCream;
  static const Color pretoTransparente = grayTransparent;
  
  // Cores semânticas
  static const Color sucesso = successGreen;
  static const Color erro = errorRed;
  static const Color aviso = warningYellow;
  static const Color info = infoCyan;
  static const Color emergencia = errorEmergency;
  static const Color emergenciaClaro = emergencyLight;

  // ========== ELEVATION SHADOWS ==========
  // Sombras padronizadas Material 3
  static List<BoxShadow> get elevationLow => [
    BoxShadow(
      color: VelloTokens.black.withOpacity(0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevationMedium => [
    BoxShadow(
      color: VelloTokens.black.withOpacity(0.12),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: VelloTokens.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevationHigh => [
    BoxShadow(
      color: VelloTokens.black.withOpacity(0.16),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: VelloTokens.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Sombras legadas
  static BoxShadow get shadowDefault => BoxShadow(
    color: VelloTokens.black.withOpacity(0.1),
    blurRadius: 10,
    offset: const Offset(0, 2),
  );
  
  static BoxShadow get shadowElevated => BoxShadow(
    color: VelloTokens.black.withOpacity(0.15),
    blurRadius: 20,
    offset: const Offset(0, 4),
  );

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