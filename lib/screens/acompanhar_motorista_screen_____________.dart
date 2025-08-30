import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:math';
import '../theme/vello_tokens.dart';
import '../../core/logger_service.dart';

// TELA COMPLETA COM MAPA GEOAPIFY E RASTREAMENTO DO MOTORISTA
class AcompanharMotoristaScreen extends StatefulWidget {
  const AcompanharMotoristaScreen({Key? key}) : super(key: key);

  @override
  State<AcompanharMotoristaScreen> createState() => _AcompanharMotoristaScreenState();
}

class _AcompanharMotoristaScreenState extends State<AcompanharMotoristaScreen> {
  // CONTROLADOR DO MAPA
  final MapController _mapController = MapController();
  
  // SUA API KEY DA GEOAPIFY (substitua pela sua)
  final String _geoapifyApiKey = "SUA_API_KEY_GEOAPIFY_AQUI";
  
  // POSIÇÕES
  LatLng _posicaoPassageiro = const LatLng(-23.5505, -46.6333); // São Paulo - Centro
  LatLng _posicaoMotorista = const LatLng(-23.5605, -46.6433); // Posição inicial do motorista
  LatLng _posicaoFinalMotorista = const LatLng(-23.5505, -46.6333); // Destino (posição do passageiro)
  
  // CONTROLE DE ANIMAÇÃO
  Timer? _timer;
  double _progresso = 0.0; // 0.0 = início, 1.0 = chegou no passageiro
  
  // STATUS
  String _statusMotorista = "Motorista a caminho...";
  String _tempoEstimado = "5 min";
  String _distancia = "2.1 km";
  
  // CONTROLE DE INICIALIZAÇÃO
  bool _jaInicializou = false;

  @override
  void initState() {
    super.initState();
    // Apenas inicializações que não dependem do context
    LoggerService.info('Inicializando tela de rastreamento...', context: context ?? 'UNKNOWN');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_jaInicializou) {
      _inicializarRastreamento();
      _jaInicializou = true;
    }
  }

  void _inicializarRastreamento() {
    // Iniciar simulação de movimento do motorista
    _iniciarSimulacaoMovimento();
    
    // Centralizar mapa após um pequeno delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _centralizarMapa();
    });
  }

  void _iniciarSimulacaoMovimento() {
    // Timer que atualiza a posição do motorista a cada 2 segundos
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_progresso < 1.0) {
        setState(() {
          // Incrementar progresso (motorista se aproxima)
          _progresso += 0.1;
          
          // Calcular nova posição do motorista (interpolação linear)
          double lat = _lerp(-23.5605, _posicaoFinalMotorista.latitude, _progresso);
          double lng = _lerp(-46.6433, _posicaoFinalMotorista.longitude, _progresso);
          
          _posicaoMotorista = LatLng(lat, lng);
          
          // Atualizar status baseado no progresso
          if (_progresso < 0.3) {
            _statusMotorista = "Motorista a caminho...";
            _tempoEstimado = "${(5 * (1 - _progresso)).toInt()} min";
            _distancia = "${(2.1 * (1 - _progresso)).toStringAsFixed(1)} km";
          } else if (_progresso < 0.7) {
            _statusMotorista = "Motorista se aproximando...";
            _tempoEstimado = "${(3 * (1 - _progresso)).toInt()} min";
            _distancia = "${(1.5 * (1 - _progresso)).toStringAsFixed(1)} km";
          } else if (_progresso < 0.95) {
            _statusMotorista = "Motorista chegando...";
            _tempoEstimado = "1 min";
            _distancia = "${(0.5 * (1 - _progresso)).toStringAsFixed(1)} km";
          } else {
            _statusMotorista = "Motorista chegou!";
            _tempoEstimado = "Agora";
            _distancia = "0 m";
          }
          
          // Mover câmera para acompanhar o motorista
          _moverCameraParaMotorista();
        });
      } else {
        // Motorista chegou - parar timer
        timer.cancel();
        _mostrarDialogChegada();
      }
    });
  }

  // Função de interpolação linear
  double _lerp(double inicio, double fim, double t) {
    return inicio + (fim - inicio) * t;
  }

  void _moverCameraParaMotorista() {
    _mapController.move(_posicaoMotorista, _mapController.camera.zoom);
  }

  void _mostrarDialogChegada() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Motorista Chegou!'),
          content: const Text('O motorista está esperando por você. Dirija-se ao local de embarque.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Voltar para tela anterior
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _centralizarMapa() {
    // Calcular bounds para mostrar passageiro e motorista
    double minLat = min(_posicaoPassageiro.latitude, _posicaoMotorista.latitude);
    double maxLat = max(_posicaoPassageiro.latitude, _posicaoMotorista.latitude);
    double minLng = min(_posicaoPassageiro.longitude, _posicaoMotorista.longitude);
    double maxLng = max(_posicaoPassageiro.longitude, _posicaoMotorista.longitude);
    
    // Calcular centro
    LatLng centro = LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );
    
    _mapController.move(centro, 14.0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acompanhar Motorista'),
        backgroundColor: const VelloTokens.brandBlue, // Azul escuro como na imagem
        foregroundColor: VelloTokens.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: _centralizarMapa,
            tooltip: 'Centralizar Mapa',
          ),
        ],
      ),
      body: Stack(
        children: [
          // MAPA COM GEOAPIFY
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _posicaoPassageiro,
              initialZoom: 14.0,
              minZoom: 10.0,
              maxZoom: 18.0,
            ),
            children: [
              // TILES DO MAPA (GEOAPIFY)
              TileLayer(
                urlTemplate: 'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=$_geoapifyApiKey',
                userAgentPackageName: 'com.example.app',
                maxZoom: 18,
              ),
              
              // MARKERS
              MarkerLayer(
                markers: [
                  // MARKER DO PASSAGEIRO
                  Marker(
                    point: _posicaoPassageiro,
                    width: 60,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: VelloTokens.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: VelloTokens.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: VelloTokens.white,
                        size: 30,
                      ),
                    ),
                  ),
                  
                  // MARKER DO MOTORISTA (TÁXI)
                  Marker(
                    point: _posicaoMotorista,
                    width: 60,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: VelloTokens.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: VelloTokens.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_taxi,
                        color: VelloTokens.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // PAINEL DE INFORMAÇÕES (parte inferior)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: VelloTokens.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: VelloTokens.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // INDICADOR DE PROGRESSO
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // INFORMAÇÕES DO MOTORISTA
                  Row(
                    children: [
                      // ÍCONE DO TÁXI
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const VelloTokens.brandBlue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.local_taxi,
                          color: VelloTokens.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // DETALHES
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'João Silva',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Honda Civic - ABC-1234',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _statusMotorista,
                              style: const TextStyle(
                                fontSize: 16,
                                color: VelloTokens.brandBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // BOTÃO DE LIGAR
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.phone, color: VelloTokens.white),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ligando para o motorista...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // INFORMAÇÕES DE TEMPO E DISTÂNCIA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoCard(
                        icon: Icons.access_time,
                        titulo: 'Tempo',
                        valor: _tempoEstimado,
                      ),
                      _buildInfoCard(
                        icon: Icons.straighten,
                        titulo: 'Distância',
                        valor: _distancia,
                      ),
                      _buildInfoCard(
                        icon: Icons.speed,
                        titulo: 'Progresso',
                        valor: '${(_progresso * 100).toInt()}%',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // BARRA DE PROGRESSO
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Progresso da viagem',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _progresso,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(VelloTokens.brandBlue),
                        minHeight: 6,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // BOTÃO DE CANCELAR
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        _mostrarDialogCancelamento();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Cancelar Corrida',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String titulo,
    required String valor,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: const VelloTokens.brandBlue,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          titulo,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: VelloTokens.brandBlue,
          ),
        ),
      ],
    );
  }

  void _mostrarDialogCancelamento() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar Corrida'),
          content: const Text('Tem certeza que deseja cancelar esta corrida?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () {
                _timer?.cancel();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Corrida cancelada'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text(
                'Sim, Cancelar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

