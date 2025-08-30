import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final String valorCorrida;

  const MapScreen({Key? key, required this.valorCorrida}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController = MapController();

  final LatLng _center = LatLng(-23.550520, -46.633308); // Exemplo: Centro de São Paulo
  final String mapStyle = 'osm-liberty'; // Estilo do mapa Geoapify



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acompanhe sua Corrida'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: _center,
              zoom: 11.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://maps.geoapify.com/v1/tile/$mapStyle/{z}/{x}/{y}.png?apiKey=203ba4a0a4304d349299a8aa22e1dcae",
                userAgentPackageName: 'com.example.app',
              ),
              // Adicionar marcadores e polylines aqui para geolocalização
            ],
          ),
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Motorista a caminho!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Valor da Corrida: ${widget.valorCorrida}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: 0.5, // Simula o progresso
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Tempo estimado: 5 min', // Placeholder
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


