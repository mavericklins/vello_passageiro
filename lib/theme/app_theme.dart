import 'package:flutter/material.dart';
import 'vello_tokens.dart';
import './vello_tokens.dart';

/// Tema principal do Vello Passageiro
/// Implementa Material Design 3 com identidade visual premium
class VelloTheme {

  // ========== TEMA PRINCIPAL (LIGHT) ==========

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Color Scheme Premium
      colorScheme: const ColorScheme.light(
        brightness: Brightness.light,
        primary: VelloTokens.brand,
        onPrimary: VelloTokens.white,
        primaryContainer: VelloTokens.brandLight,
        onPrimaryContainer: VelloTokens.brandDark,
        secondary: VelloTokens.info,
        onSecondary: VelloTokens.white,
        secondaryContainer: VelloTokens.infoLight,
        onSecondaryContainer: VelloTokens.infoDark,
        tertiary: VelloTokens.warning,
        surface: VelloTokens.gray50,
        onSurface: VelloTokens.gray900,
        surfaceVariant: VelloTokens.gray100,
        onSurfaceVariant: VelloTokens.gray600,
        background: VelloTokens.white,
        onBackground: VelloTokens.gray900,
        error: VelloTokens.danger,
        onError: VelloTokens.white,
        errorContainer: VelloTokens.dangerLight,
        onErrorContainer: VelloTokens.dangerDark,
        outline: VelloTokens.gray300,
        shadow: VelloTokens.gray800,
        scrim: VelloTokens.black54,
      ),

      // Scaffold
      scaffoldBackgroundColor: VelloTokens.white,

      // Typography Premium
      textTheme: _buildPremiumTextTheme(),

      // AppBar Theme
      appBarTheme: _buildPremiumAppBarTheme(),

      // Button Themes
      elevatedButtonTheme: _buildPremiumElevatedButtonTheme(),
      filledButtonTheme: _buildPremiumFilledButtonTheme(),
      textButtonTheme: _buildPremiumTextButtonTheme(),
      outlinedButtonTheme: _buildPremiumOutlinedButtonTheme(),

      // Card Theme Premium
      cardTheme: _buildPremiumCardTheme(),

      // Input Theme Premium
      inputDecorationTheme: _buildPremiumInputTheme(),

      // Bottom Navigation Premium
      bottomNavigationBarTheme: _buildPremiumBottomNavTheme(),

      // Navigation Bar (Material 3)
      navigationBarTheme: _buildPremiumNavigationBarTheme(),

      // Dialog Theme Premium
      dialogTheme: _buildPremiumDialogTheme(),

      // Bottom Sheet Theme Premium
      bottomSheetTheme: _buildPremiumBottomSheetTheme(),

      // Tab Bar Theme Premium
      tabBarTheme: _buildPremiumTabBarTheme(),

      // Chip Theme Premium
      chipTheme: _buildPremiumChipTheme(),

      // Progress Indicator Theme
      progressIndicatorTheme: _buildPremiumProgressIndicatorTheme(),

      // Floating Action Button Premium
      floatingActionButtonTheme: _buildPremiumFabTheme(),

      // Switch Theme Premium
      switchTheme: _buildPremiumSwitchTheme(),

      // Checkbox Theme Premium
      checkboxTheme: _buildPremiumCheckboxTheme(),

      // Radio Theme Premium
      radioTheme: _buildPremiumRadioTheme(),

      // SnackBar Theme Premium
      snackBarTheme: _buildPremiumSnackBarTheme(),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: VelloTokens.gray200,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ========== TEMA DARK PREMIUM ==========

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      // Color Scheme Dark Premium
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: VelloTokens.brandLight,
        onPrimary: VelloTokens.darkSurface,
        primaryContainer: VelloTokens.brand,
        onPrimaryContainer: VelloTokens.white,
        secondary: VelloTokens.infoLight,
        onSecondary: VelloTokens.darkSurface,
        secondaryContainer: VelloTokens.info,
        onSecondaryContainer: VelloTokens.white,
        tertiary: VelloTokens.warningLight,
        surface: VelloTokens.darkSurfaceVariant,
        onSurface: VelloTokens.darkOnSurface,
        surfaceVariant: VelloTokens.gray800,
        onSurfaceVariant: VelloTokens.darkOnSurfaceVariant,
        background: VelloTokens.darkSurface,
        onBackground: VelloTokens.darkOnSurface,
        error: VelloTokens.dangerLight,
        onError: VelloTokens.darkSurface,
        errorContainer: VelloTokens.danger,
        onErrorContainer: VelloTokens.white,
        outline: VelloTokens.gray600,
        shadow: VelloTokens.black87,
        scrim: VelloTokens.black87,
      ),

      // Scaffold Dark
      scaffoldBackgroundColor: VelloTokens.darkSurface,

      // Typography Premium Dark
      textTheme: _buildPremiumTextTheme(isDark: true),

      // Components Dark (usando mesmo padrão, cores ajustadas automaticamente pelo ColorScheme)
      appBarTheme: _buildPremiumAppBarTheme(),
      elevatedButtonTheme: _buildPremiumElevatedButtonTheme(),
      filledButtonTheme: _buildPremiumFilledButtonTheme(),
      textButtonTheme: _buildPremiumTextButtonTheme(),
      outlinedButtonTheme: _buildPremiumOutlinedButtonTheme(),
      cardTheme: _buildPremiumCardTheme(),
      inputDecorationTheme: _buildPremiumInputTheme(),
      bottomNavigationBarTheme: _buildPremiumBottomNavTheme(),
      navigationBarTheme: _buildPremiumNavigationBarTheme(),
      dialogTheme: _buildPremiumDialogTheme(),
      bottomSheetTheme: _buildPremiumBottomSheetTheme(),
      tabBarTheme: _buildPremiumTabBarTheme(),
      chipTheme: _buildPremiumChipTheme(),
      progressIndicatorTheme: _buildPremiumProgressIndicatorTheme(),
      floatingActionButtonTheme: _buildPremiumFabTheme(),
      switchTheme: _buildPremiumSwitchTheme(),
      checkboxTheme: _buildPremiumCheckboxTheme(),
      radioTheme: _buildPremiumRadioTheme(),
      snackBarTheme: _buildPremiumSnackBarTheme(),

      dividerTheme: const DividerThemeData(
        color: VelloTokens.gray700,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ========== TEXT THEME PREMIUM ==========

  static TextTheme _buildPremiumTextTheme({bool isDark = false}) {
    final Color textColor = isDark ? VelloTokens.darkOnSurface : VelloTokens.gray900;
    final Color textColorVariant = isDark ? VelloTokens.darkOnSurfaceVariant : VelloTokens.gray600;

    return TextTheme(
      // Display
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: textColor,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textColor,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: textColor,
        height: 1.22,
      ),

      // Headlines
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: textColor,
        height: 1.33,
      ),

      // Titles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: textColor,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: textColor,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor,
        height: 1.43,
      ),

      // Body
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: textColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: textColor,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: textColorVariant,
        height: 1.33,
      ),

      // Labels
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: textColor,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textColor,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: textColorVariant,
        height: 1.45,
      ),
    );
  }

  // ========== COMPONENT THEMES PREMIUM ==========

  static AppBarTheme _buildPremiumAppBarTheme() {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 2,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      iconTheme: const IconThemeData(size: 24),
    );
  }

  static ElevatedButtonThemeData _buildPremiumElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: const RoundedRectangleBorder(borderRadius: VelloTokens.radiusLarge),
        padding: const EdgeInsets.symmetric(horizontal: VelloTokens.spaceL, vertical: VelloTokens.spaceM),
        minimumSize: const Size(64, VelloTokens.minTouchTarget),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ).copyWith(
        elevation: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) return 1;
          if (states.contains(MaterialState.hovered)) return 4;
          if (states.contains(MaterialState.disabled)) return 0;
          return 2;
        }),
      ),
    );
  }

  static FilledButtonThemeData _buildPremiumFilledButtonTheme() {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: VelloTokens.radiusMedium),
        padding: const EdgeInsets.symmetric(horizontal: VelloTokens.spaceL, vertical: VelloTokens.spaceM),
        minimumSize: const Size(64, 48),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildPremiumTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: VelloTokens.radiusMedium),
        padding: const EdgeInsets.symmetric(horizontal: VelloTokens.spaceM, vertical: VelloTokens.spaceS),
        minimumSize: const Size(64, 40),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildPremiumOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: VelloTokens.radiusMedium),
        padding: const EdgeInsets.symmetric(horizontal: VelloTokens.spaceL, vertical: VelloTokens.spaceM),
        minimumSize: const Size(64, 48),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ).copyWith(
        side: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return const BorderSide(color: VelloTokens.gray300, width: 1);
          }
          return const BorderSide(width: 1);
        }),
      ),
    );
  }

  static CardThemeData _buildPremiumCardTheme() {
    return const CardThemeData(
      elevation: 2,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: VelloTokens.radiusLarge),
      margin: EdgeInsets.symmetric(horizontal: VelloTokens.spaceM, vertical: VelloTokens.spaceS),
    );
  }

  static InputDecorationTheme _buildPremiumInputTheme() {
    return InputDecorationTheme(
      filled: true,
      border: const OutlineInputBorder(
        borderRadius: VelloTokens.radiusLarge,
        borderSide: BorderSide.none,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: VelloTokens.radiusLarge,
        borderSide: BorderSide(color: VelloTokens.gray300, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: VelloTokens.radiusLarge,
        borderSide: BorderSide(color: VelloTokens.brand, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: VelloTokens.radiusLarge,
        borderSide: BorderSide(color: VelloTokens.danger, width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: VelloTokens.radiusLarge,
        borderSide: BorderSide(color: VelloTokens.danger, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: VelloTokens.spaceM),
      hintStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static BottomNavigationBarThemeData _buildPremiumBottomNavTheme() {
    return const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    );
  }

  static NavigationBarThemeData _buildPremiumNavigationBarTheme() {
    return NavigationBarThemeData(
      surfaceTintColor: Colors.transparent,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
        }
        return const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        return const IconThemeData(size: 24);
      }),
    );
  }

  static DialogThemeData _buildPremiumDialogTheme() {
    return const DialogThemeData(
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: VelloTokens.radiusXLarge),
      insetPadding: EdgeInsets.all(VelloTokens.spaceL),
    );
  }

  static BottomSheetThemeData _buildPremiumBottomSheetTheme() {
    return const BottomSheetThemeData(
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }

  static TabBarThemeData _buildPremiumTabBarTheme() {
    return const TabBarThemeData(
      labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      indicatorSize: TabBarIndicatorSize.label,
    );
  }

  static ChipThemeData _buildPremiumChipTheme() {
    return ChipThemeData(
      padding: const EdgeInsets.symmetric(horizontal: VelloTokens.spaceM, vertical: VelloTokens.spaceS),
      shape: const RoundedRectangleBorder(borderRadius: VelloTokens.radiusSmall),
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      secondaryLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    );
  }

  static ProgressIndicatorThemeData _buildPremiumProgressIndicatorTheme() {
    return const ProgressIndicatorThemeData(
      refreshBackgroundColor: VelloTokens.gray100,
    );
  }

  static FloatingActionButtonThemeData _buildPremiumFabTheme() {
    return const FloatingActionButtonThemeData(
      elevation: 6,
      shape: CircleBorder(),
    );
  }

  static SwitchThemeData _buildPremiumSwitchTheme() {
    return SwitchThemeData(
      thumbIcon: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const Icon(Icons.check, size: 16);
        }
        return null;
      }),
    );
  }

  static CheckboxThemeData _buildPremiumCheckboxTheme() {
    return CheckboxThemeData(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      side: MaterialStateBorderSide.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return const BorderSide(color: VelloTokens.gray300, width: 2);
        }
        return const BorderSide(width: 2);
      }),
    );
  }

  static RadioThemeData _buildPremiumRadioTheme() {
    return RadioThemeData(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static SnackBarThemeData _buildPremiumSnackBarTheme() {
    return const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: VelloTokens.radiusMedium),
      insetPadding: EdgeInsets.all(VelloTokens.spaceM),
    );
  }
}