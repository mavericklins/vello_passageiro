// lib/screens/home/home_controller.dart
import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';

class HomeController {
  final TextEditingController destinationController = TextEditingController();

  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;
  static const Color velloCardBackground = VelloTokens.white;

  String distanceEstimate = '4,5 km';
  String priceEstimate = 'R\$ 15,00';

  void init(BuildContext context) {
    // Aqui você pode buscar localização atual, permissões, etc.
    LoggerService.info('Controller iniciado com identidade visual Vello!', context: context ?? 'UNKNOWN');
  }

  void requestRide() {
    // Lógica para solicitar corrida (exemplo simples)
    LoggerService.info('Solicitando corrida para: ${destinationController.text}', context: context ?? 'UNKNOWN');
  }

  void dispose() {
    destinationController.dispose();
  }

  // Método para obter cor primária da Vello
  Color getPrimaryColor() => velloBlue;

  // Método para obter cor de destaque da Vello
  Color getAccentColor() => velloOrange;

  // Método para obter cor de fundo da Vello
  Color getBackgroundColor() => velloLightGray;

  // Método para obter cor de cards da Vello
  Color getCardColor() => velloCardBackground;
}

