import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({Key? key}) : super(key: key);

  @override
  _ReportIncidentScreenState createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedIncidentType;
  bool _isLoadingLocation = false;
  Position? _currentPosition;

  final List<String> _incidentTypes = [
    'Acidente',
    'Engarrafamento',
    'Obra na Pista',
    'Via Bloqueada',
    'Outro',
  ];

  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brand;
  static const Color velloLightGray = VelloTokens.gray100;
  static const Color velloCardBackground = VelloTokens.white;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      LoggerService.info("Erro ao obter localização: $e", context: "report_incident_screen");
      _showSnackBar("Não foi possível obter sua localização atual.", Colors.red);
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _reportIncident() async {
    if (_selectedIncidentType == null) {
      _showSnackBar("Por favor, selecione o tipo de incidente.", Colors.red);
      return;
    }
    if (_currentPosition == null) {
      _showSnackBar("Não foi possível obter sua localização. Tente novamente.", Colors.red);
      return;
    }

    setState(() {
      _isLoadingLocation = true; // Reutilizando para indicar envio
    });

    try {
      await FirebaseService.instance.reportIncident(
        type: _selectedIncidentType!,
        description: _descriptionController.text.trim(),
        lat: _currentPosition!.latitude,
        lng: _currentPosition!.longitude,
      );
      _showSnackBar("Incidente reportado com sucesso!", Colors.green);
      Navigator.pop(context); // Volta para a tela anterior
    } catch (e) {
      LoggerService.info("Erro ao reportar incidente: $e", context: "report_incident_screen");
      _showSnackBar("Erro ao reportar incidente. Tente novamente.", Colors.red);
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
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
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          "Reportar Incidente",
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
              color: Colors.grey.shade200,
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
                    "Tipo de Incidente",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: velloBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedIncidentType,
                    decoration: InputDecoration(
                      hintText: "Selecione o tipo de incidente",
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
                    items: _incidentTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedIncidentType = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Descrição (Opcional)",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: velloBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Detalhes adicionais sobre o incidente...",
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
                  Row(
                    children: [
                      Icon(Icons.location_on, color: velloBlue),
                      const SizedBox(width: 8),
                      _isLoadingLocation
                          ? const CircularProgressIndicator(strokeWidth: 2, color: velloOrange)
                          : Expanded(
                              child: Text(
                                _currentPosition != null
                                    ? 'Localização: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}'
                                    : 'Obtendo localização...', 
                                style: const TextStyle(color: velloBlue),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoadingLocation ? null : _reportIncident,
              style: ElevatedButton.styleFrom(
                backgroundColor: velloOrange,
                foregroundColor: VelloTokens.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoadingLocation
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: VelloTokens.white, strokeWidth: 2),
                    )
                  : const Text(
                      "Reportar Incidente",
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