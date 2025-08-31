import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/address_model.dart';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

class AddressSearchService {
  static const String _apiKey = '203ba4a0a4304d349299a8aa22e1dcae';
  static const String _baseUrl = 'https://api.geoapify.com/v1';

  // Buscar endereços com autocomplete
  static Future<List<AddressModel>> searchAddresses(String query) async {
    if (query.length < 3) return [];

    try {
      final url = Uri.parse(
        '$_baseUrl/geocode/autocomplete?text=$query&apiKey=$_apiKey&limit=5&lang=pt&filter=countrycode:br'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> features = data['features'] ?? [];

        return features.map((feature) => AddressModel.fromGeoapify(feature)).toList();
      }

      return [];
    } catch (e) {
      LoggerService.info('Erro ao buscar endereços: $e', context: 'AddressSearchService');
      return [];
    }
  }

  // Buscar detalhes de um endereço específico
  static Future<AddressModel?> getAddressDetails(double lat, double lon) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/geocode/reverse?lat=$lat&lon=$lon&apiKey=$_apiKey&lang=pt'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> features = data['features'] ?? [];

        if (features.isNotEmpty) {
          return AddressModel.fromGeoapify(features.first);
        }
      }

      return null;
    } catch (e) {
      LoggerService.info('Erro ao buscar detalhes do endereço: $e', context: 'AddressSearchService');
      return null;
    }
  }

  // Calcular rota entre dois pontos
  static Future<RouteInfo?> calculateRoute(AddressModel origin, AddressModel destination, {List<AddressModel>? waypoints}) async {
    try {
      String waypointsParam = '';
      if (waypoints != null && waypoints.isNotEmpty) {
        final waypointCoords = waypoints.map((w) => '${w.longitude},${w.latitude}').join('|');
        waypointsParam = '&waypoints=$waypointCoords';
      }

      final url = Uri.parse(
        '$_baseUrl/routing?waypoints=${origin.longitude},${origin.latitude}|${destination.longitude},${destination.latitude}$waypointsParam&mode=drive&apiKey=$_apiKey'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> features = data['features'] ?? [];

        if (features.isNotEmpty) {
          final properties = features.first['properties'];
          return RouteInfo(
            distance: (properties['distance'] as num).toDouble(),
            duration: (properties['time'] as num).toDouble(),
            waypoints: features.first['geometry']['coordinates'][0]
                .map<List<double>>((coord) => [coord[1].toDouble(), coord[0].toDouble()])
                .toList(),
          );
        }
      }

      return null;
    } catch (e) {
      LoggerService.info('Erro ao calcular rota: $e', context: 'AddressSearchService');
      return null;
    }
  }
}

class RouteInfo {
  final double distance; // metros
  final double duration; // segundos
  final List<List<double>> waypoints; // [lat, lon]

  RouteInfo({
    required this.distance,
    required this.duration,
    required this.waypoints,
  });

  // Distância em quilômetros
  double get distanceKm => distance / 1000;

  // Duração em minutos
  double get durationMinutes => duration / 60;

  // Formatação amigável
  String get formattedDistance {
    if (distance < 1000) {
      return '${distance.round()} m';
    }
    return '${(distance / 1000).toStringAsFixed(1)} km';
  }

  String get formattedDuration {
    final minutes = (duration / 60).round();
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = (minutes / 60).floor();
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}min';
  }
}