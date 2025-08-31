import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../configuracoes/configuracoes_screen.dart';
import '../historico/historico_screen.dart';
import '../login_screen.dart';
import '../perfil/perfil_screen.dart';

import '../ride_request_screen.dart';
import '../../core/logger_service.dart';
import '../../services/auth_permanente_service.dart';
import '../../services/firebase_service.dart';
import '../../services/geolocation_service.dart';
import '../../theme/vello_tokens.dart';
import '../../widgets/security/simple_trip_sharing.dart';
import '../../routes/app_routes.dart';

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
              color: VelloTokens.brandOrange,
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
  final GeolocationService _geoService = GeolocationService();
  StreamSubscription<Position>? _positionSubscription;
  
  // Variáveis para auto-follow
  bool _isUserInteracting = false;
  bool _followUser = true;
  Timer? _userInteractionTimer;
  
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
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _userInteractionTimer?.cancel();
    _geoService.dispose();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    final hasPermission = await _geoService.checkAndRequestPermissions();
    if (!hasPermission) return;

    _positionSubscription = _geoService.positionStream.listen(
      (Position position) {
        final newLocation = LatLng(position.latitude, position.longitude);
        
        setState(() {
          currentLocation = newLocation;
        });

        // Auto-follow: centralizar automaticamente quando não há interação
        if (_followUser && !_isUserInteracting) {
          _mapController.move(newLocation, _mapController.camera.zoom);
        }
      },
      onError: (error) {
        LoggerService.info('Erro no stream de localização: $error', context: 'HomeScreen');
      },
    );
  }

  void _onUserInteraction() {
    if (!_isUserInteracting) {
      setState(() {
        _isUserInteracting = true;
        _followUser = false;
      });
    }
    
    // Reset timer a cada interação
    _userInteractionTimer?.cancel();
    _userInteractionTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isUserInteracting = false;
          // Não reeativa auto-follow automaticamente, usuário deve usar botão
        });
      }
    });
  }

  void _ativarAutoFollow() {
    setState(() {
      _followUser = true;
      _isUserInteracting = false;
    });
    
    // Centralizar imediatamente na localização atual
    if (currentLocation != null) {
      _mapController.move(currentLocation!, 16);
    }
    
    _userInteractionTimer?.cancel();
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

    if (currentLocation != null) {
      _mapController.move(currentLocation!, 16);
    }
  }

  void _centralizarMapa() {
    _ativarAutoFollow();
  }

  // Navegar para nova tela de solicitação de corrida
  void _navegarParaConfirmacao() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideRequestScreen(
          initialDestination: '',
        ),
      ),
    );
  }

  Future<void> _checkActiveSharedTrip() async {
    setState(() {
      _isTripShared = false;
    });
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

  // Função para ativar SOS conforme especificado no prompt
  void _activateSOS() {
    Navigator.pushNamed(context, AppRoutes.sosScreen);
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
                  MaterialPageRoute(builder: (context) => PerfilScreen()),
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
                    builder: (context) => HistoricoScreen(),
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
                    builder: (context) => ConfiguracoesScreen(),
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
                  MaterialPageRoute(builder: (context) => LoginScreen()),
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
      // Botão SOS flutuante conforme especificado no prompt
      floatingActionButton: FloatingActionButton(
        onPressed: _activateSOS,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        tooltip: 'Emergência SOS',
        child: const Icon(
          Icons.emergency,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          Column(
            children: [
              // Banner clicável que navega para confirmação de corrida
              GestureDetector(
                onTap: _navegarParaConfirmacao,
                child: WelcomeBanner(userName: widget.userName),
              ),
              
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
                              initialCenter: currentLocation ?? const LatLng(-23.5505, -46.6333),
                              initialZoom: 16,
                              minZoom: 12.0,
                              // Detectar interações do usuário
                              onTap: (_, __) => _onUserInteraction(),
                              onSecondaryTap: (_, __) => _onUserInteraction(),
                              onLongPress: (_, __) => _onUserInteraction(),
                              onPositionChanged: (_, bool hasGesture) {
                                if (hasGesture) {
                                  _onUserInteraction();
                                }
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.vello.passenger',
                              ),
                              MarkerLayer(
                                markers: [
                                  if (currentLocation != null)
                                    Marker(
                                      point: currentLocation!,
                                      width: 60,
                                      height: 60,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: velloOrange,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: VelloTokens.white,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: VelloTokens.black.withOpacity(0.3),
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
          
          // Botão de centralizar mapa
          if (currentLocation != null && !_followUser)
            Positioned(
              right: 16,
              bottom: 100,
              child: FloatingActionButton.small(
                onPressed: _centralizarMapa,
                backgroundColor: velloCardBackground,
                foregroundColor: velloBlue,
                child: const Icon(Icons.my_location),
              ),
            ),

          // Widget de compartilhamento de viagem
          if (_isTripShared && currentLocation != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: SimpleTripSharing(
                // currentLocation: currentLocation!,
                // onStop: _stopTripSharing, // Parâmetro removido
              ),
            ),

          // Status de corrida ativa (se houver)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('corridas')
                  .where('passageiroId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .where('status', whereIn: ['aceita', 'em_andamento'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const SizedBox.shrink();
                }

                final corrida = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                final nomeMotorista = corrida['nomeMotorista'] ?? 'Motorista';
                final placaVeiculo = corrida['placaVeiculo'] ?? 'ABC-1234';
                final tempoEstimado = '5 min';
                final distancia = '1.2 km';

                return Container(
                  margin: const EdgeInsets.only(bottom: 80),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: velloCardBackground,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: VelloTokens.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: velloOrange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.local_taxi,
                              color: VelloTokens.white,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Motorista a caminho',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: velloBlue,
                                  ),
                                ),
                                Text(
                                  '$nomeMotorista • $placaVeiculo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Text(
                              tempoEstimado,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
                                SizedBox(width: 4),
                                Text(
                                  'Distância: $distancia',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Simular ligação
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ligando para $nomeMotorista...')),
                              );
                            },
                            icon: Icon(Icons.phone, size: 16),
                            label: Text('Ligar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: VelloTokens.white,
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size(0, 32),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

