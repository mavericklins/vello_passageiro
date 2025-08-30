import 'package:flutter/material.dart';
import 'package:vello/services/firebase_service.dart';
import '../theme/vello_tokens.dart';

class VelloPointsScreen extends StatefulWidget {
  const VelloPointsScreen({Key? key}) : super(key: key);

  @override
  _VelloPointsScreenState createState() => _VelloPointsScreenState();
}

class _VelloPointsScreenState extends State<VelloPointsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  int _velloPoints = 0;
  final TextEditingController _resgateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarVelloPoints();
  }

  Future<void> _carregarVelloPoints() async {
    final points = await _firebaseService.getVelloPoints();
    setState(() {
      _velloPoints = points;
    });
  }

  Future<void> _resgatarVelloPoints() async {
    final String valorResgateStr = _resgateController.text;
    final int? valorResgate = int.tryParse(valorResgateStr);

    if (valorResgate == null || valorResgate <= 0) {
      _mostrarSnackBar("Por favor, insira um valor válido para resgate.", Colors.red);
      return;
    }

    if (valorResgate > _velloPoints) {
      _mostrarSnackBar("Você não tem pontos suficientes para este resgate.", Colors.red);
      return;
    }

    if (valorResgate < 500) {
      _mostrarSnackBar("O resgate mínimo é de 500 Vello Points.", Colors.red);
      return;
    }

    try {
      await _firebaseService.subtrairVelloPoints(valorResgate);
      await _carregarVelloPoints(); // Recarrega o saldo após o resgate
      _resgateController.clear();
      _mostrarSnackBar("Você resgatou $valorResgate Vello Points com sucesso!", Colors.green);
    } catch (e) {
      _mostrarSnackBar("Erro ao resgatar Vello Points: $e", Colors.red);
    }
  }

  void _mostrarSnackBar(String mensagem, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "VelloPoints",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: VelloTokens.brandBlueAlt,
          ),
        ),
        backgroundColor: VelloTokens.white,
        foregroundColor: VelloTokens.brandBlueAlt,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: VelloTokens.gray200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: VelloTokens.brandBlueAlt,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de Saldo de Pontos
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [VelloTokens.brand, VelloTokens.brand.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: VelloTokens.brand.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Seu Saldo de Vello Points",
                    style: TextStyle(
                      fontSize: 16,
                      color: VelloTokens.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stars, size: 32, color: VelloTokens.white),
                      const SizedBox(width: 8),
                      Text(
                        _velloPoints.toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: VelloTokens.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "100 Vello Points = R\$1,00 de desconto",
                    style: TextStyle(
                      fontSize: 12,
                      color: VelloTokens.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Seção de Resgate de Pontos
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: VelloTokens.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: VelloTokens.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Resgatar Vello Points",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: VelloTokens.brandBlueAlt,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _resgateController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Quantidade de pontos para resgatar (mín. 500)",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: VelloTokens.brand, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      filled: true,
                      fillColor: VelloTokens.gray100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _resgatarVelloPoints,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VelloTokens.brand,
                      foregroundColor: VelloTokens.white,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: Size(double.infinity, 50), // Botão de largura total
                    ),
                    child: const Text(
                      "Resgatar Pontos",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Seção de Histórico de Pontos (Opcional, para futura implementação)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: VelloTokens.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: VelloTokens.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Histórico de Pontos",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: VelloTokens.brandBlueAlt,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Funcionalidade em desenvolvimento. Em breve você poderá ver seu histórico de pontos aqui!",
                    style: TextStyle(color: Colors.grey[600]),
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


