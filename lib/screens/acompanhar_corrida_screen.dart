import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/vello_tokens.dart';
import '../../core/error_handler.dart';
import '../../core/logger_service.dart';

class AcompanharCorridaScreen extends StatefulWidget {
  @override
  _AcompanharCorridaScreenState createState() => _AcompanharCorridaScreenState();
}

class _AcompanharCorridaScreenState extends State<AcompanharCorridaScreen> {
  String? corridaId;
  Map<String, dynamic>? corridaData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _buscarCorridaAtual();
  }

  Future<void> _buscarCorridaAtual() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      
      if (userId.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Buscar corrida mais recente do usuário
      final snapshot = await FirebaseFirestore.instance
          .collection('corridas')
          .where('passageiroId', isEqualTo: userId)
          .orderBy('criadaEm', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        setState(() {
          corridaId = doc.id;
          corridaData = doc.data();
          isLoading = false;
        });

        // Escutar mudanças na corrida
        _escutarMudancasCorrida(doc.id);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      LoggerService.info('Erro ao buscar corrida: $e', context: context ?? 'UNKNOWN');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _escutarMudancasCorrida(String id) {
    FirebaseFirestore.instance
        .collection('corridas')
        .doc(id)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        setState(() {
          corridaData = snapshot.data();
        });
      }
    });
  }

  Future<void> _ligarMotorista() async {
    final telefone = corridaData?['telefoneMotorista'];
    if (telefone != null && telefone.isNotEmpty) {
      final url = 'tel:$telefone';
      if (await canLaunch(url)) {
        await launch(url);
      }
    }
  }

  Future<void> _cancelarCorrida() async {
    if (corridaId == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancelar Corrida'),
        content: Text('Tem certeza que deseja cancelar esta corrida?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sim', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await FirebaseFirestore.instance
            .collection('corridas')
            .doc(corridaId)
            .update({
          'status': 'cancelada',
          'statusDetalhado': 'cancelada_passageiro',
          'canceladaEm': FieldValue.serverTimestamp(),
        });

        Navigator.of(context).pushReplacementNamed('/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cancelar corrida: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatusCard() {
    final status = corridaData?['statusDetalhado'] ?? 'pendente';
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusDescription;

    switch (status) {
      case 'pendente':
        statusColor = Colors.orange;
        statusIcon = Icons.search;
        statusText = 'Procurando Motorista';
        statusDescription = 'Aguarde, estamos procurando um motorista próximo...';
        break;
      case 'indo_buscar':
        statusColor = Colors.blue;
        statusIcon = Icons.directions_car;
        statusText = 'Motorista a Caminho';
        statusDescription = 'O motorista está indo até você';
        break;
      case 'aguardando_embarque':
        statusColor = Colors.green;
        statusIcon = Icons.location_on;
        statusText = 'Motorista Chegou!';
        statusDescription = 'Dirija-se ao veículo sem demora';
        break;
      case 'em_andamento':
        statusColor = Colors.purple;
        statusIcon = Icons.navigation;
        statusText = 'Corrida em Andamento';
        statusDescription = 'Você está a caminho do seu destino';
        break;
      case 'concluida':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Corrida Concluída';
        statusDescription = 'Obrigado por usar nossos serviços!';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusText = 'Status Desconhecido';
        statusDescription = 'Aguarde...';
    }

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 32),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        statusDescription,
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
          ],
        ),
      ),
    );
  }

  Widget _buildMotoristaCard() {
    final nomeMotorista = corridaData?['nomeMotorista'];
    final telefoneMotorista = corridaData?['telefoneMotorista'];
    final placaVeiculo = corridaData?['placaVeiculo'];
    final modeloVeiculo = corridaData?['modeloVeiculo'];
    final corVeiculo = corridaData?['corVeiculo'];

    if (nomeMotorista == null) {
      return SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seu Motorista',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: VelloTokens.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nomeMotorista,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (telefoneMotorista != null)
                        Text(
                          telefoneMotorista,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                if (telefoneMotorista != null)
                  IconButton(
                    onPressed: _ligarMotorista,
                    icon: Icon(Icons.phone, color: Colors.green),
                  ),
              ],
            ),
            if (modeloVeiculo != null || placaVeiculo != null) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.directions_car, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${corVeiculo ?? ''} ${modeloVeiculo ?? ''} - ${placaVeiculo ?? ''}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCorridaDetalhes() {
    final origem = corridaData?['origem'] ?? 'Origem';
    final destino = corridaData?['destino'] ?? 'Destino';
    final valor = corridaData?['valor'] ?? '0.00';
    final metodoPagamento = corridaData?['metodoPagamento'] ?? 'Dinheiro';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalhes da Corrida',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.my_location, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    origem,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    destino,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Valor: R\$ $valor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      metodoPagamento,
                      style: TextStyle(
                        fontSize: 12,
                        color: VelloTokens.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acompanhar Corrida'),
        backgroundColor: Colors.green,
        foregroundColor: VelloTokens.white,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text('Carregando corrida...'),
                ],
              ),
            )
          : corridaData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma corrida encontrada',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                        child: Text('Voltar ao Início'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildStatusCard(),
                      _buildMotoristaCard(),
                      _buildCorridaDetalhes(),
                      SizedBox(height: 20),
                      if (corridaData?['status'] == 'pendente') ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton(
                            onPressed: _cancelarCorrida,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: Size(double.infinity, 48),
                            ),
                            child: Text(
                              'Cancelar Corrida',
                              style: TextStyle(color: VelloTokens.white),
                            ),
                          ),
                        ),
                      ],
                      if (corridaData?['status'] == 'concluida') ...[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              minimumSize: Size(double.infinity, 48),
                            ),
                            child: Text(
                              'Voltar ao Início',
                              style: TextStyle(color: VelloTokens.white),
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}

