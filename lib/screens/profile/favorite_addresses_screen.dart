import 'package:flutter/material.dart';
import 'package:vello/services/firebase_service.dart';
import 'package:vello/services/geoapify_service.dart';
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

class FavoriteAddressesScreen extends StatefulWidget {
  const FavoriteAddressesScreen({Key? key}) : super(key: key);

  @override
  _FavoriteAddressesScreenState createState() => _FavoriteAddressesScreenState();
}

class _FavoriteAddressesScreenState extends State<FavoriteAddressesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final GeoapifyService _geoapifyService = GeoapifyService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlueAlt;
  static const Color velloOrange = VelloTokens.brand;
  static const Color velloLightGray = VelloTokens.gray100;
  static const Color velloCardBackground = VelloTokens.white;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _addFavoriteAddress() async {
    if (_nameController.text.isEmpty || _addressController.text.isEmpty) {
      _showSnackBar("Por favor, preencha o nome e o endereço.", Colors.red);
      return;
    }

    final addressCoords = await _geoapifyService.getCoordinates(_addressController.text);

    if (addressCoords == null) {
      _showSnackBar("Não foi possível encontrar as coordenadas para o endereço informado.", Colors.red);
      return;
    }

    try {
      await _firebaseService.addFavoriteAddress(
        _nameController.text.trim(),
        _addressController.text.trim(),
        addressCoords["lat"]!,
        addressCoords["lon"]!,
      );
      _showSnackBar("Endereço favorito adicionado com sucesso!", Colors.green);
      _nameController.clear();
      _addressController.clear();
    } catch (e) {
      LoggerService.info("Erro ao adicionar endereço favorito: $e", context: context ?? "UNKNOWN");
      _showSnackBar("Erro ao adicionar endereço favorito. Tente novamente.", Colors.red);
    }
  }

  Future<void> _deleteFavoriteAddress(String addressId) async {
    try {
      await _firebaseService.deleteFavoriteAddress(addressId);
      _showSnackBar("Endereço favorito removido com sucesso!", Colors.green);
    } catch (e) {
      LoggerService.info("Erro ao remover endereço favorito: $e", context: context ?? "UNKNOWN");
      _showSnackBar("Erro ao remover endereço favorito. Tente novamente.", Colors.red);
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
          "Endereços Favoritos",
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
              color: const VelloTokens.gray200,
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
                    "Adicionar Novo Endereço Favorito",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: velloBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Nome (ex: Casa, Trabalho)",
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
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: "Endereço completo",
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
                    onPressed: _addFavoriteAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: velloOrange,
                      foregroundColor: VelloTokens.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Adicionar Endereço",
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
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firebaseService.getFavoriteAddresses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Erro: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nenhum endereço favorito adicionado ainda."));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final address = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.location_on, color: velloBlue),
                        title: Text(address["name"]),
                        subtitle: Text(address["address"]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteFavoriteAddress(address["id"]),
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


