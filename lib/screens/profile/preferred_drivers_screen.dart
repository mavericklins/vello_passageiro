import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_service.dart';
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

class PreferredDriversScreen extends StatefulWidget {
  const PreferredDriversScreen({Key? key}) : super(key: key);

  @override
  _PreferredDriversScreenState createState() => _PreferredDriversScreenState();
}

class _PreferredDriversScreenState extends State<PreferredDriversScreen> {
  final FirebaseService _firebaseService = FirebaseService.instance;
  final TextEditingController _driverIdController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();

  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlueAlt;
  static const Color velloOrange = VelloTokens.brand;
  static const Color velloLightGray = VelloTokens.gray100;
  static const Color velloCardBackground = VelloTokens.white;

  @override
  void dispose() {
    _driverIdController.dispose();
    _driverNameController.dispose();
    super.dispose();
  }

  Future<void> _addPreferredDriver() async {
    if (_driverIdController.text.isEmpty || _driverNameController.text.isEmpty) {
      _showSnackBar("Por favor, preencha o ID e o nome do motorista.", Colors.red);
      return;
    }

    try {
      await _firebaseService.addPreferredDriver(
        driverId: _driverIdController.text.trim(),
        name: _driverNameController.text.trim(),
      );
      _showSnackBar("Motorista preferido adicionado com sucesso!", Colors.green);
      _driverIdController.clear();
      _driverNameController.clear();
    } catch (e) {
      LoggerService.info("Erro ao adicionar motorista preferido: $e", context: 'preferred_drivers_screen');
      _showSnackBar("Erro ao adicionar motorista preferido. Tente novamente.", Colors.red);
    }
  }

  Future<void> _removePreferredDriver(String driverId) async {
    try {
      await _firebaseService.removePreferredDriver(driverId);
      _showSnackBar("Motorista preferido removido com sucesso!", Colors.green);
    } catch (e) {
      LoggerService.info("Erro ao remover motorista preferido: $e", context: 'preferred_drivers_screen');
      _showSnackBar("Erro ao remover motorista preferido. Tente novamente.", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          "Motoristas Preferidos",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: velloBlue,
          ),
        ),
        backgroundColor: velloCardBackground,
        foregroundColor: velloBlue,
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
              color: velloBlue,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: velloCardBackground,
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
                    "Adicionar Novo Motorista Preferido",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: velloBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _driverIdController,
                    decoration: InputDecoration(
                      hintText: "ID do Motorista",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: velloOrange, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      filled: true,
                      fillColor: velloLightGray,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _driverNameController,
                    decoration: InputDecoration(
                      hintText: "Nome do Motorista",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: velloOrange, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      filled: true,
                      fillColor: velloLightGray,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addPreferredDriver,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: velloOrange,
                      foregroundColor: VelloTokens.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Adicionar Motorista",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firebaseService.getPreferredDrivers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Erro: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Nenhum motorista preferido adicionado ainda."));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final driver = doc.data();
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.person, color: velloBlue),
                        title: Text(driver["name"] ?? driver["driverName"] ?? ""),
                        subtitle: Text("ID: ${driver["driverId"] ?? doc.id}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _removePreferredDriver(driver["driverId"] ?? doc.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}