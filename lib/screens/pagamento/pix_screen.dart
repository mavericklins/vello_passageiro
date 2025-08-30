import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:vello/controllers/auth_provider.dart';
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

class PixScreen extends StatelessWidget {
  final String valorCorrida;

  const PixScreen({Key? key, required this.valorCorrida}) : super(key: key);

  Future<void> solicitarCorrida(BuildContext context) async {
    try {
      LoggerService.info('👉 solicitando corrida...', context: context ?? 'UNKNOWN');

      final uid = Provider.of<AuthProvider>(context, listen: false).usuario?.uid ??
          Provider.of<AuthProvider>(context, listen: false).dadosUsuario?['uid'];

      if (uid == null) {
        LoggerService.error(' Usuário não logado', context: context ?? 'UNKNOWN');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário não logado')),
        );
        return;
      }

      LoggerService.success(' UID: $uid', context: context ?? 'UNKNOWN');

      final doc = await FirebaseFirestore.instance.collection('passageiros').doc(uid).get();

      if (!doc.exists) {
        LoggerService.error(' Passageiro não encontrado', context: context ?? 'UNKNOWN');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passageiro não encontrado')),
        );
        return;
      }

      final dados = doc.data()!;
      LoggerService.info('📦 Dados do passageiro: $dados', context: context ?? 'UNKNOWN');

      await FirebaseFirestore.instance.collection('corridas').add({
        'id_passageiro': uid,
        'nome_passageiro': dados['nome'] ?? '',
        'foto_passageiro': dados['foto_url'] ?? '',
        'origem': 'Rua Dom Pedro II, Lins - SP',
        'destino': 'Avenida Brasil, Lins - SP',
        'valor': double.tryParse(
          valorCorrida.replaceAll('R\$ ', '').replaceAll(',', '.'),
        ) ??
            0.0,
        'forma_pagamento': 'pix',
        'status': 'pendente',
        'timestamp': FieldValue.serverTimestamp(),
      });

      LoggerService.success(' Corrida criada com sucesso!', context: context ?? 'UNKNOWN');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Corrida solicitada com sucesso')),
      );
      Navigator.pop(context);
    } catch (e) {
      LoggerService.error(' Erro ao solicitar corrida: $e', context: context ?? 'UNKNOWN');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao solicitar corrida')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento com Pix'),
        backgroundColor: VelloTokens.white,
        foregroundColor: VelloTokens.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Valor Total:',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            Text(
              valorCorrida,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Icon(Icons.qr_code_2, size: 150, color: Colors.purple[300]),
                  const SizedBox(height: 20),
                  const Text(
                    'Escaneie o QR Code para pagar com Pix',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ou copie e cole a chave Pix abaixo:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'CHAVE_PIX_AQUI_EXEMPLO',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Processando pagamento Pix...")),
                      );
                      await Future.delayed(const Duration(seconds: 1));
                      await solicitarCorrida(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[300],
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Confirmar Pagamento Pix',
                      style: TextStyle(fontSize: 16, color: VelloTokens.white),
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
}