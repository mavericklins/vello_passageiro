import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';

class VelloPointsScreen extends StatelessWidget {
  final String valorCorrida;

  const VelloPointsScreen({Key? key, required this.valorCorrida}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VelloPoints'),
        backgroundColor: VelloTokens.white,
        foregroundColor: VelloTokens.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stars, size: 100, color: Colors.amber[700]),
            SizedBox(height: 20),
            Text(
              'Você está na tela VelloPoints!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Valor da Corrida: ' + valorCorrida,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Volta para a tela anterior
              },
              child: Text('Voltar para Pagamentos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: VelloTokens.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


