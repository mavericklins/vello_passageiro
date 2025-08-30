import 'package:flutter/material.dart';
import 'package:vello/services/firebase_service.dart';
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

class TravelPreferencesScreen extends StatefulWidget {
  const TravelPreferencesScreen({Key? key}) : super(key: key);

  @override
  _TravelPreferencesScreenState createState() => _TravelPreferencesScreenState();
}

class _TravelPreferencesScreenState extends State<TravelPreferencesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, bool> _preferences = {
    'silence': false,
    'music': false,
    'air_conditioning': false,
  };

  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlueAlt;
  static const Color velloOrange = VelloTokens.brand;
  static const Color velloLightGray = VelloTokens.gray100;
  static const Color velloCardBackground = VelloTokens.white;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final loadedPreferences = await _firebaseService.getTravelPreferences();
    setState(() {
      _preferences = {
        'silence': loadedPreferences['silence'] ?? false,
        'music': loadedPreferences['music'] ?? false,
        'air_conditioning': loadedPreferences['air_conditioning'] ?? false,
      };
    });
  }

  Future<void> _savePreferences() async {
    try {
      await _firebaseService.saveTravelPreferences(_preferences);
      _showSnackBar("Preferências salvas com sucesso!", Colors.green);
    } catch (e) {
      LoggerService.info("Erro ao salvar preferências: $e", context: context ?? "UNKNOWN");
      _showSnackBar("Erro ao salvar preferências. Tente novamente.", Colors.red);
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
          "Preferências de Viagem",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                    "Selecione suas preferências para as próximas viagens:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: velloBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text(
                      "Viagem em Silêncio",
                      style: TextStyle(color: velloBlue),
                    ),
                    value: _preferences['silence']!,
                    onChanged: (bool value) {
                      setState(() {
                        _preferences['silence'] = value;
                      });
                    },
                    activeColor: velloOrange,
                  ),
                  SwitchListTile(
                    title: const Text(
                      "Música Ambiente",
                      style: TextStyle(color: velloBlue),
                    ),
                    value: _preferences['music']!,
                    onChanged: (bool value) {
                      setState(() {
                        _preferences['music'] = value;
                      });
                    },
                    activeColor: velloOrange,
                  ),
                  SwitchListTile(
                    title: const Text(
                      "Ar Condicionado",
                      style: TextStyle(color: velloBlue),
                    ),
                    value: _preferences['air_conditioning']!,
                    onChanged: (bool value) {
                      setState(() {
                        _preferences['air_conditioning'] = value;
                      });
                    },
                    activeColor: velloOrange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: velloOrange,
                foregroundColor: VelloTokens.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                "Salvar Preferências",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


