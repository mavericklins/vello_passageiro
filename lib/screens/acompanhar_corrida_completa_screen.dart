import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/matching_service.dart';
import 'dart:async';
import '../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

class AcompanharCorridaCompletaScreen extends StatefulWidget {
  final String? corridaId;

  const AcompanharCorridaCompletaScreen({Key? key, this.corridaId}) : super(key: key);

  @override
  State<AcompanharCorridaCompletaScreen> createState() => _AcompanharCorridaCompletaScreenState();
}

class _AcompanharCorridaCompletaScreenState extends State<AcompanharCorridaCompletaScreen> {
  final MatchingService _matchingService = MatchingService();
  
  // Estados da corrida
  String _status = 'pendente';
  String _statusDetalhado = 'procurando_motorista';
  
  // Dados do motorista
  Map<String, dynamic>? _motoristaData;
  String _nomeMotorista = '';
  String _telefoneMotorista = '';
  String _placaVeiculo = '';
  String _modeloVeiculo = '';
  String _corVeiculo = '';
  
  // Dados da corrida
  String _origem = '';
  String _destino = '';
  String _valor = '';
  
  // Controle de tempo
  Timer? _tempoTimer;
  int _tempoDecorrido = 0;
  
  // Cores Vello
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloBlue = VelloTokens.brandBlueAlt;
  static const Color velloGreen = VelloTokens.success;

  @override
  void initState() {
    super.initState();
    _inicializarAcompanhamento();
  }

  @override
  void dispose() {
    _matchingService.dispose();
    _tempoTimer?.cancel();
    super.dispose();
  }

  void _inicializarAcompanhamento() {
    // Configurar callbacks do matching service
    _matchingService.onStatusUpdate = _onStatusUpdate;
    _matchingService.onError = _onError;
    
    // Buscar corrida ID dos argumentos se não foi passado
    String? corridaId = widget.corridaId;
    if (corridaId == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      corridaId = args?['corridaId'];
    }
    
    if (corridaId != null) {
      // Buscar dados iniciais da corrida
      _buscarDadosCorrida(corridaId);
      
      // Iniciar monitoramento
      _matchingService.startMonitoring(corridaId);
      
      // Iniciar timer de tempo decorrido
      _iniciarTimer();
    } else {
      _onError('ID da corrida não encontrado');
    }
  }

  void _iniciarTimer() {
    _tempoTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _tempoDecorrido++;
      });
    });
  }

  Future<void> _buscarDadosCorrida(String corridaId) async {
    try {
      final corridaDoc = await FirebaseFirestore.instance
          .collection('corridas')
          .doc(corridaId)
          .get();
      
      if (corridaDoc.exists) {
        final data = corridaDoc.data()!;
        setState(() {
          _origem = data['origem']['endereco'] ?? 'Origem';
          _destino = data['destino']['endereco'] ?? 'Destino';
          _valor = data['valor']?.toString() ?? '0.00';
          _status = data['status'] ?? 'pendente';
          _statusDetalhado = data['statusDetalhado'] ?? 'procurando_motorista';
        });
      }
    } catch (e) {
      LoggerService.info('Erro ao buscar dados da corrida: $e', context: context ?? 'UNKNOWN');
    }
  }

  void _onStatusUpdate(String status, Map<String, dynamic>? motoristaData) {
    setState(() {
      _status = status;
      _motoristaData = motoristaData;
      
      if (motoristaData != null) {
        _nomeMotorista = motoristaData['nome'] ?? 'Motorista';
        _telefoneMotorista = motoristaData['telefone'] ?? '';
        _placaVeiculo = motoristaData['placaVeiculo'] ?? 'ABC-1234';
        _modeloVeiculo = motoristaData['modeloVeiculo'] ?? 'Veículo';
        _corVeiculo = motoristaData['corVeiculo'] ?? 'Branco';
      }
      
      // Atualizar status detalhado baseado no status principal
      _statusDetalhado = _getStatusDetalhado(status);
    });
  }

  void _onError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getStatusDetalhado(String status) {
    switch (status) {
      case 'pendente':
        return 'procurando_motorista';
      case 'aceita':
        return 'motorista_a_caminho';
      case 'chegou_origem':
        return 'motorista_chegou';
      case 'em_andamento':
        return 'corrida_iniciada';
      case 'concluida':
        return 'corrida_finalizada';
      case 'cancelada':
        return 'corrida_cancelada';
      default:
        return 'status_desconhecido';
    }
  }

  String _getStatusText() {
    switch (_statusDetalhado) {
      case 'procurando_motorista':
        return 'Procurando motorista próximo...';
      case 'motorista_a_caminho':
        return 'Motorista a caminho do local de embarque';
      case 'motorista_chegou':
        return 'Motorista chegou! Dirija-se ao veículo';
      case 'corrida_iniciada':
        return 'Corrida em andamento';
      case 'corrida_finalizada':
        return 'Corrida finalizada com sucesso';
      case 'corrida_cancelada':
        return 'Corrida cancelada';
      default:
        return 'Acompanhando corrida...';
    }
  }

  Color _getStatusColor() {
    switch (_statusDetalhado) {
      case 'procurando_motorista':
        return Colors.orange;
      case 'motorista_a_caminho':
        return velloBlue;
      case 'motorista_chegou':
        return velloGreen;
      case 'corrida_iniciada':
        return velloOrange;
      case 'corrida_finalizada':
        return velloGreen;
      case 'corrida_cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (_statusDetalhado) {
      case 'procurando_motorista':
        return Icons.search;
      case 'motorista_a_caminho':
        return Icons.directions_car;
      case 'motorista_chegou':
        return Icons.location_on;
      case 'corrida_iniciada':
        return Icons.navigation;
      case 'corrida_finalizada':
        return Icons.check_circle;
      case 'corrida_cancelada':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _formatarTempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segs = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const VelloTokens.grayLight,
      appBar: AppBar(
        title: const Text('Acompanhar Corrida'),
        backgroundColor: velloBlue,
        foregroundColor: VelloTokens.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status principal da corrida
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: VelloTokens.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: VelloTokens.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Ícone animado do status
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      size: 40,
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Texto do status
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: velloBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Tempo decorrido
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: velloOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Tempo: ${_formatarTempo(_tempoDecorrido)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: velloOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Informações da corrida
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: VelloTokens.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: VelloTokens.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalhes da Corrida',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: velloBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Origem
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: velloGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Origem',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _origem,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Destino
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: velloOrange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Destino',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _destino,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Valor
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: velloGreen, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Valor: R\$ $_valor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: velloGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Informações do motorista (se disponível)
            if (_motoristaData != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: VelloTokens.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: VelloTokens.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seu Motorista',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: velloBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Nome do motorista
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: velloOrange.withOpacity(0.1),
                          child: Icon(Icons.person, color: velloOrange),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nomeMotorista,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_telefoneMotorista.isNotEmpty)
                                Text(
                                  _telefoneMotorista,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Informações do veículo
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.directions_car, color: velloBlue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$_corVeiculo $_modeloVeiculo',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Placa: $_placaVeiculo',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Botões de ação
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Simular ligação para motorista
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ligando para motorista...')),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Ligar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: velloGreen,
                        foregroundColor: VelloTokens.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Enviar mensagem
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enviando mensagem...')),
                        );
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('Mensagem'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: velloBlue,
                        foregroundColor: VelloTokens.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // Botão cancelar (apenas se corrida não iniciou)
            if (_status == 'pendente' || _status == 'aceita') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _mostrarDialogCancelamento(),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancelar Corrida'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: VelloTokens.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],

            // Botão finalizar (se corrida concluída)
            if (_status == 'concluida') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Voltar ao Início'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: velloGreen,
                    foregroundColor: VelloTokens.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _mostrarDialogCancelamento() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Corrida'),
        content: const Text('Tem certeza que deseja cancelar a corrida?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Cancelar corrida via matching service
              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
              final corridaId = widget.corridaId ?? args?['corridaId'];
              
              if (corridaId != null) {
                await _matchingService.cancelRide(corridaId, 'Cancelado pelo passageiro');
                
                // Voltar para home
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sim, Cancelar', style: TextStyle(color: VelloTokens.white)),
          ),
        ],
      ),
    );
  }
}

