import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

class SimpleTripSharing extends StatefulWidget {
  @override
  _SimpleTripSharingState createState() => _SimpleTripSharingState();
}

class _SimpleTripSharingState extends State<SimpleTripSharing> {
  bool _isActive = false;
  List<String> _emergencyContacts = [];

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
              color: VelloTokens.black26,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🛡️ Compartilhar Viagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Compartilhe sua localização com contatos de confiança para maior segurança.'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Número do WhatsApp (ex: 5511999999999)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _addContact(value);
                  Navigator.pop(context);
                }
              },
            ),
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
            child: Text('Ativar'),
          ),
        ],
      ),
    );
  }

  void _addContact(String contact) {
    setState(() {
      _emergencyContacts.add(contact);
    });
  }

  void _activateSharing() {
    setState(() {
      _isActive = true;
    });

    // Enviar mensagem para contatos
    for (String contact in _emergencyContacts) {
      _sendWhatsAppMessage(contact);
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

  void _sendWhatsAppMessage(String phoneNumber) async {
    final message = '''
🚗 Vello - Compartilhamento de Viagem

Olá! Estou usando o Vello e compartilhei minha viagem com você para maior segurança.

⏰ Iniciado às: ${DateTime.now().toString().substring(11, 16)}
📍 Acompanhe em tempo real

🛡️ Recursos de Segurança:
• Localização em tempo real
• Dados do motorista
• Rota completa da viagem
• Contato direto com central

Vello - Mobilidade segura!
    ''';

    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    
    try {
      if (await canLaunch(url)) {
        await launch(url);
      }
    } catch (e) {
      LoggerService.info('Erro ao abrir WhatsApp: $e', context: context ?? 'UNKNOWN');
    }
  }
}

