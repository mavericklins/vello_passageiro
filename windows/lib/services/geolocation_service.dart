import 'package:geolocator/geolocator.dart';

class GeolocationService {
  Future<Position> buscarLocalizacaoAtual() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
