import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/firebase_service.dart';
import '../pagamento/confirmacao_corrida.dart';
import '../../widgets/security/simple_trip_sharing.dart';
import 'package:vello/screens/perfil/perfil_screen.dart';
import 'package:vello/screens/historico/historico_screen.dart';
import 'package:vello/screens/configuracoes/configuracoes_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vello/screens/login_screen.dart';
import '../../services/auth_permanente_service.dart';
import '../../theme/vello_tokens.dart';

class WelcomeBanner extends StatelessWidget {
  final String userName;

  const WelcomeBanner({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [VelloTokens.brandBlue, VelloTokens.brandBlueLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: VelloTokens.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, $userName!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: VelloTokens.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Para onde vamos hoje?',
                  style: TextStyle(
                    fontSize: 16,
                    color: VelloTokens.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const VelloTokens.brandOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car,
              color: VelloTokens.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng? currentLocation;
  late final MapController _mapController;
  
  // Variáveis para compartilhamento de viagem
  String? _activeSharedTripId;
  bool _isTripShared = false;

  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;
  static const Color velloCardBackground = VelloTokens.white;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
    _checkActiveSharedTrip();
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

  // Navegar para tela de confirmação de corrida
  void _navegarParaConfirmacao() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmacaoCorridaScreen(
          enderecoInicial: '',
        ),
      ),
    );
  }

  Future<void> _checkActiveSharedTrip() async {
    setState(() {
      _isTripShared = false;
    });
  }

  void _showTripSharingModal() {
    if (currentLocation == null) {
      _showLocationRequiredDialog();
      return;
    }

    final tripId = 'trip_${DateTime.now().millisecondsSinceEpoch}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SimpleTripSharingWidget(
        tripId: tripId,
        onShared: () {
          setState(() {
            _activeSharedTripId = tripId;
            _isTripShared = true;
          });
        },
      ),
    );
  }

  void _showLocationRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_off, color: velloOrange),
            SizedBox(width: 8),
            Text('Localização Necessária'),
          ],
        ),
        content: Text(
          'Para compartilhar sua viagem, precisamos da sua localização atual. '
          'Aguarde enquanto obtemos sua posição.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: velloOrange)),
          ),
        ],
      ),
    );
  }

  Future<void> _stopTripSharing() async {
    setState(() {
      _activeSharedTripId = null;
      _isTripShared = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartilhamento finalizado'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: velloOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: VelloTokens.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Vello',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: velloBlue,
              ),
            ),
          ],
        ),
        backgroundColor: velloCardBackground,
        elevation: 0,
        foregroundColor: velloBlue,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: velloOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: velloOrange,
                  size: 20,
                ),
              ),
              tooltip: 'Perfil',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PerfilScreen()),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: velloBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.history,
                  color: velloBlue,
                  size: 20,
                ),
              ),
              tooltip: 'Histórico',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HistoricoScreen(),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
              tooltip: 'Configurações',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ConfiguracoesScreen(),
                  ),
                );
              },
            ),
          ),
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.more_vert,
                color: Colors.red,
                size: 20,
              ),
            ),
            onSelected: (value) async {
              if (value == 'sair') {
                // Usar logout seguro que limpa armazenamento seguro
                await AuthPermanenteService.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'sair',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Column(
            children: [
              // Banner clicável que navega para confirmação de corrida
              GestureDetector(
                onTap: _navegarParaConfirmacao,
                child: WelcomeBanner(userName: widget.userName),
              ),
              
              // REMOVIDO COMPLETAMENTE O CARD DE DESTINO
              
              Expanded(
                child: currentLocation == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: velloOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: CircularProgressIndicator(
                                color: velloOrange,
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Obtendo sua localização...',
                              style: TextStyle(
                                fontSize: 16,
                                color: velloBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: VelloTokens.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: FlutterMap(
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
                                    width: 50,
                                    height: 50,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: velloOrange,
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                          color: VelloTokens.white,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: VelloTokens.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: VelloTokens.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
                  : 40,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: VelloTokens.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      heroTag: "btnCompartilhar",
                      onPressed: _isTripShared ? _stopTripSharing : _showTripSharingModal,
                      backgroundColor: _isTripShared ? Colors.green : velloBlue,
                      foregroundColor: VelloTokens.white,
                      elevation: 0,
                      child: Icon(
                        _isTripShared ? Icons.stop : Icons.security,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: VelloTokens.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      heroTag: "btnCentralizar",
                      onPressed: _centralizarMapa,
                      backgroundColor: velloOrange,
                      foregroundColor: VelloTokens.white,
                      elevation: 0,
                      child: const Icon(Icons.my_location, size: 24),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

