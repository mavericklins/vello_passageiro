// lib/screens/home/home_ui.dart
import 'package:flutter/material.dart';
import 'home_controller.dart';
import '../../widgets/home_widgets.dart';
import '../../theme/vello_tokens.dart';

// Cores da identidade visual Vello
const Color velloBlue = VelloTokens.brandBlue;
const Color velloOrange = VelloTokens.brandOrange;
const Color velloLightGray = VelloTokens.grayLight;
const Color velloCardBackground = VelloTokens.white;

Widget buildHomeUI(BuildContext context, HomeController controller) {
  return Scaffold(
    backgroundColor: velloLightGray,
    appBar: AppBar(
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: velloOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: VelloTokens.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Vello Passageiro',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: velloBlue,
            ),
          ),
        ],
      ),
      backgroundColor: velloCardBackground,
      elevation: 0,
      foregroundColor: velloBlue,
    ),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header com gradiente
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [velloBlue, velloBlue.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: velloBlue.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: velloOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: VelloTokens.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Para onde vamos hoje?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: VelloTokens.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Digite o destino desejado',
                  style: TextStyle(
                    fontSize: 14,
                    color: VelloTokens.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          // Campo de busca
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: velloCardBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: VelloTokens.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: velloOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.search,
                        color: velloOrange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Destino',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: velloBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.destinationController,
                  decoration: InputDecoration(
                    hintText: 'Ex: Avenida Paulista, 1000',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: velloOrange, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    filled: true,
                    fillColor: velloLightGray,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Card de estimativa
          RideEstimateCard(
            distance: controller.distanceEstimate,
            price: controller.priceEstimate,
          ),
          
          const SizedBox(height: 40),
          
          // Botão de solicitar corrida
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RequestRideButton(
              onPressed: controller.requestRide,
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

class RideEstimateCard extends StatelessWidget {
  final String distance;
  final String price;

  const RideEstimateCard({
    Key? key,
    required this.distance,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [velloOrange, velloOrange.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: velloOrange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Distância estimada',
                  style: TextStyle(
                    fontSize: 14,
                    color: VelloTokens.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  distance,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: VelloTokens.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: VelloTokens.white.withOpacity(0.3),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preço estimado',
                  style: TextStyle(
                    fontSize: 14,
                    color: VelloTokens.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: VelloTokens.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RequestRideButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RequestRideButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: velloOrange,
        boxShadow: [
          BoxShadow(
            color: velloOrange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              color: VelloTokens.white,
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              "Solicitar Corrida",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: VelloTokens.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

