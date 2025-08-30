import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vello/screens/home/confirmacao_corrida.dart';
import 'package:vello/services/firebase_service.dart';
import 'components/home_widgets.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vello/screens/perfil/perfil_screen.dart';
import 'package:vello/screens/historico/historico_screen.dart';
import 'package:vello/screens/configuracoes/configuracoes_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vello/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng? currentLocation;
  late final MapController _mapController;
  final TextEditingController _buscaController = TextEditingController();
  List<String> enderecosRecentes = [];
  List<String> sugestoes = [];
  bool mostrandoSugestoes = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
    _carregarHistorico();
    _buscaController.addListener(_onBuscaChanged);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always)
        return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });

    _mapController.move(currentLocation!, 16);
  }

  void _centralizarMapa() {
    if (currentLocation != null) {
      _mapController.move(currentLocation!, 16);
    }
  }

  Future<void> _salvarEndereco() async {
    final texto = _buscaController.text.trim();
    if (texto.isEmpty) return;

    await FirebaseService.salvarEnderecoNoHistorico(texto);
    _buscaController.clear();
    await _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    final lista = await FirebaseService.buscarUltimosEnderecos();
    setState(() {
      enderecosRecentes = lista;
    });
  }

  void _onBuscaChanged() {
    final texto = _buscaController.text.trim();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (texto.isNotEmpty) {
        buscarSugestoes(texto);
      } else {
        setState(() {
          sugestoes = [];
          mostrandoSugestoes = false;
        });
      }
    });
  }

  Future<void> buscarSugestoes(String texto) async {
    final url = Uri.parse(
      'https://api.geoapify.com/v1/geocode/autocomplete?text=$texto&apiKey=203ba4a0a4304d349299a8aa22e1dcae&limit=5',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final features = data['features'] as List<dynamic>;
        setState(() {
          sugestoes = features
              .map((f) => f['properties']['formatted'] as String)
              .toList();
          mostrandoSugestoes = true;
        });
      } else {
        setState(() {
          sugestoes = [];
          mostrandoSugestoes = false;
        });
      }
    } catch (e) {
      setState(() {
        sugestoes = [];
        mostrandoSugestoes = false;
      });
    }
  }

  void _selecionarSugestao(String sugestao) async {
    _buscaController.text = sugestao;
    setState(() {
      mostrandoSugestoes = false;
      sugestoes = [];
    });
    await FirebaseService.salvarEnderecoNoHistorico(sugestao);
    await _carregarHistorico();
    FocusScope.of(context).unfocus(); // Fecha o teclado
    if (currentLocation != null) {
      print('Navegando para confirmação de corrida');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              ConfirmacaoCorridaScreen(enderecoInicial: sugestao),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Localização não disponível'),
          content: const Text('Não foi possível obter sua localização atual.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAbaInferior() {
    final hasHistorico = enderecosRecentes.isNotEmpty;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para onde vamos, ${widget.userName.split(" ").first}?',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 166, 82),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _buscaController,
                      readOnly:
                          true, // impede digitar direto na barra principal
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfirmacaoCorridaScreen(
                              enderecoInicial: _buscaController.text,
                            ),
                          ),
                        );
                      },
                      decoration: const InputDecoration(
                        hintText: 'Escolher destino',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _salvarEndereco,
                  ),
                ],
              ),
            ),
            if (mostrandoSugestoes && sugestoes.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 115, 0),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sugestoes.length > 3 ? 3 : sugestoes.length,
                  itemBuilder: (context, index) {
                    final sugestao = sugestoes[index];
                    return ListTile(
                      title: Text(sugestao),
                      onTap: () => _selecionarSugestao(sugestao),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            if (hasHistorico)
              ...enderecosRecentes.map(
                (e) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time, size: 20),
                  title: const Text('Recente', style: TextStyle(fontSize: 12)),
                  subtitle: Text(
                    e,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vello'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PerfilScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HistoricoScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurações',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ConfiguracoesScreen(),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'sair') {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Limpa SharedPreferences
                await FirebaseAuth.instance.signOut(); // Desloga do Firebase
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false, // Remove todas as rotas anteriores
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(value: 'sair', child: Text('Sair')),
            ],
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Column(
            children: [
              WelcomeBanner(userName: widget.userName),
              Expanded(
                child: currentLocation == null
                    ? const Center(child: CircularProgressIndicator())
                    : FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: currentLocation,
                          zoom: 16,
                          minZoom: 12.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://maps.geoapify.com/v1/tile/osm-carto/{z}/{x}/{y}.png?apiKey=203ba4a0a4304d349299a8aa22e1dcae',
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: currentLocation!,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.blue,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
          if (currentLocation != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              bottom: keyboardOpen
                  ? 16 + MediaQuery.of(context).viewInsets.bottom
                  : 190,
              right: 20,
              child: FloatingActionButton(
                heroTag: "btnCentralizar",
                onPressed: _centralizarMapa,
                backgroundColor: Colors.orange,
                child: const Icon(Icons.my_location, color: Colors.blue),
              ),
            ),
          _buildAbaInferior(),
        ],
      ),
    );
  }
}

