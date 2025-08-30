import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';

class CarteiraDigitalScreen extends StatelessWidget {
  final String valorCorrida;

  const CarteiraDigitalScreen({Key? key, required this.valorCorrida}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento com Carteira Digital'),
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[700]),
            ),
            SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Icon(Icons.account_balance_wallet, size: 150, color: Colors.teal[300]),
                  SizedBox(height: 20),
                  Text(
                    'Selecione sua carteira digital preferida:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 20),
                  // Placeholder para botões de carteiras digitais (PayPal, PicPay, Mercado Pago)
                  ElevatedButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Processando pagamento com PayPal..."))
                      );
                      await Future.delayed(Duration(seconds: 2)); // Simula API call
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Pagamento com PayPal confirmado!"))
                      );
                      Navigator.pop(context, true); // Retorna para a tela anterior com sucesso
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[300], // Cor do ícone de carteira digital
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      "Pagar com PayPal",
                      style: TextStyle(fontSize: 16, color: VelloTokens.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Processando pagamento com PicPay..."))
                      );
                      await Future.delayed(Duration(seconds: 2)); // Simula API call
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Pagamento com PicPay confirmado!"))
                      );
                      Navigator.pop(context, true); // Retorna para a tela anterior com sucesso
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[300],
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Pagar com PicPay',
                      style: TextStyle(fontSize: 16, color: VelloTokens.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Processando pagamento com Mercado Pago..."))
                      );
                      await Future.delayed(Duration(seconds: 2)); // Simula API call
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Pagamento com Mercado Pago confirmado!"))
                      );
                      Navigator.pop(context, true); // Retorna para a tela anterior com sucesso
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[300],
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      "Pagar com Mercado Pago",
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

