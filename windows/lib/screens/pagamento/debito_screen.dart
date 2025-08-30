import 'package:flutter/material.dart';

class DebitoScreen extends StatelessWidget {
  final String valorCorrida;

  const DebitoScreen({Key? key, required this.valorCorrida}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento com Cartão de Débito'),
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
            TextField(
              decoration: InputDecoration(
                labelText: 'Número do Cartão de Débito',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card, color: Colors.orange[300]),
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Validade (MM/AA)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: 'Nome do Titular',
                border: OutlineInputBorder(),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                // Simular processamento de pagamento com cartão de débito
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Processando pagamento com Cartão de Débito..."))
                );
                await Future.delayed(Duration(seconds: 2)); // Simula API call
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Pagamento com Cartão de Débito confirmado!"))
                );
                Navigator.pop(context, true); // Retorna para a tela anterior com sucesso
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[300], // Cor do ícone de cartão de débito
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Pagar com Cartão de Débito',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

