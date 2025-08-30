import 'package:flutter/material.dart';

class CorridaValorCard extends StatelessWidget {
  final String valor;
  final String tempo;

  const CorridaValorCard({
    super.key,
    required this.valor,
    required this.tempo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text("Valor estimado: $valor"),
        subtitle: Text("Tempo: $tempo"),
        leading: const Icon(Icons.attach_money),
      ),
    );
  }
}
