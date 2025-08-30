// ============================================================================
// ARQUIVO DEPRECIADO - ETAPA 5: UNIFICAÇÃO DE DESIGN TOKENS
// ============================================================================
// 
// Este arquivo continha definições de cores duplicadas que foram consolidadas
// em /lib/theme/vello_tokens.dart
//
// O conteúdo original foi migrado para VelloTokens com os seguintes mapeamentos:
// - VelloColors.azul → VelloTokens.brandBlue
// - VelloColors.laranja → VelloTokens.brand  
// - VelloColors.sucesso → VelloTokens.successGreen
// - VelloColors.erro → VelloTokens.errorRed
// - etc.
//
// MIGRAÇÃO NECESSÁRIA:
// 1. Substituir import '../constants/app_colors.dart' por import '../theme/vello_tokens.dart'
// 2. Trocar VelloColors por VelloTokens  
// 3. Atualizar nomes de propriedades conforme mapeamento
//
// Este arquivo será removido em versão futura
// ============================================================================

import 'package:flutter/material.dart';

@deprecated
class VelloColors {
  // Cores principais da identidade Vello
  @deprecated
  static const Color azul = Color(0xFF1B3A57);      // → VelloTokens.brandBlue
  @deprecated  
  static const Color laranja = Color(0xFFFF8C42);   // → VelloTokens.brandOrange
  @deprecated
  static const Color cinzaClaro = Color(0xFFF8F9FA); // → VelloTokens.grayLight
  
  // Variações do azul
  @deprecated
  static const Color azulEscuro = Color(0xFF0F2A3F); // → VelloTokens.brandBlueDark
  @deprecated
  static const Color azulClaro = Color(0xFF2B4A67);  // → VelloTokens.brandBlueLight
  
  // Variações do laranja  
  @deprecated
  static const Color laranjaEscuro = Color(0xFFE67A35); // → VelloTokens.brandOrangeDark
  @deprecated
  static const Color laranjaClaro = Color(0xFFFFAD6F);  // → VelloTokens.brandOrangeLight
  
  // Cores de status
  @deprecated
  static const Color sucesso = Color(0xFF28a745);    // → VelloTokens.successGreen
  @deprecated
  static const Color erro = Color(0xFFdc3545);       // → VelloTokens.errorRed
  @deprecated
  static const Color aviso = Color(0xFFffc107);      // → VelloTokens.warningYellow
  @deprecated
  static const Color info = Color(0xFF17a2b8);       // → VelloTokens.infoCyan
  
  // Cores neutras
  @deprecated
  static const Color branco = Color(0xFFFFFFFF);     // → VelloTokens.white
  @deprecated
  static const Color preto = Color(0xFF000000);      // → VelloTokens.black
  
  // Cores de emergência
  @deprecated
  static const Color emergencia = Color(0xFFE53E3E); // → VelloTokens.errorEmergency
  @deprecated
  static const Color emergenciaClaro = Color(0xFFFED7D7); // → VelloTokens.emergencyLight
}