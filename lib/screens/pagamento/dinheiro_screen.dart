import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/matching_service.dart';
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

class DinheiroScreen extends StatefulWidget {
  final String valorCorrida;

  const DinheiroScreen({Key? key, required this.valorCorrida}) : super(key: key);

  @override
  State<DinheiroScreen> createState() => _DinheiroScreenState();
}

class _DinheiroScreenState extends State<DinheiroScreen> {
  bool _confirmado = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagamento em Dinheiro'),
        backgroundColor: Colors.green,
        foregroundColor: VelloTokens.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ícone e título
            Icon(
              Icons.money,
              size: 80,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'Pagamento em Dinheiro',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            // Card com valor
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Valor da Corrida',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'R\$ ${widget.valorCorrida}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Aviso
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Você pagará em dinheiro diretamente ao motorista no final da corrida.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Checkbox de confirmação
            CheckboxListTile(
              value: _confirmado,
              onChanged: (value) {
                setState(() {
                  _confirmado = value ?? false;
                });
              },
              title: Text(
                'Confirmo que tenho o valor exato em dinheiro',
                style: TextStyle(fontSize: 16),
              ),
              activeColor: Colors.green,
              controlAffinity: ListTileControlAffinity.leading,
            ),

            Spacer(),

            // Botão confirmar
            ElevatedButton(
              onPressed: _confirmado ? _confirmarPagamento : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: VelloTokens.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: Text(
                'Confirmar e Solicitar Corrida',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 16),

            // Botão voltar
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Escolher Outro Método',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarPagamento() async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      // BUSCAR DADOS DO SHAREDPREFERENCES (como no login_screen)
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final userName = prefs.getString('nomeUsuario') ?? 'Usuário';
      final userEmail = prefs.getString('userEmail') ?? '';
      final userPhone = prefs.getString('userTelefone') ?? '';
      final isLoggedIn = prefs.getBool('logado') ?? false;

      if (!isLoggedIn || userId == null) {
        Navigator.pop(context); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: Usuário não encontrado. Faça login novamente.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      LoggerService.success(' Usuário logado: $userId - $userName', context: context ?? 'UNKNOWN');

      // Obter localização atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Buscar endereços dos argumentos da rota
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      // Se não tem argumentos, usar dados padrão da localização atual
      final enderecoOrigem = args?['enderecoOrigem'] ?? 'Localização atual';
      final enderecoDestino = args?['enderecoDestino'] ?? 'Destino informado';
      final latOrigem = args?['latOrigem'] ?? position.latitude;
      final lngOrigem = args?['lngOrigem'] ?? position.longitude;
      final latDestino = args?['latDestino'] ?? position.latitude;
      final lngDestino = args?['lngDestino'] ?? position.longitude;

      LoggerService.info('📍 Origem: $enderecoOrigem ($latOrigem, $lngOrigem)', context: context ?? 'UNKNOWN');
      LoggerService.info('📍 Destino: $enderecoDestino ($latDestino, $lngDestino)', context: context ?? 'UNKNOWN');

      // Criar dados da corrida
      final corridaData = {
        'passageiroId': userId,
        'nomePassageiro': userName,
        'telefonePassageiro': userPhone,
        'emailPassageiro': userEmail,
        'origem': {
          'endereco': enderecoOrigem,
          'latitude': latOrigem,
          'longitude': lngOrigem,
        },
        'destino': {
          'endereco': enderecoDestino,
          'latitude': latDestino,
          'longitude': lngDestino,
        },
        'valor': double.tryParse(widget.valorCorrida.replaceAll(',', '.')) ?? 0.0,
        'metodoPagamento': 'dinheiro',
        'status': 'pendente',
        'statusDetalhado': 'procurando_motorista',
        'criadaEm': FieldValue.serverTimestamp(),
        'dataHoraSolicitacao': FieldValue.serverTimestamp(),
        'motoristaId': null,
        'nomeMotorista': null,
        'telefoneMotorista': null,
        'placaVeiculo': null,
        'modeloVeiculo': null,
        'corVeiculo': null,
      };

      // Salvar corrida no Firebase
      final corridaRef = await FirebaseFirestore.instance
          .collection('corridas')
          .add(corridaData);

      LoggerService.success(' Corrida criada: ${corridaRef.id}', context: context ?? 'UNKNOWN');

      // Iniciar matching service
      await MatchingService.notifyNearbyDrivers(corridaRef.id);

      Navigator.pop(context); // Fechar loading

      // Navegar para tela de acompanhamento
      Navigator.pushReplacementNamed(
        context,
        '/acompanhar_motorista',
        arguments: {'corridaId': corridaRef.id},
      );

    } catch (e) {
      Navigator.pop(context); // Fechar loading
      LoggerService.error(' Erro ao confirmar pagamento: $e', context: context ?? 'UNKNOWN');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao solicitar corrida: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}