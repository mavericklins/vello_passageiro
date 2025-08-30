import 'package:geolocator/geolocator.dart';
import 'dart:async';

class GeolocationService {
  static final GeolocationService _instance = GeolocationService._internal();
  factory GeolocationService() => _instance;
  GeolocationService._internal();

  StreamSubscription<Position>? _positionSubscription;
  Stream<Position>? _positionStream;

  Future<Position> buscarLocalizacaoAtual() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Stream contínuo da posição do usuário
  Stream<Position> get positionStream {
    _positionStream ??= Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Atualizar a cada 10 metros
      ),
    );
    return _positionStream!;
  }

  /// Verifica e solicita permissões de localização
  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Limpa recursos
  void dispose() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }
}