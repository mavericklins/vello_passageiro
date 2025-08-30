import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';

class MapScreen extends StatefulWidget {
  final String valorCorrida;
  final String? rideId; // ADICIONADO: parâmetro rideId

  const MapScreen({
    Key? key, 
    required this.valorCorrida,
    this.rideId, // ADICIONADO: parâmetro opcional
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  
  // Localização padrão (São Paulo)
  LatLng _currentLocation = LatLng(-23.5505, -46.6333);
  
  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    // Inicializar mapa com localização atual
    // Se tiver rideId, pode buscar dados da corrida
    if (widget.rideId != null) {
      LoggerService.info('Acompanhando corrida: ${widget.rideId}', context: context ?? 'UNKNOWN');
      // Aqui você pode implementar o acompanhamento da corrida
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.rideId != null 
            ? 'Acompanhar Corrida' 
            : 'Mapa - R\$ ${widget.valorCorrida}'
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: VelloTokens.white,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentLocation,
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.vello.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLocation,
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.rideId != null) ...[
            FloatingActionButton(
              heroTag: "info",
              onPressed: () {
                _showRideInfo();
              },
              child: Icon(Icons.info),
              backgroundColor: Colors.blue,
            ),
            SizedBox(height: 10),
          ],
          FloatingActionButton(
            heroTag: "location",
            onPressed: () {
              _centerOnCurrentLocation();
            },
            child: Icon(Icons.my_location),
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }

  void _centerOnCurrentLocation() {
    _mapController.move(_currentLocation, 15.0);
  }

  void _showRideInfo() {
    if (widget.rideId == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Informações da Corrida'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID da Corrida: ${widget.rideId}'),
            SizedBox(height: 10),
            Text('Valor: R\$ ${widget.valorCorrida}'),
            SizedBox(height: 10),
            Text('Status: Aguardando motorista...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

