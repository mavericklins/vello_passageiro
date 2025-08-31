import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../theme/vello_tokens.dart';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

class BuscandoMotoristasScreen extends StatefulWidget {
  final String corridaId;
  final LatLng? localizacaoPassageiro;

  const BuscandoMotoristasScreen({
    Key? key,
    required this.corridaId,
    this.localizacaoPassageiro,
  }) : super(key: key);

  @override
  State<BuscandoMotoristasScreen> createState() => _BuscandoMotoristasScreenState();
}

class _BuscandoMotoristasScreenState extends State<BuscandoMotoristasScreen>
    with TickerProviderStateMixin {

  late MapController _mapController;
  LatLng? _currentLocation;
  List<Map<String, dynamic>> _motoristasProximos = [];
  StreamSubscription<DocumentSnapshot>? _corridaSubscription;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _setupAnimations();
    _getCurrentLocation();
    _buscarMotoristasProximos();
    _monitorarCorrida();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  Future<void> _getCurrentLocation() async {
    if (widget.localizacaoPassageiro != null) {
      setState(() {
        _currentLocation = widget.localizacaoPassageiro;
      });
      if (_currentLocation != null) {
        _mapController.move(_currentLocation!, 15);
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      if (_currentLocation != null) {
        _mapController.move(_currentLocation!, 15);
      }
    } catch (e) {
      LoggerService.info('Erro ao obter localização: $e', context: 'BuscandoMotoristasScreen');
    }
  }

  Future<void> _buscarMotoristasProximos() async {
    if (_currentLocation == null) return;

    try {
      final motoristasSnapshot = await FirebaseFirestore.instance
          .collection('motoristas')
          .where('disponivel', isEqualTo: true)
          .where('status', isEqualTo: 'disponivel')
          .get();

      List<Map<String, dynamic>> motoristasProximos = [];

      for (var doc in motoristasSnapshot.docs) {
        final data = doc.data();
        final localizacao = data['localizacao'];

        if (localizacao != null) {
          final motoristaLat = localizacao['latitude'];
          final motoristaLng = localizacao['longitude'];

          final distancia = Geolocator.distanceBetween(
            _currentLocation?.latitude ?? 0,
            _currentLocation?.longitude ?? 0,
            motoristaLat,
            motoristaLng,
          );

          if (distancia <= 10000) {
            motoristasProximos.add({
              'id': doc.id,
              'nome': data['nome'] ?? 'Motorista',
              'latitude': motoristaLat,
              'longitude': motoristaLng,
              'distancia': distancia,
              'veiculo': data['veiculo'] ?? 'Veículo',
              'placa': data['placaVeiculo'] ?? 'ABC-1234',
              'avaliacao': data['avaliacao'] ?? 4.5,
            });
          }
        }
      }

      motoristasProximos.sort((a, b) => a['distancia'].compareTo(b['distancia']));

      setState(() {
        _motoristasProximos = motoristasProximos;
      });

    } catch (e) {
      LoggerService.info('Erro ao buscar motoristas: $e', context: 'BuscandoMotoristasScreen');
    }
  }

  void _monitorarCorrida() {
    _corridaSubscription = FirebaseFirestore.instance
        .collection('corridas')
        .doc(widget.corridaId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data == null) return;
        
        final status = data['status'];

        if (status == 'aceita' && data['motoristaId'] != null) {
          _corridaAceita(data['motoristaId']);
        }
      }
    });
  }

  void _corridaAceita(String motoristaId) {
    _pulseController.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Motorista Encontrado!'),
          ],
        ),
        content: Text('Um motorista aceitou sua corrida e está a caminho.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/home');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Ver no Mapa', style: TextStyle(color: VelloTokens.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _corridaSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: Text('Buscando Motoristas'),
        backgroundColor: velloBlue,
        foregroundColor: VelloTokens.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _cancelarCorrida();
          },
        ),
      ),
      body: Stack(
        children: [
          if (_currentLocation != null)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation ?? const LatLng(-23.5505, -46.6333),
                initialZoom: 15,
                minZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://maps.geoapify.com/v1/tile/osm-carto/{z}/{x}/{y}.png?apiKey=203ba4a0a4304d349299a8aa22e1dcae',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 60,
                      height: 60,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: velloOrange,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: VelloTokens.white, width: 3),
                              ),
                              child: Icon(Icons.person, color: VelloTokens.white, size: 30),
                            ),
                          );
                        },
                      ),
                    ),
                    ..._motoristasProximos.map((motorista) {
                      return Marker(
                        point: LatLng(motorista['latitude'], motorista['longitude']),
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: velloBlue,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: VelloTokens.white, width: 2),
                          ),
                          child: Icon(Icons.local_taxi, color: VelloTokens.white, size: 25),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: VelloTokens.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(velloOrange),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Procurando motoristas próximos...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: velloBlue,
                                ),
                              ),
                              Text(
                                '${_motoristasProximos.length} motoristas encontrados',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _cancelarCorrida,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Cancelar Busca', style: TextStyle(color: VelloTokens.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelarCorrida() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        final bool? fazerLogin = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Login Necessário'),
            content: Text('Você precisa estar logado para cancelar a busca.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Fazer Login'),
              ),
            ],
          ),
        );

        if (fazerLogin == true) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
        return;
      }

      final bool? confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Cancelar Busca'),
          content: Text('Tem certeza que deseja cancelar a busca por motoristas?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Não'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Sim, Cancelar', style: TextStyle(color: VelloTokens.white)),
            ),
          ],
        ),
      );

      if (confirmar != true) return;

      final docRef = FirebaseFirestore.instance.collection('corridas').doc(widget.corridaId);

      try {
        await docRef.update({
          'status': 'cancelada',
          'canceladaEm': FieldValue.serverTimestamp(),
          'canceladaPor': 'passageiro',
          'passageiroId': user.uid,
          'passageiroEmail': user.email,
        });
      } catch (updateError) {
        await docRef.set({
          'status': 'cancelada',
          'canceladaEm': FieldValue.serverTimestamp(),
          'canceladaPor': 'passageiro',
          'passageiroId': user.uid,
          'passageiroEmail': user.email,
          'criadoEm': FieldValue.serverTimestamp(),
          'corridaId': widget.corridaId,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Busca cancelada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cancelar busca. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}