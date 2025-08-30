// lib/screens/home/home_controller.dart
import 'package:flutter/material.dart';

class HomeController {
  final TextEditingController destinationController = TextEditingController();

  String distanceEstimate = '4,5 km';
  String priceEstimate = 'R\$ 15,00';

  void init(BuildContext context) {
    // Aqui você pode buscar localização atual, permissões, etc.
    print('Controller iniciado!');
  }

  void requestRide() {
    // Lógica para solicitar corrida (exemplo simples)
    print('Solicitando corrida para: ${destinationController.text}');
  }

  void dispose() {
    destinationController.dispose();
  }
}
