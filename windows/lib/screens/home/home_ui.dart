// lib/screens/home/home_ui.dart
import 'package:flutter/material.dart';
import 'home_controller.dart';
import '../../widgets/home_widgets.dart';


Widget buildHomeUI(BuildContext context, HomeController controller) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Vello Passageiro'),
      backgroundColor: Colors.deepOrange,
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Digite o destino:',
            style: TextStyle(fontSize: 18),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: controller.destinationController,
            decoration: const InputDecoration(
              hintText: 'Ex: Avenida Paulista, 1000',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        RideEstimateCard(
          distance: controller.distanceEstimate,
          price: controller.priceEstimate,
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: RequestRideButton(
            onPressed: controller.requestRide,
          ),
        ),
      ],
    ),
  );
}
