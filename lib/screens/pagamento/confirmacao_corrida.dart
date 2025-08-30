import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../services/firebase_service.dart';
import '../pagamento/pagamento_screen.dart';
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

class ConfirmacaoCorridaScreen extends StatefulWidget {
  final String enderecoInicial;

  const ConfirmacaoCorridaScreen({Key? key, required this.enderecoInicial}) : super(key: key);

  @override
  State<ConfirmacaoCorridaScreen> createState() => _ConfirmacaoCorridaScreenState();
}

class _ConfirmacaoCorridaScreenState extends State<ConfirmacaoCorridaScreen> {
  LatLng? posicaoAtual;
  MapController? _mapController;
  final TextEditingController origemController = TextEditingController();
  final TextEditingController destinoController = TextEditingController();
  final FocusNode destinoFocus = FocusNode();
  final FocusNode origemFocus = FocusNode();
  
  List<String> sugestoesDestino = [];
  List<String> sugestoesOrigem = [];
  bool carregandoLocalizacao = true;
  bool enderecoSelecionado = false;
  String valorEstimado = "R\$ --,--";
  Timer? _debounce;
  Timer? _debounceOrigem;
  
  // Variáveis para múltiplos destinos
  bool _useMultipleDestinations = false;
  List<String> _additionalDestinations = [];
  List<TextEditingController> _destinationControllers = [];
  List<FocusNode> _destinationFocusNodes = [];
  List<List<String>> _destinationSuggestions = [];
  List<Timer?> _destinationDebounces = [];
  
  // Variáveis para corrida compartilhada
  bool _useSharedRide = false;
  int _maxPassengers = 2;
  double _individualPrice = 0.0;

  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;
  static const Color velloCardBackground = VelloTokens.white;

  bool get _dadosCompletos => 
      origemController.text.isNotEmpty &&
      destinoController.text.isNotEmpty && 
      valorEstimado != "R\$ --,--";

  @override
  void initState() {
    super.initState();
    
    // Inicializar MapController de forma segura
    try {
      _mapController = MapController();
    } catch (e) {
      LoggerService.info('Erro ao inicializar MapController: $e', context: context ?? 'UNKNOWN');
      _mapController = null;
    }
    
    // Configurar listeners
    destinoController.addListener(_onDestinoChanged);
    origemController.addListener(_onOrigemChanged);
    
    // Configurar destino inicial se fornecido
    if (widget.enderecoInicial.isNotEmpty) {
      destinoController.text = widget.enderecoInicial;
      enderecoSelecionado = true;
    }
    
    // Iniciar obtenção de localização
    _iniciarDeteccaoLocalizacao();
  }

  @override
  void dispose() {
    origemController.dispose();
    destinoController.dispose();
    destinoFocus.dispose();
    origemFocus.dispose();
    
    // Limpar recursos de múltiplos destinos
    for (var controller in _destinationControllers) {
      controller.dispose();
    }
    for (var focusNode in _destinationFocusNodes) {
      focusNode.dispose();
    }
    for (var timer in _destinationDebounces) {
      timer?.cancel();
    }
    
    _destinationControllers.clear();
    _destinationFocusNodes.clear();
    _destinationSuggestions.clear();
    _destinationDebounces.clear();
    
    _debounce?.cancel();
    _debounceOrigem?.cancel();
    super.dispose();
  }

  Future<void> _iniciarDeteccaoLocalizacao() async {
    LoggerService.info('🔍 Iniciando detecção de localização...', context: context ?? 'UNKNOWN');
    
    setState(() {
      carregandoLocalizacao = true;
      origemController.text = "Obtendo sua localização...";
    });

    try {
      // Verificar se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LoggerService.info('📍 Serviço de localização habilitado: $serviceEnabled', context: context ?? 'UNKNOWN');
      
      if (!serviceEnabled) {
        setState(() {
          carregandoLocalizacao = false;
          origemController.text = "Serviço de localização desabilitado";
        });
        return;
      }

      // Verificar permissões
      LocationPermission permission = await Geolocator.checkPermission();
      LoggerService.info('🔐 Permissão atual: $permission', context: context ?? 'UNKNOWN');
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        LoggerService.info('🔐 Nova permissão: $permission', context: context ?? 'UNKNOWN');
        
        if (permission == LocationPermission.denied) {
          setState(() {
            carregandoLocalizacao = false;
            origemController.text = "Permissão de localização negada";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          carregandoLocalizacao = false;
          origemController.text = "Permissão de localização negada permanentemente";
        });
        return;
      }

      // Obter posição atual
      LoggerService.info('📱 Obtendo posição atual...', context: context ?? 'UNKNOWN');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );

      LoggerService.info('📍 Posição obtida: ${position.latitude}, ${position.longitude}', context: context ?? 'UNKNOWN');

      setState(() {
        posicaoAtual = LatLng(position.latitude, position.longitude);
      });

      // Mover mapa para a posição (se o MapController estiver disponível)
      if (_mapController != null) {
        try {
          _mapController!.move(posicaoAtual!, 16);
        } catch (e) {
          LoggerService.info('Erro ao mover mapa: $e', context: context ?? 'UNKNOWN');
        }
      }
      
      // Obter endereço da posição atual
      await _obterEnderecoAtual();
      
      // Calcular rota se destino já estiver preenchido
      if (enderecoSelecionado && destinoController.text.isNotEmpty) {
        _calcularRota();
      }

    } catch (e) {
      LoggerService.error(' Erro ao obter localização: $e', context: context ?? 'UNKNOWN');
      setState(() {
        carregandoLocalizacao = false;
        origemController.text = "Erro ao obter localização";
      });
    }
  }

  Future<void> _obterEnderecoAtual() async {
    if (posicaoAtual == null) {
      LoggerService.error(' Posição atual é null', context: context ?? 'UNKNOWN');
      setState(() {
        carregandoLocalizacao = false;
        origemController.text = "Localização não disponível";
      });
      return;
    }

    LoggerService.info('🌐 Obtendo endereço para: ${posicaoAtual!.latitude}, ${posicaoAtual!.longitude}', context: context ?? 'UNKNOWN');

    final url = Uri.parse(
      'https://api.geoapify.com/v1/geocode/reverse?lat=${posicaoAtual!.latitude}&lon=${posicaoAtual!.longitude}&apiKey=203ba4a0a4304d349299a8aa22e1dcae&format=json',
    );

    try {
      final response = await http.get(url).timeout(Duration(seconds: 10));
      LoggerService.info('🌐 Status da resposta: ${response.statusCode}', context: context ?? 'UNKNOWN');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        LoggerService.info('🌐 Dados recebidos: $data', context: context ?? 'UNKNOWN');
        
        if (data['results'] != null && data['results'].isNotEmpty) {
          final endereco = data['results'][0]['formatted'] as String;
          LoggerService.success(' Endereço encontrado: $endereco', context: context ?? 'UNKNOWN');
          
          setState(() {
            origemController.text = endereco;
            carregandoLocalizacao = false;
          });
        } else {
          LoggerService.error(' Nenhum resultado encontrado', context: context ?? 'UNKNOWN');
          setState(() {
            origemController.text = "Endereço não encontrado";
            carregandoLocalizacao = false;
          });
        }
      } else {
        LoggerService.error(' Erro na API: ${response.statusCode} - ${response.body}', context: context ?? 'UNKNOWN');
        setState(() {
          origemController.text = "Erro ao obter endereço";
          carregandoLocalizacao = false;
        });
      }
    } catch (e) {
      LoggerService.error(' Erro de conexão: $e', context: context ?? 'UNKNOWN');
      setState(() {
        origemController.text = "Erro de conexão";
        carregandoLocalizacao = false;
      });
    }
  }

  void _onDestinoChanged() {
    final texto = destinoController.text.trim();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (texto.isNotEmpty && destinoFocus.hasFocus) {
        _buscarSugestoes(texto, isDestino: true);
      } else {
        setState(() {
          sugestoesDestino = [];
        });
      }
    });
  }

  void _onOrigemChanged() {
    final texto = origemController.text.trim();
    if (_debounceOrigem?.isActive ?? false) _debounceOrigem!.cancel();
    _debounceOrigem = Timer(const Duration(milliseconds: 400), () {
      if (texto.isNotEmpty && origemFocus.hasFocus) {
        _buscarSugestoes(texto, isDestino: false);
      } else {
        setState(() {
          sugestoesOrigem = [];
        });
      }
    });
  }

  void _onDestinationChanged(int index) {
    final texto = _destinationControllers[index].text.trim();
    if (_destinationDebounces[index]?.isActive ?? false) _destinationDebounces[index]!.cancel();
    _destinationDebounces[index] = Timer(const Duration(milliseconds: 400), () {
      if (texto.isNotEmpty && _destinationFocusNodes[index].hasFocus) {
        _buscarSugestoesParada(texto, index);
      } else {
        setState(() {
          _destinationSuggestions[index] = [];
        });
      }
    });
  }

  Future<void> _buscarSugestoes(String texto, {required bool isDestino}) async {
    // Construir URL com bias para localização atual e raio limitado
    String url = 'https://api.geoapify.com/v1/geocode/autocomplete?text=$texto&apiKey=203ba4a0a4304d349299a8aa22e1dcae&limit=5';
    
    // Adicionar bias para localização atual se disponível
    if (posicaoAtual != null) {
      url += '&bias=proximity:${posicaoAtual!.longitude},${posicaoAtual!.latitude}';
      // Limitar busca a um raio de 50km
      url += '&filter=circle:${posicaoAtual!.longitude},${posicaoAtual!.latitude},50000';
    }
    
    // Adicionar filtro para Brasil
    url += '&filter=countrycode:br';

    final uri = Uri.parse(url);

    try {
      final response = await http.get(uri).timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List<dynamic>;
        
        // Filtrar e ordenar por proximidade se temos localização atual
        List<String> sugestoes = features
            .map((f) => f['properties']['formatted'] as String)
            .toList();
            
        // Se temos localização atual, filtrar por distância
        if (posicaoAtual != null) {
          List<Map<String, dynamic>> sugestoesComDistancia = [];
          
          for (var feature in features) {
            final coords = feature['geometry']['coordinates'] as List<dynamic>;
            final lat = coords[1] as double;
            final lon = coords[0] as double;
            
            final distancia = Geolocator.distanceBetween(
              posicaoAtual!.latitude,
              posicaoAtual!.longitude,
              lat,
              lon,
            );
            
            // Apenas sugestões dentro de 50km
            if (distancia <= 50000) {
              sugestoesComDistancia.add({
                'endereco': feature['properties']['formatted'] as String,
                'distancia': distancia,
              });
            }
          }
          
          // Ordenar por distância
          sugestoesComDistancia.sort((a, b) => a['distancia'].compareTo(b['distancia']));
          
          sugestoes = sugestoesComDistancia
              .map((s) => s['endereco'] as String)
              .toList();
        }
        
        setState(() {
          if (isDestino) {
            sugestoesDestino = sugestoes;
          } else {
            sugestoesOrigem = sugestoes;
          }
        });
      }
    } catch (e) {
      LoggerService.info('Erro ao buscar sugestões: $e', context: context ?? 'UNKNOWN');
      setState(() {
        if (isDestino) {
          sugestoesDestino = [];
        } else {
          sugestoesOrigem = [];
        }
      });
    }
  }

  Future<void> _buscarSugestoesParada(String texto, int index) async {
    // Construir URL com bias para localização atual e raio limitado
    String url = 'https://api.geoapify.com/v1/geocode/autocomplete?text=$texto&apiKey=203ba4a0a4304d349299a8aa22e1dcae&limit=5';
    
    // Adicionar bias para localização atual se disponível
    if (posicaoAtual != null) {
      url += '&bias=proximity:${posicaoAtual!.longitude},${posicaoAtual!.latitude}';
      // Limitar busca a um raio de 50km
      url += '&filter=circle:${posicaoAtual!.longitude},${posicaoAtual!.latitude},50000';
    }
    
    // Adicionar filtro para Brasil
    url += '&filter=countrycode:br';

    final uri = Uri.parse(url);

    try {
      final response = await http.get(uri).timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List<dynamic>;
        
        // Filtrar e ordenar por proximidade se temos localização atual
        List<String> sugestoes = features
            .map((f) => f['properties']['formatted'] as String)
            .toList();
            
        // Se temos localização atual, filtrar por distância
        if (posicaoAtual != null) {
          List<Map<String, dynamic>> sugestoesComDistancia = [];
          
          for (var feature in features) {
            final coords = feature['geometry']['coordinates'] as List<dynamic>;
            final lat = coords[1] as double;
            final lon = coords[0] as double;
            
            final distancia = Geolocator.distanceBetween(
              posicaoAtual!.latitude,
              posicaoAtual!.longitude,
              lat,
              lon,
            );
            
            // Apenas sugestões dentro de 50km
            if (distancia <= 50000) {
              sugestoesComDistancia.add({
                'endereco': feature['properties']['formatted'] as String,
                'distancia': distancia,
              });
            }
          }
          
          // Ordenar por distância
          sugestoesComDistancia.sort((a, b) => a['distancia'].compareTo(b['distancia']));
          
          sugestoes = sugestoesComDistancia
              .map((s) => s['endereco'] as String)
              .toList();
        }
        
        setState(() {
          if (index < _destinationSuggestions.length) {
            _destinationSuggestions[index] = sugestoes;
          }
        });
      }
    } catch (e) {
      LoggerService.info('Erro ao buscar sugestões para parada: $e', context: context ?? 'UNKNOWN');
      setState(() {
        if (index < _destinationSuggestions.length) {
          _destinationSuggestions[index] = [];
        }
      });
    }
  }

  void _onEnderecoSelecionado(String endereco, {required bool isDestino}) {
    setState(() {
      if (isDestino) {
        destinoController.text = endereco;
        sugestoesDestino = [];
        destinoFocus.unfocus();
        enderecoSelecionado = true;
      } else {
        origemController.text = endereco;
        sugestoesOrigem = [];
        origemFocus.unfocus();
      }
    });
    _calcularRota();
  }

  void _onParadaSelecionada(String endereco, int index) {
    setState(() {
      _destinationControllers[index].text = endereco;
      _additionalDestinations[index] = endereco;
      _destinationSuggestions[index] = [];
      _destinationFocusNodes[index].unfocus();
    });
    _calcularRota();
  }

  Future<void> _calcularRota() async {
    if (destinoController.text.isEmpty || origemController.text.isEmpty) return;

    final origem = await _obterCoordenadas(origemController.text);
    final destino = await _obterCoordenadas(destinoController.text);
    if (origem == null || destino == null) return;

    final distancia = Geolocator.distanceBetween(
      origem.latitude,
      origem.longitude,
      destino.latitude,
      destino.longitude,
    );

    final distanciaKm = distancia / 1000;
    final precoBase = 15.0;
    final precoPorKm = 3.5;
    var precoTotal = precoBase + (distanciaKm * precoPorKm);

    // Adicionar custo por paradas extras
    if (_useMultipleDestinations) {
      precoTotal += (_additionalDestinations.length * 8.0);
    }

    setState(() {
      if (_useSharedRide && _maxPassengers > 1) {
        _individualPrice = precoTotal / _maxPassengers;
        valorEstimado = "R\$ ${_individualPrice.toStringAsFixed(2).replaceAll('.', ',')} por pessoa";
      } else {
        valorEstimado = "R\$ ${precoTotal.toStringAsFixed(2).replaceAll('.', ',')}";
      }
    });
  }

  Future<LatLng?> _obterCoordenadas(String endereco) async {
    final url = Uri.parse(
      'https://api.geoapify.com/v1/geocode/search?text=$endereco&apiKey=203ba4a0a4304d349299a8aa22e1dcae&limit=1',
    );

    try {
      final response = await http.get(url).timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List<dynamic>;
        if (features.isNotEmpty) {
          final coords = features[0]['geometry']['coordinates'] as List<dynamic>;
          return LatLng(coords[1], coords[0]);
        }
      }
    } catch (e) {
      LoggerService.info('Erro ao obter coordenadas: $e', context: context ?? 'UNKNOWN');
    }
    return null;
  }

  // Funções para múltiplos destinos
  void _toggleMultipleDestinations() {
    setState(() {
      _useMultipleDestinations = !_useMultipleDestinations;
      if (!_useMultipleDestinations) {
        _additionalDestinations.clear();
        for (var controller in _destinationControllers) {
          controller.dispose();
        }
        for (var focusNode in _destinationFocusNodes) {
          focusNode.dispose();
        }
        for (var timer in _destinationDebounces) {
          timer?.cancel();
        }
        _destinationControllers.clear();
        _destinationFocusNodes.clear();
        _destinationSuggestions.clear();
        _destinationDebounces.clear();
      }
      _calcularRota();
    });
  }

  void _addDestination() {
    if (_additionalDestinations.length < 3) {
      setState(() {
        _additionalDestinations.add('');
        
        final controller = TextEditingController();
        final focusNode = FocusNode();
        
        _destinationControllers.add(controller);
        _destinationFocusNodes.add(focusNode);
        _destinationSuggestions.add([]);
        _destinationDebounces.add(null);
        
        // Adicionar listener para o novo controller
        final index = _destinationControllers.length - 1;
        controller.addListener(() => _onDestinationChanged(index));
      });
    }
  }

  void _removeDestination(int index) {
    setState(() {
      _additionalDestinations.removeAt(index);
      _destinationControllers[index].dispose();
      _destinationFocusNodes[index].dispose();
      _destinationDebounces[index]?.cancel();
      
      _destinationControllers.removeAt(index);
      _destinationFocusNodes.removeAt(index);
      _destinationSuggestions.removeAt(index);
      _destinationDebounces.removeAt(index);
      
      _calcularRota();
    });
  }

  void _calculateMultipleDestinationsRoute() {
    _calcularRota();
  }

  // Função para alternar corrida compartilhada
  void _toggleSharedRide() {
    setState(() {
      _useSharedRide = !_useSharedRide;
      _calcularRota();
    });
  }

  void _navegarParaPagamento() {
    // Navegar para a tela de pagamento existente
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PagamentoScreen(
          valorCorrida: valorEstimado,
          enderecoOrigem: origemController.text,
          enderecoDestino: destinoController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          'Confirmar Corrida',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: velloCardBackground,
        elevation: 0,
        foregroundColor: velloBlue,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: velloOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back,
              color: velloOrange,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Card de origem EDITÁVEL com localização automática
            Container(
              margin: const EdgeInsets.all(16),
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
                          color: velloBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: VelloTokens.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Origem',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: velloBlue,
                        ),
                      ),
                      const Spacer(),
                      if (carregandoLocalizacao)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: velloOrange,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: origemController,
                    focusNode: origemFocus,
                    decoration: InputDecoration(
                      hintText: 'Digite o endereço de origem',
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
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _iniciarDeteccaoLocalizacao,
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: velloOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.refresh,
                        color: velloOrange,
                        size: 16,
                      ),
                    ),
                    label: Text(
                      'Atualizar localização',
                      style: TextStyle(color: velloOrange),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de sugestões de origem
            if (sugestoesOrigem.isNotEmpty && origemFocus.hasFocus)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: velloCardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: velloOrange.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: VelloTokens.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sugestoesOrigem.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: velloBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.my_location,
                          color: velloBlue,
                          size: 16,
                        ),
                      ),
                      title: Text(
                        sugestoesOrigem[index],
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _onEnderecoSelecionado(sugestoesOrigem[index], isDestino: false);
                      },
                    );
                  },
                ),
              ),

            // Card de destino com múltiplos destinos e autocompletar
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
                          Icons.location_on,
                          color: velloOrange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Para onde você vai?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: velloBlue,
                          ),
                        ),
                      ),
                      // Toggle para múltiplos destinos
                      IconButton(
                        onPressed: _toggleMultipleDestinations,
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _useMultipleDestinations
                                ? velloOrange.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add_location_alt,
                            color: _useMultipleDestinations ? velloOrange : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: destinoController,
                    focusNode: destinoFocus,
                    decoration: InputDecoration(
                      hintText: 'Digite o endereço de destino',
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

                  // Campos de múltiplos destinos COM AUTOCOMPLETAR
                  if (_useMultipleDestinations) ...[
                    const SizedBox(height: 16),
                    ...List.generate(_destinationControllers.length, (index) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _destinationControllers[index],
                                    focusNode: _destinationFocusNodes[index],
                                    decoration: InputDecoration(
                                      hintText: 'Parada ${index + 1}',
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
                                    onChanged: (value) {
                                      _additionalDestinations[index] = value;
                                      _calculateMultipleDestinationsRoute();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _removeDestination(index),
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          
                          // Sugestões para esta parada específica
                          if (index < _destinationSuggestions.length && 
                              _destinationSuggestions[index].isNotEmpty && 
                              _destinationFocusNodes[index].hasFocus)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: velloCardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: velloOrange.withOpacity(0.2)),
                                boxShadow: [
                                  BoxShadow(
                                    color: VelloTokens.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _destinationSuggestions[index].length,
                                itemBuilder: (context, suggestionIndex) {
                                  return ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: velloOrange.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.location_on,
                                        color: velloOrange,
                                        size: 16,
                                      ),
                                    ),
                                    title: Text(
                                      _destinationSuggestions[index][suggestionIndex],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                    onTap: () {
                                      _onParadaSelecionada(_destinationSuggestions[index][suggestionIndex], index);
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      );
                    }),

                    if (_additionalDestinations.length < 3)
                      TextButton.icon(
                        onPressed: _addDestination,
                        icon: Icon(Icons.add, color: velloOrange),
                        label: Text(
                          'Adicionar parada',
                          style: TextStyle(color: velloOrange),
                        ),
                      ),
                  ],
                ],
              ),
            ),

            // Lista de sugestões de destino
            if (sugestoesDestino.isNotEmpty && destinoFocus.hasFocus)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: velloCardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: velloOrange.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: VelloTokens.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sugestoesDestino.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: velloOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: velloOrange,
                          size: 16,
                        ),
                      ),
                      title: Text(
                        sugestoesDestino[index],
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _onEnderecoSelecionado(sugestoesDestino[index], isDestino: true);
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // Card de valor estimado
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valor estimado da corrida',
                    style: TextStyle(
                      fontSize: 14,
                      color: VelloTokens.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    valorEstimado,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: VelloTokens.white,
                    ),
                  ),
                ],
              ),
            ),

            // Botão de confirmar
            Container(
              margin: const EdgeInsets.all(16),
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: _dadosCompletos ? velloOrange : Colors.grey[400],
                borderRadius: BorderRadius.circular(16),
                boxShadow: _dadosCompletos ? [
                  BoxShadow(
                    color: velloOrange.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ] : null,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _dadosCompletos ? _navegarParaPagamento : null,
                child: const Text(
                  'Confirmar Corrida',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: VelloTokens.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

