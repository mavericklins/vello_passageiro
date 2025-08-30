import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/logger_service.dart';
import '../core/error_handler.dart';

class GeoapifyService {
  final String apiKey = '203ba4a0a4304d349299a8aa22e1dcae'; // Sua chave API Geoapify

  Future<Map<String, dynamic>?> getRouteDetails(
      double startLat, double startLon, double endLat, double endLon) async {
    try {
      final url = Uri.parse(
          'https://api.geoapify.com/v1/routing?waypoints=$startLat,$startLon|$endLat,$endLon&mode=drive&details=traffic_flow&apiKey=$apiKey');

      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        LoggerService.error('Erro na API Geoapify Routing: ${response.statusCode} - ${response.body}', context: 'GEOAPIFY');
        return null;
      }
    } catch (e) {
      LoggerService.info('Erro ao obter detalhes da rota: $e', context: context ?? 'UNKNOWN');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCoordinates(String address) async {
    try {
      final url = Uri.parse(
          'https://api.geoapify.com/v1/geocode/search?text=${Uri.encodeComponent(address)}&apiKey=$apiKey');

      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final coords = data['features'][0]['geometry']['coordinates'];
          return {'lon': coords[0], 'lat': coords[1]};
        }
      } else {
        LoggerService.error('Erro na API Geoapify Geocoding: ${response.statusCode} - ${response.body}', context: 'GEOAPIFY');
      }
    } catch (e) {
      LoggerService.info('Erro ao obter coordenadas: $e', context: context ?? 'UNKNOWN');
    }
    return null;
  }
}


