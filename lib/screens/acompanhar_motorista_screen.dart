import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';
import '../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

// TELA REAL COM BUSCA POR MOTORISTAS NO FIREBASE - VERSÃO CORRIGIDA
class AcompanharMotoristaScreen extends StatefulWidget {
  final String? corridaId; // ID da corrida atual (opcional para compatibilidade)
  
  const AcompanharMotoristaScreen({
    Key? key,
    this.corridaId, // Agora é opcional
  }) : super(key: key);

  @override
  State<AcompanharMotoristaScreen> createState() => _AcompanharMotoristaScreenState();
}

class _AcompanharMotoristaScreenState extends State<AcompanharMotoristaScreen> {
  // CONTROLADOR DO MAPA
  final MapController _mapController = MapController();
  
  // SUA API KEY DA GEOAPIFY - SUBSTITUA PELA SUA CHAVE REAL
  final String _geoapifyApiKey = "203ba4a0a4304d349299a8aa22e1dcae";
  
  // FIREBASE
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // POSIÇÕES
  LatLng _posicaoPassageiro = const LatLng(-23.5505, -46.6333);
  LatLng? _posicaoMotorista;
  
  // DADOS DA CORRIDA
  Map<String, dynamic>? _dadosCorrida;
  Map<String, dynamic>? _dadosMotorista;
  List<Map<String, dynamic>> _motoristasProximos = [];
  
  // CONTROLE DE ESTADO
  String _statusCorrida = "procurando"; // procurando, aceita, em_andamento, concluida
  Timer? _timerBusca;
  Timer? _timerRastreamento;
  StreamSubscription<DocumentSnapshot>? _corridaSubscription;
  StreamSubscription<QuerySnapshot>? _motoristasSubscription;
  
  // CONTROLE DE INICIALIZAÇÃO
  bool _jaInicializou = false;

  @override
  void initState() {
    super.initState();
    LoggerService.info('Inicializando busca por motoristas...', context: context ?? 'UNKNOWN');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_jaInicializou) {
      _inicializarBuscaPorMotoristas();
      _jaInicializou = true;
    }
  }

  void _inicializarBuscaPorMotoristas() {
    // Se tem corridaId, buscar dados da corrida
    if (widget.corridaId != null) {
      _buscarDadosCorrida();
      _escutarMudancasCorrida();
    } else {
      // Modo demonstração - apenas buscar motoristas próximos
      _statusCorrida = "procurando";
    }
    
    // Buscar motoristas próximos
    _buscarMotoristasProximos();
    
    // Centralizar mapa
    Future.delayed(const Duration(milliseconds: 1000), () {
      _centralizarMapa();
    });
  }

  void _buscarDadosCorrida() async {
    if (widget.corridaId == null) return;
    
    try {
      DocumentSnapshot doc = await _firestore
          .collection('corridas')
          .doc(widget.corridaId!)
          .get();
      
      if (doc.exists) {
        setState(() {
          _dadosCorrida = doc.data() as Map<String, dynamic>;
          _statusCorrida = _dadosCorrida!['status'] ?? 'procurando';
          
          // Definir posição do passageiro
          if (_dadosCorrida!['origem'] != null) {
            _posicaoPassageiro = LatLng(
              _dadosCorrida!['origem']['latitude'],
              _dadosCorrida!['origem']['longitude'],
            );
          }
        });
      }
    } catch (e) {
      LoggerService.info('Erro ao buscar dados da corrida: $e', context: context ?? 'UNKNOWN');
    }
  }

  void _escutarMudancasCorrida() {
    if (widget.corridaId == null) return;
    
    _corridaSubscription = _firestore
        .collection('corridas')
        .doc(widget.corridaId!)
        .snapshots()
        .listen((DocumentSnapshot doc) {
      if (doc.exists) {
        Map<String, dynamic> dados = doc.data() as Map<String, dynamic>;
        
        setState(() {
          _dadosCorrida = dados;
          _statusCorrida = dados['status'] ?? 'procurando';
        });
        
        // Se a corrida foi aceita, buscar dados do motorista
        if (_statusCorrida == 'aceita' && dados['motoristaId'] != null) {
          _buscarDadosMotorista(dados['motoristaId']);
          _iniciarRastreamentoMotorista();
        }
      }
    });
  }

  void _buscarMotoristasProximos() {
    // Buscar motoristas online e disponíveis
    _motoristasSubscription = _firestore
        .collection('motoristas')
        .where('status', isEqualTo: 'online')
        .where('disponivel', isEqualTo: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      
      List<Map<String, dynamic>> motoristasProximos = [];
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> motorista = doc.data() as Map<String, dynamic>;
        motorista['id'] = doc.id;
        
        // Calcular distância do motorista até o passageiro
        if (motorista['localizacao'] != null) {
          double distancia = _calcularDistancia(
            _posicaoPassageiro.latitude,
            _posicaoPassageiro.longitude,
            motorista['localizacao']['latitude'],
            motorista['localizacao']['longitude'],
          );
          
          // Apenas motoristas num raio de 10km
          if (distancia <= 10.0) {
            motorista['distancia'] = distancia;
            motoristasProximos.add(motorista);
          }
        }
      }
      
      // Ordenar por distância
      motoristasProximos.sort((a, b) => 
        a['distancia'].compareTo(b['distancia']));
      
      setState(() {
        _motoristasProximos = motoristasProximos;
      });
    }, onError: (error) {
      LoggerService.info('Erro ao buscar motoristas: $error', context: context ?? 'UNKNOWN');
      // Se não conseguir conectar ao Firebase, mostrar motoristas fictícios para demonstração
      _criarMotoristasDemo();
    });
  }

  void _criarMotoristasDemo() {
    // Motoristas fictícios para demonstração quando não há Firebase
    setState(() {
      _motoristasProximos = [
        {
          'id': 'demo1',
          'nome': 'João Silva',
          'distancia': 1.2,
          'localizacao': {
            'latitude': -23.5525,
            'longitude': -46.6353,
          },
          'veiculo': {'modelo': 'Honda Civic', 'placa': 'ABC-1234'},
        },
        {
          'id': 'demo2',
          'nome': 'Maria Santos',
          'distancia': 2.1,
          'localizacao': {
            'latitude': -23.5485,
            'longitude': -46.6313,
          },
          'veiculo': {'modelo': 'Toyota Corolla', 'placa': 'DEF-5678'},
        },
        {
          'id': 'demo3',
          'nome': 'Carlos Lima',
          'distancia': 3.5,
          'localizacao': {
            'latitude': -23.5545,
            'longitude': -46.6373,
          },
          'veiculo': {'modelo': 'Hyundai HB20', 'placa': 'GHI-9012'},
        },
      ];
    });
  }

  void _buscarDadosMotorista(String motoristaId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('motoristas')
          .doc(motoristaId)
          .get();
      
      if (doc.exists) {
        setState(() {
          _dadosMotorista = doc.data() as Map<String, dynamic>;
          
          if (_dadosMotorista!['localizacao'] != null) {
            _posicaoMotorista = LatLng(
              _dadosMotorista!['localizacao']['latitude'],
              _dadosMotorista!['localizacao']['longitude'],
            );
          }
        });
      }
    } catch (e) {
      LoggerService.info('Erro ao buscar dados do motorista: $e', context: context ?? 'UNKNOWN');
    }
  }

  void _iniciarRastreamentoMotorista() {
    if (_dadosCorrida == null || _dadosCorrida!['motoristaId'] == null) return;
    
    // Escutar mudanças na localização do motorista
    _timerRastreamento = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('motoristas')
            .doc(_dadosCorrida!['motoristaId'])
            .get();
        
        if (doc.exists) {
          Map<String, dynamic> dados = doc.data() as Map<String, dynamic>;
          
          if (dados['localizacao'] != null) {
            setState(() {
              _posicaoMotorista = LatLng(
                dados['localizacao']['latitude'],
                dados['localizacao']['longitude'],
              );
              _dadosMotorista = dados;
            });
          }
        }
      } catch (e) {
        LoggerService.info('Erro ao rastrear motorista: $e', context: context ?? 'UNKNOWN');
      }
    });
  }

  double _calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Raio da Terra em km
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  void _centralizarMapa() {
    if (_statusCorrida == 'aceita' && _posicaoMotorista != null) {
      // Mostrar passageiro e motorista
      double minLat = min(_posicaoPassageiro.latitude, _posicaoMotorista!.latitude);
      double maxLat = max(_posicaoPassageiro.latitude, _posicaoMotorista!.latitude);
      double minLng = min(_posicaoPassageiro.longitude, _posicaoMotorista!.longitude);
      double maxLng = max(_posicaoPassageiro.longitude, _posicaoMotorista!.longitude);
      
      LatLng centro = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
      _mapController.move(centro, 14.0);
    } else {
      // Centralizar no passageiro
      _mapController.move(_posicaoPassageiro, 15.0);
    }
  }

  void _cancelarCorrida() async {
    if (widget.corridaId != null) {
      try {
        await _firestore.collection('corridas').doc(widget.corridaId!).update({
          'status': 'cancelada',
          'dataHoraCancelamento': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        LoggerService.info('Erro ao cancelar corrida: $e', context: context ?? 'UNKNOWN');
      }
    }
    
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Corrida cancelada'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _timerBusca?.cancel();
    _timerRastreamento?.cancel();
    _corridaSubscription?.cancel();
    _motoristasSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acompanhar Motorista'),
        backgroundColor: const VelloTokens.brandBlue,
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
              initialZoom: 15.0,
              minZoom: 10.0,
              maxZoom: 18.0,
            ),
            children: [
              // TILES DO MAPA
              TileLayer(
                urlTemplate: 'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=$_geoapifyApiKey',
                userAgentPackageName: 'com.example.app',
                maxZoom: 18,
              ),
              
              // MARKERS
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),
          
          // PAINEL DE INFORMAÇÕES
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildPainelInformacoes(),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];
    
    // MARKER DO PASSAGEIRO
    markers.add(
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
    );
    
    // MARKERS DOS MOTORISTAS PRÓXIMOS (apenas se não há motorista aceito)
    if (_statusCorrida == 'procurando') {
      for (var motorista in _motoristasProximos) {
        if (motorista['localizacao'] != null) {
          markers.add(
            Marker(
              point: LatLng(
                motorista['localizacao']['latitude'],
                motorista['localizacao']['longitude'],
              ),
              width: 50,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  shape: BoxShape.circle,
                  border: Border.all(color: VelloTokens.white, width: 2),
                ),
                child: const Icon(
                  Icons.local_taxi,
                  color: VelloTokens.white,
                  size: 25,
                ),
              ),
            ),
          );
        }
      }
    }
    
    // MARKER DO MOTORISTA ACEITO
    if (_statusCorrida == 'aceita' && _posicaoMotorista != null) {
      markers.add(
        Marker(
          point: _posicaoMotorista!,
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
      );
    }
    
    return markers;
  }

  Widget _buildPainelInformacoes() {
    return Container(
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
          // INDICADOR
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          if (_statusCorrida == 'procurando') ...[
            _buildPainelProcurando(),
          ] else if (_statusCorrida == 'aceita') ...[
            _buildPainelAceita(),
          ],
        ],
      ),
    );
  }

  Widget _buildPainelProcurando() {
    return Column(
      children: [
        const Icon(
          Icons.search,
          size: 48,
          color: VelloTokens.brandBlue,
        ),
        const SizedBox(height: 16),
        const Text(
          'Procurando motoristas próximos...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_motoristasProximos.length} motoristas encontrados',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20),
        
        // LISTA DE MOTORISTAS PRÓXIMOS
        if (_motoristasProximos.isNotEmpty) ...[
          const Text(
            'Motoristas próximos:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          ...(_motoristasProximos.take(3).map((motorista) => 
            _buildItemMotorista(motorista))),
        ],
        
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _cancelarCorrida,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancelar Corrida'),
          ),
        ),
      ],
    );
  }

  Widget _buildPainelAceita() {
    if (_dadosMotorista == null) {
      return const CircularProgressIndicator();
    }
    
    return Column(
      children: [
        Row(
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dadosMotorista!['nome'] ?? 'Motorista',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_dadosMotorista!['veiculo']?['modelo'] ?? ''} - ${_dadosMotorista!['veiculo']?['placa'] ?? ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Motorista a caminho...',
                    style: TextStyle(
                      fontSize: 16,
                      color: VelloTokens.brandBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
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
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _cancelarCorrida,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancelar Corrida'),
          ),
        ),
      ],
    );
  }

  Widget _buildItemMotorista(Map<String, dynamic> motorista) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_taxi, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  motorista['nome'] ?? 'Motorista',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${motorista['distancia'].toStringAsFixed(1)} km',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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

