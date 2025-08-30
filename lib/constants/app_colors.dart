// ============================================================================
// ETAPA 5: UNIFICAÇÃO DE DESIGN TOKENS
// ============================================================================
// 
// ⚠️  ARQUIVO DEPRECIADO - USE VelloTokens EM VEZ DE VelloColors
// 
// Este arquivo foi consolidado em /lib/theme/vello_tokens.dart
// 
// MIGRAÇÃO OBRIGATÓRIA:
// Substitua: import '../constants/app_colors.dart'
// Por:       import '../theme/vello_tokens.dart'  
// 
// E troque VelloColors por VelloTokens em todo o código
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/vello_tokens.dart';

/// Classe de compatibilidade temporária
/// Forwards para VelloTokens para evitar quebras durante a migração
@deprecated
class VelloColors {
  // Forwards para VelloTokens - USE VelloTokens DIRETAMENTE
  @deprecated
  static const Color azul = VelloTokens.brandBlue;
  @deprecated  
  static const Color laranja = VelloTokens.brandOrange;
  @deprecated
  static const Color cinzaClaro = VelloTokens.grayLight;
  @deprecated
  static const Color azulEscuro = VelloTokens.brandBlueDark;
  @deprecated
  static const Color azulClaro = VelloTokens.brandBlueLight;
  @deprecated
  static const Color laranjaEscuro = VelloTokens.brandOrangeDark;
  @deprecated
  static const Color laranjaClaro = VelloTokens.brandOrangeLight;
  @deprecated
  static const Color sucesso = VelloTokens.successGreen;
  @deprecated
  static const Color erro = VelloTokens.errorRed;
  @deprecated
  static const Color aviso = VelloTokens.warningYellow;
  @deprecated
  static const Color info = VelloTokens.infoCyan;
  @deprecated
  static const Color branco = VelloTokens.white;
  @deprecated
  static const Color preto = VelloTokens.black;
  @deprecated
  static const Color cinza100 = VelloTokens.gray_100;
  @deprecated
  static const Color cinza200 = VelloTokens.gray_200;
  @deprecated
  static const Color cinza300 = VelloTokens.gray_300;
  @deprecated
  static const Color cinza400 = VelloTokens.gray_400;
  @deprecated
  static const Color cinza500 = VelloTokens.gray_500;
  @deprecated
  static const Color cinza600 = VelloTokens.gray_600;
  @deprecated
  static const Color cinza700 = VelloTokens.gray_700;
  @deprecated
  static const Color cinza800 = VelloTokens.gray_800;
  @deprecated
  static const Color cinza900 = VelloTokens.gray_900;
  @deprecated
  static const Color emergencia = VelloTokens.errorEmergency;
  @deprecated
  static const Color emergenciaClaro = VelloTokens.emergencyLight;
  
  // Gradientes
  @deprecated
  static const LinearGradient gradientePrimario = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [VelloTokens.brandBlue, VelloTokens.brandBlueDark],
  );
  
  @deprecated
  static const LinearGradient gradienteSecundario = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [VelloTokens.brandOrange, VelloTokens.brandOrangeDark],
  );
  
  @deprecated
  static const LinearGradient gradienteEmergencia = VelloTokens.gradientEmergency;
  
  // Sombras
  @deprecated
  static BoxShadow get sombraPadrao => VelloTokens.shadowDefault;
  
  @deprecated
  static BoxShadow get sombraElevada => VelloTokens.shadowElevated;
  
  // Métodos
  @deprecated
  static Color obterCor(String nomeCor) => VelloTokens.getColorByName(nomeCor);
  
  @deprecated  
  static Color comOpacidade(Color cor, double opacidade) => VelloTokens.withOpacity(cor, opacidade);
}