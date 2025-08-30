import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/multiple_destinations.dart';
import '../../theme/vello_tokens.dart';

/// Widget para gerenciar múltiplos destinos
class DestinationsManager extends StatefulWidget {
  final Destination origin;
  final List<Destination> initialDestinations;
  final Function(List<Destination>) onDestinationsChanged;
  final Function(MultipleDestinationsRoute) onRouteCalculated;

  const DestinationsManager({
    Key? key,
    required this.origin,
    required this.initialDestinations,
    required this.onDestinationsChanged,
    required this.onRouteCalculated,
  }) : super(key: key);

  @override
  _DestinationsManagerState createState() => _DestinationsManagerState();
}

class _DestinationsManagerState extends State<DestinationsManager> {
  List<Destination> _destinations = [];
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  final List<List<String>> _suggestions = [];
  bool _isCalculatingRoute = false;

  // Cores da identidade Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = primaryColor;
  static const Color velloLightGray = VelloTokens.grayLight;

  @override
  void initState() {
    super.initState();
    _initializeDestinations();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _initializeDestinations() {
    _destinations = [widget.origin, ...widget.initialDestinations];
    
    // Garantir que sempre tenha pelo menos origem e um destino
    if (_destinations.length < 2) {
      _destinations.add(Destination(
        id: 'dest_${DateTime.now().millisecondsSinceEpoch}',
        address: '',
        lat: 0,
        lng: 0,
        order: 1,
        type: DestinationType.destination,
      ));
    }

    _updateControllers();
  }

  void _updateControllers() {
    // Limpar controllers e focus nodes existentes
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    
    _controllers.clear();
    _focusNodes.clear();
    _suggestions.clear();

    // Criar novos controllers para cada destino (exceto origem)
    for (int i = 1; i < _destinations.length; i++) {
      final controller = TextEditingController(text: _destinations[i].address);
      final focusNode = FocusNode();
      
      controller.addListener(() => _onAddressChanged(i, controller.text));
      focusNode.addListener(() => _onFocusChanged(i, focusNode.hasFocus));
      
      _controllers.add(controller);
      _focusNodes.add(focusNode);
      _suggestions.add([]);
    }
  }

  void _onAddressChanged(int index, String address) {
    if (address.length >= 3) {
      _searchAddressSuggestions(index, address);
    } else {
      setState(() {
        _suggestions[index - 1].clear();
      });
    }
  }

  void _onFocusChanged(int index, bool hasFocus) {
    if (!hasFocus) {
      setState(() {
        _suggestions[index - 1].clear();
      });
    }
  }

  Future<void> _searchAddressSuggestions(int index, String query) async {
    try {
      final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/autocomplete?text=${Uri.encodeComponent(query)}&limit=5&apiKey=203ba4a0a4304d349299a8aa22e1dcae'
      );
      
      final response = await http.get(url).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final suggestions = <String>[];
        
        if (data['features'] != null) {
          for (var feature in data['features']) {
            final address = feature['properties']['formatted'];
            if (address != null && address.isNotEmpty) {
              suggestions.add(address);
            }
          }
        }
        
        setState(() {
          _suggestions[index - 1] = suggestions;
        });
      }
    } catch (e) {
      LoggerService.info('Erro ao buscar sugestões: $e', context: context ?? 'UNKNOWN');
    }
  }

  void _selectSuggestion(int index, String address) async {
    _controllers[index - 1].text = address;
    
    // Buscar coordenadas do endereço
    final coordinates = await _getCoordinatesFromAddress(address);
    
    if (coordinates != null) {
      setState(() {
        _destinations[index] = _destinations[index].copyWith(
          address: address,
          lat: coordinates['lat'],
          lng: coordinates['lng'],
        );
        _suggestions[index - 1].clear();
      });
      
      widget.onDestinationsChanged(_destinations);
      _calculateRoute();
    }
  }

  Future<Map<String, double>?> _getCoordinatesFromAddress(String address) async {
    try {
      final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/search?text=${Uri.encodeComponent(address)}&limit=1&apiKey=203ba4a0a4304d349299a8aa22e1dcae'
      );
      
      final response = await http.get(url).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final coordinates = data['features'][0]['geometry']['coordinates'];
          return {
            'lat': coordinates[1].toDouble(),
            'lng': coordinates[0].toDouble(),
          };
        }
      }
    } catch (e) {
      LoggerService.info('Erro ao obter coordenadas: $e', context: context ?? 'UNKNOWN');
    }
    return null;
  }

  void _addDestination() {
    if (_destinations.length >= 6) { // Máximo 5 paradas + origem
      _showMaxDestinationsDialog();
      return;
    }

    setState(() {
      final newDestination = Destination(
        id: 'dest_${DateTime.now().millisecondsSinceEpoch}',
        address: '',
        lat: 0,
        lng: 0,
        order: _destinations.length,
        type: _destinations.length == _destinations.length 
            ? DestinationType.destination 
            : DestinationType.stop,
      );
      
      // Inserir antes do último destino
      if (_destinations.length > 1) {
        _destinations.insert(_destinations.length - 1, newDestination);
        // Atualizar o último como destino final
        _destinations.last = _destinations.last.copyWith(
          type: DestinationType.destination,
          order: _destinations.length - 1,
        );
        // Atualizar o novo como parada
        _destinations[_destinations.length - 2] = _destinations[_destinations.length - 2].copyWith(
          type: DestinationType.stop,
        );
      } else {
        _destinations.add(newDestination);
      }
      
      _updateControllers();
    });
  }

  void _removeDestination(int index) {
    if (_destinations.length <= 2) return; // Manter pelo menos origem + 1 destino
    
    setState(() {
      _destinations.removeAt(index);
      // Reordenar
      for (int i = 0; i < _destinations.length; i++) {
        _destinations[i] = _destinations[i].copyWith(order: i);
      }
      // Garantir que o último seja destino final
      if (_destinations.length > 1) {
        _destinations.last = _destinations.last.copyWith(
          type: DestinationType.destination,
        );
      }
      
      _updateControllers();
    });
    
    widget.onDestinationsChanged(_destinations);
    _calculateRoute();
  }

  Future<void> _calculateRoute() async {
    if (_destinations.length < 2) return;
    
    // Verificar se todos os destinos têm coordenadas válidas
    final validDestinations = _destinations.where((dest) => 
      dest.address.isNotEmpty && dest.lat != 0 && dest.lng != 0
    ).toList();
    
    if (validDestinations.length < 2) return;
    
    setState(() => _isCalculatingRoute = true);
    
    try {
      // Simular cálculo de rota (em implementação real, usar API de rotas)
      await Future.delayed(Duration(seconds: 1));
      
      final route = await _calculateMultipleDestinationsRoute(validDestinations);
      widget.onRouteCalculated(route);
    } catch (e) {
      LoggerService.info('Erro ao calcular rota: $e', context: context ?? 'UNKNOWN');
    } finally {
      setState(() => _isCalculatingRoute = false);
    }
  }

  Future<MultipleDestinationsRoute> _calculateMultipleDestinationsRoute(
    List<Destination> destinations
  ) async {
    // Cálculo simplificado - em implementação real, usar API de rotas
    double totalDistance = 0;
    int totalDurationMinutes = 0;
    final segments = <RouteSegment>[];
    
    for (int i = 0; i < destinations.length - 1; i++) {
      final from = destinations[i];
      final to = destinations[i + 1];
      
      // Calcular distância aproximada usando fórmula de Haversine
      final distance = _calculateDistance(from.lat, from.lng, to.lat, to.lng);
      final duration = Duration(minutes: (distance / 500).round() + 5); // ~30km/h + tempo de parada
      final price = distance * 0.002 + 2.0; // R$ 2,00 por km + taxa base
      
      totalDistance += distance;
      totalDurationMinutes += duration.inMinutes;
      
      segments.add(RouteSegment(
        fromDestinationId: from.id,
        toDestinationId: to.id,
        distance: distance,
        duration: duration,
        price: price,
      ));
    }
    
    final totalPrice = totalDistance * 0.002 + 5.0; // Preço base + por km
    
    return MultipleDestinationsRoute(
      id: 'route_${DateTime.now().millisecondsSinceEpoch}',
      destinations: destinations,
      totalDistance: totalDistance,
      totalDuration: Duration(minutes: totalDurationMinutes),
      estimatedPrice: totalPrice,
      segments: segments,
      createdAt: DateTime.now(),
    );
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371000; // metros
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  void _showMaxDestinationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: velloOrange),
            SizedBox(width: 8),
            Text('Limite Atingido'),
          ],
        ),
        content: Text('Você pode adicionar no máximo 5 paradas intermediárias.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: velloOrange)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.route, color: velloOrange, size: 20),
            SizedBox(width: 8),
            Text(
              'Destinos da Viagem',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: velloBlue,
              ),
            ),
            Spacer(),
            if (_isCalculatingRoute)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(velloOrange),
                ),
              ),
          ],
        ),
        
        SizedBox(height: 16),
        
        // Lista de destinos
        ...List.generate(_destinations.length, (index) {
          final destination = _destinations[index];
          final isOrigin = destination.type == DestinationType.origin;
          final controllerIndex = index - 1;
          
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                // Ícone do tipo de destino
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isOrigin ? Colors.green : velloOrange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      destination.type.icon,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                
                SizedBox(width: 12),
                
                // Campo de endereço
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: isOrigin 
                            ? TextEditingController(text: destination.address)
                            : _controllers[controllerIndex],
                        focusNode: isOrigin ? null : _focusNodes[controllerIndex],
                        enabled: !isOrigin,
                        decoration: InputDecoration(
                          labelText: destination.type.displayName,
                          hintText: isOrigin ? null : 'Digite o endereço...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: velloOrange),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        style: TextStyle(fontSize: 14),
                      ),
                      
                      // Sugestões
                      if (!isOrigin && 
                          controllerIndex < _suggestions.length && 
                          _suggestions[controllerIndex].isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: VelloTokens.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: VelloTokens.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: _suggestions[controllerIndex]
                                .take(3)
                                .map((suggestion) => ListTile(
                                  dense: true,
                                  title: Text(
                                    suggestion,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  onTap: () => _selectSuggestion(index, suggestion),
                                ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Botão de remover (apenas para paradas e destino final)
                if (!isOrigin && _destinations.length > 2)
                  IconButton(
                    onPressed: () => _removeDestination(index),
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
              ],
            ),
          );
        }),
        
        // Botão adicionar parada
        if (_destinations.length < 6)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              onPressed: _addDestination,
              icon: Icon(Icons.add_location, color: velloOrange),
              label: Text(
                'Adicionar Parada',
                style: TextStyle(color: velloOrange),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: velloOrange),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Import necessário para math
import 'dart:math' as math;
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

