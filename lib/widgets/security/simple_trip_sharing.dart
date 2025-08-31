import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';
import '../../services/emergency_service.dart';

class SimpleTripSharing extends StatefulWidget {
  @override
  _SimpleTripSharingState createState() => _SimpleTripSharingState();
}

class _SimpleTripSharingState extends State<SimpleTripSharing> {
  bool _isActive = false;
  List<EmergencyContact> _emergencyContacts = [];
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
    _getCurrentLocation();
  }

  void _loadEmergencyContacts() {
    EmergencyService.getEmergencyContacts().listen(
      (contacts) {
        if (mounted) {
          setState(() {
            _emergencyContacts = contacts;
          });
        }
      },
      onError: (error) {
        LoggerService.error('Erro ao carregar contatos de emergência: $error', context: 'SimpleTripSharing');
      },
    );
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
      LoggerService.error('Erro ao obter localização: $e', context: 'SimpleTripSharing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleSharing,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: _isActive ? Colors.green : Colors.blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: VelloTokens.black.withOpacity(0.26),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          _isActive ? Icons.stop : Icons.shield,
          color: VelloTokens.white,
          size: 28,
        ),
      ),
    );
  }

  void _toggleSharing() {
    if (_isActive) {
      _stopSharing();
    } else {
      _startSharing();
    }
  }

  void _startSharing() {
    if (_emergencyContacts.isEmpty) {
      // Mostrar diálogo orientando a cadastrar contatos
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Nenhum Contato Cadastrado'),
            ],
          ),
          content: Text(
            'Você precisa cadastrar contatos de emergência para compartilhar sua viagem.\n\nDeseja cadastrar agora?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/emergency-contacts');
              },
              style: ElevatedButton.styleFrom(backgroundColor: VelloTokens.brandOrange),
              child: Text('Cadastrar Contatos', style: TextStyle(color: VelloTokens.white)),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🛡️ Compartilhar Viagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Compartilhe sua localização com seus contatos de emergência para maior segurança.'),
            SizedBox(height: 16),
            Text(
              'Serão notificados ${_emergencyContacts.length} contato${_emergencyContacts.length > 1 ? 's' : ''}:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ..._emergencyContacts.take(3).map((contact) => Text('• ${contact.name}')),
            if (_emergencyContacts.length > 3)
              Text('• ... e mais ${_emergencyContacts.length - 3} contato${_emergencyContacts.length - 3 > 1 ? 's' : ''}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _activateSharing();
            },
            child: Text('Ativar Compartilhamento'),
          ),
        ],
      ),
    );
  }

  void _activateSharing() async {
    setState(() {
      _isActive = true;
    });

    // Atualizar localização antes de enviar
    await _getCurrentLocation();

    // Enviar mensagem para todos os contatos cadastrados
    if (_currentPosition != null && _emergencyContacts.isNotEmpty) {
      for (EmergencyContact contact in _emergencyContacts) {
        await _sendLocationMessage(contact);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🛡️ Compartilhamento ativo! Contatos notificados.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _stopSharing() {
    setState(() {
      _isActive = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🛡️ Compartilhamento desativado.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _sendLocationMessage(EmergencyContact contact) async {
    if (_currentPosition == null) return;

    final lat = _currentPosition!.latitude;
    final lng = _currentPosition!.longitude;
    final mapsLink = 'https://maps.google.com/?q=$lat,$lng';
    
    final message = '''
🚗 Vello - Compartilhamento de Viagem

Olá, ${contact.name}! Estou usando o Vello e compartilhei minha viagem com você para maior segurança.

⏰ Iniciado às: ${DateTime.now().toString().substring(11, 16)}
📍 Minha localização: $mapsLink

🛡️ Recursos de Segurança:
• Localização em tempo real
• Dados do motorista
• Rota completa da viagem
• Contato direto com central

Vello - Mobilidade segura!
    ''';

    final phoneNumber = contact.phone.replaceAll(RegExp(r'[^\d]'), '');
    
    try {
      // Tentar enviar via WhatsApp
      await EmergencyService.shareLocationWhatsApp(phoneNumber, lat, lng);
    } catch (e) {
      LoggerService.error('Erro ao enviar mensagem para ${contact.name}: $e', context: 'SimpleTripSharing');
    }
  }
}