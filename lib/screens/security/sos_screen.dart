import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/emergency_service.dart';
import '../../services/advanced_security_service.dart';
import '../../theme/vello_tokens.dart';
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

class SOSScreen extends StatefulWidget {
  @override
  _SOSScreenState createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  bool _emergenciaAtiva = false;
  bool _isLoading = false;
  Position? _currentPosition;

  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
      
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {});
    } catch (e) {
      LoggerService.info('Erro ao obter localização: $e', context: context ?? 'UNKNOWN');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: Text(
          'SOS - Emergência',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: VelloTokens.white,
          ),
        ),
        backgroundColor: Colors.red,
        foregroundColor: VelloTokens.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: VelloTokens.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back,
              color: VelloTokens.white,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Cabeçalho de emergência
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.warning,
                    size: 80,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Central de Emergência',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: velloBlue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sua segurança é nossa prioridade. Em caso de emergência, toque no botão SOS.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Botão SOS principal
            GestureDetector(
              onTap: _emergenciaAtiva ? null : _ativarEmergencia,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: _emergenciaAtiva ? Colors.grey : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      spreadRadius: 8,
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: VelloTokens.white,
                          strokeWidth: 4,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SOS',
                              style: TextStyle(
                                color: VelloTokens.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'TOQUE AQUI',
                              style: TextStyle(
                                color: VelloTokens.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            SizedBox(height: 32),

            // Informações de localização
            if (_currentPosition != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: VelloTokens.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: VelloTokens.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: velloOrange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Sua Localização Atual',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: velloBlue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      'Long: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],

            // Ações rápidas de emergência
            _buildQuickActions(),

            SizedBox(height: 24),

            // Contatos de emergência
            _buildEmergencyContacts(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: VelloTokens.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: VelloTokens.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações de Emergência',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: velloBlue,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Polícia',
                    '190',
                    Icons.local_police,
                    Colors.blue,
                    () => _makeEmergencyCall('190'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'SAMU',
                    '192',
                    Icons.medical_services,
                    Colors.red,
                    () => _makeEmergencyCall('192'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Bombeiros',
                    '193',
                    Icons.fire_truck,
                    Colors.orange,
                    () => _makeEmergencyCall('193'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Compartilhar',
                    'Localização',
                    Icons.share_location,
                    velloOrange,
                    _shareLocation,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContacts() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: VelloTokens.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: VelloTokens.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contatos de Emergência',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: velloBlue,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/emergency-contacts'),
                  child: Text(
                    'Gerenciar',
                    style: TextStyle(color: velloOrange),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Configure seus contatos de emergência para que sejam notificados automaticamente quando o SOS for acionado.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _ativarEmergencia() async {
    setState(() {
      _emergenciaAtiva = true;
      _isLoading = true;
    });

    try {
      // Disparar alerta de emergência
      final alertId = await EmergencyService.triggerEmergencyAlert(
        type: EmergencyType.general,
        notes: 'SOS acionado pelo passageiro',
      );

      if (alertId != null) {
        // Ativar recursos avançados de segurança
        await AdvancedSecurityService().activateEmergency();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SOS acionado! Seus contatos foram notificados.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );

        // Mostrar opções adicionais
        _showEmergencyActionsDialog();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao acionar SOS: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _emergenciaAtiva = false;
      });
    }
  }

  void _showEmergencyActionsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('SOS Acionado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Emergência ativada com sucesso!'),
            SizedBox(height: 12),
            Text('• Contatos notificados'),
            Text('• Localização compartilhada'),
            Text('• Central de emergência acionada'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelarEmergencia();
            },
            child: Text('Cancelar SOS'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('OK', style: TextStyle(color: VelloTokens.white)),
          ),
        ],
      ),
    );
  }

  void _cancelarEmergencia() async {
    await AdvancedSecurityService().cancelEmergency();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Emergência cancelada.'),
        backgroundColor: velloOrange,
      ),
    );
  }

  void _makeEmergencyCall(String number) async {
    await EmergencyService.makeEmergencyCall(number);
  }

  void _shareLocation() async {
    if (_currentPosition != null) {
      await AdvancedSecurityService().shareLocation();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Localização compartilhada!'),
          backgroundColor: velloOrange,
        ),
      );
    }
  }
}