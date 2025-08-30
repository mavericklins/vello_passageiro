import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

class AcompanharMotoristaScreen extends StatefulWidget {
  const AcompanharMotoristaScreen({Key? key}) : super(key: key);

  @override
  State<AcompanharMotoristaScreen> createState() => _AcompanharMotoristaScreenState();
}

class _AcompanharMotoristaScreenState extends State<AcompanharMotoristaScreen> {
  String _statusCorrida = 'Procurando motorista...';
  String _nomeMotorista = '';
  String _placaVeiculo = '';
  String _tempoEstimado = '';

  @override
  void initState() {
    super.initState();
    _monitorarCorrida();
  }

  void _monitorarCorrida() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Monitorar corridas do usuário
    FirebaseFirestore.instance
        .collection('corridas')
        .where('passageiroId', isEqualTo: user.uid)
        .where('status', whereIn: ['pendente', 'aceita', 'em_andamento'])
        .orderBy('criadaEm', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final corrida = snapshot.docs.first.data();
        setState(() {
          _statusCorrida = _getStatusText(corrida['status']);
          
          if (corrida['motoristaId'] != null) {
            _buscarDadosMotorista(corrida['motoristaId']);
          }
        });
      }
    });
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pendente':
        return 'Procurando motorista...';
      case 'aceita':
        return 'Motorista a caminho!';
      case 'em_andamento':
        return 'Corrida em andamento';
      default:
        return 'Status desconhecido';
    }
  }

  void _buscarDadosMotorista(String motoristaId) async {
    try {
      final motoristaDoc = await FirebaseFirestore.instance
          .collection('motoristas')
          .doc(motoristaId)
          .get();
      
      if (motoristaDoc.exists) {
        final dados = motoristaDoc.data()!;
        setState(() {
          _nomeMotorista = dados['nome'] ?? 'Motorista';
          _placaVeiculo = dados['placaVeiculo'] ?? 'ABC-1234';
          _tempoEstimado = '5-10 min';
        });
      }
    } catch (e) {
      LoggerService.info('Erro ao buscar dados do motorista: $e', context: context ?? 'UNKNOWN');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const VelloTokens.grayLight,
      appBar: AppBar(
        title: const Text('Acompanhar Corrida'),
        backgroundColor: const VelloTokens.brandBlue,
        foregroundColor: VelloTokens.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Status da corrida
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: VelloTokens.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: VelloTokens.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 64,
                    color: const VelloTokens.brandOrange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _statusCorrida,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: VelloTokens.brandBlue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Informações do motorista (se disponível)
            if (_nomeMotorista.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: VelloTokens.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: VelloTokens.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seu Motorista',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: VelloTokens.brandBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person, color: VelloTokens.brandOrange),
                        const SizedBox(width: 8),
                        Text(
                          _nomeMotorista,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.directions_car, color: VelloTokens.brandOrange),
                        const SizedBox(width: 8),
                        Text(
                          'Placa: $_placaVeiculo',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: VelloTokens.brandOrange),
                        const SizedBox(width: 8),
                        Text(
                          'Chegada em: $_tempoEstimado',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const Spacer(),

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
                      backgroundColor: Colors.green,
                      foregroundColor: VelloTokens.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Cancelar corrida
                      _mostrarDialogCancelamento();
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: VelloTokens.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
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
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sim, Cancelar', style: TextStyle(color: VelloTokens.white)),
          ),
        ],
      ),
    );
  }
}

