import 'package:flutter/material.dart';

class PixScreen extends StatelessWidget {
  final String valorCorrida;

  const PixScreen({Key? key, required this.valorCorrida}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento com Pix'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[700]),
            ),
            SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Icon(Icons.qr_code_2, size: 150, color: Colors.purple[300]),
                  SizedBox(height: 20),
                  Text(
                    'Escaneie o QR Code para pagar com Pix',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ou copie e cole a chave Pix abaixo:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'CHAVE_PIX_AQUI_EXEMPLO',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Simular processamento de pagamento Pix
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Processando pagamento Pix..."))
                      );
                      await Future.delayed(Duration(seconds: 2)); // Simula API call
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Pagamento Pix confirmado!"))
                      );
                      Navigator.pop(context, true); // Retorna para a tela anterior com sucesso
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[300], // Cor do ícone Pix
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Confirmar Pagamento Pix',
                      style: TextStyle(fontSize: 16, color: Colors.white),
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

