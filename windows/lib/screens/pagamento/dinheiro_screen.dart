import 'package:flutter/material.dart';
import 'package:vello/screens/map/map_screen.dart';

class DinheiroScreen extends StatelessWidget {
  final String valorCorrida;

  const DinheiroScreen({Key? key, required this.valorCorrida}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento em Dinheiro'),
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
                  Icon(Icons.money, size: 150, color: Colors.green[300]),
                  SizedBox(height: 20),
                  Text(
                    'Pague o valor exato ao motorista.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'O motorista pode não ter troco para valores altos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Atenção!"),
                      content: const Text(
                        "Por favor, faça o pagamento diretamente ao motorista. Tenha o valor exato ou troco para facilitar."
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Entendi"),
                          onPressed: () {
                            Navigator.of(context).pop(); // Fecha o diálogo
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Pagamento em Dinheiro confirmado!"))
                            );
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen(valorCorrida: valorCorrida)));
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[300], // Cor do ícone de dinheiro
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Confirmar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


