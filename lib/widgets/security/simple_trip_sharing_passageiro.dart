import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/vello_tokens.dart';
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

/// Widget para compartilhamento de viagem via WhatsApp - Versão Passageiro
class SimpleTripSharingPassageiroWidget extends StatefulWidget {
  final String tripId;
  final String? motoristaId;
  final String? motoristaNome;
  final String? motoristaVeiculo;
  final String? destino;
  final VoidCallback? onShared;

  const SimpleTripSharingPassageiroWidget({
    Key? key,
    required this.tripId,
    this.motoristaId,
    this.motoristaNome,
    this.motoristaVeiculo,
    this.destino,
    this.onShared,
  }) : super(key: key);

  @override
  _SimpleTripSharingPassageiroWidgetState createState() => _SimpleTripSharingPassageiroWidgetState();
}

class _SimpleTripSharingPassageiroWidgetState extends State<SimpleTripSharingPassageiroWidget> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final List<Map<String, String>> _contacts = [];
  bool _isLoading = false;

  // Cores da identidade Vello Passageiro
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: VelloTokens.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: velloBlue.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: velloBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.share_location, color: VelloTokens.white, size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Compartilhar Viagem',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: velloBlue,
                            ),
                          ),
                          Text(
                            'Mantenha seus familiares informados sobre sua viagem',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.motoristaNome != null || widget.destino != null) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.motoristaNome != null)
                          Row(
                            children: [
                              Icon(Icons.person, size: 14, color: Colors.green[700]),
                              SizedBox(width: 4),
                              Text(
                                'Motorista: ${widget.motoristaNome}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        if (widget.motoristaVeiculo != null) ...[
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.directions_car, size: 14, color: Colors.blue[700]),
                              SizedBox(width: 4),
                              Text(
                                'Veículo: ${widget.motoristaVeiculo}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ],
                        if (widget.destino != null) ...[
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: Colors.red[700]),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Destino: ${widget.destino}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Formulário para adicionar contatos
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome do contato',
                    prefixIcon: Icon(Icons.person, color: velloBlue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: velloBlue),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Telefone (com DDD)',
                    prefixIcon: Icon(Icons.phone, color: velloBlue),
                    hintText: '11999999999',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: velloBlue),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addContact,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: velloBlue,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Adicionar Contato', style: TextStyle(color: VelloTokens.white)),
                  ),
                ),
              ],
            ),
          ),

          // Lista de contatos adicionados
          if (_contacts.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Contatos Selecionados (${_contacts.length}/5)',
                  style: TextStyle(fontWeight: FontWeight.w600, color: velloBlue),
                ),
              ),
            ),
            SizedBox(height: 8),
          ],

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: velloBlue,
                      child: Text(
                        contact['name']!.substring(0, 1).toUpperCase(),
                        style: TextStyle(color: VelloTokens.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(contact['name']!),
                    subtitle: Text(contact['phone']!),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeContact(index),
                    ),
                  ),
                );
              },
            ),
          ),

          // Botões de ação
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Cancelar'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _contacts.isEmpty || _isLoading ? null : _shareTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: velloOrange,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(VelloTokens.white),
                            ),
                          )
                        : Text(
                            'Compartilhar (${_contacts.length})',
                            style: TextStyle(color: VelloTokens.white, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addContact() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      _showErrorDialog('Preencha nome e telefone');
      return;
    }

    if (_contacts.length >= 5) {
      _showErrorDialog('Máximo 5 contatos permitidos');
      return;
    }

    setState(() {
      _contacts.add({'name': name, 'phone': phone});
      _nameController.clear();
      _phoneController.clear();
    });
  }

  void _removeContact(int index) {
    setState(() {
      _contacts.removeAt(index);
    });
  }

  Future<void> _shareTrip() async {
    setState(() => _isLoading = true);

    try {
      final trackingLink = 'https://vellopassageiroseguro.app/track/${widget.tripId}';
      
      for (final contact in _contacts) {
        final message = _buildShareMessage(contact['name']!, trackingLink);
        await _sendWhatsAppMessage(contact['phone']!, message);
        await Future.delayed(Duration(milliseconds: 500)); // Evitar spam
      }

      Navigator.pop(context);
      widget.onShared?.call();
      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Erro ao compartilhar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _buildShareMessage(String contactName, String trackingLink) {
    final now = DateTime.now();
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    String message = '''
🚗 *Vello Passageiro - Compartilhamento de Viagem*

Olá $contactName! 
Estou fazendo uma viagem e compartilhei com você para sua tranquilidade.

⏰ *Iniciado às:* $time
''';

    if (widget.motoristaNome != null) {
      message += '👤 *Motorista:* ${widget.motoristaNome}\n';
    }
    
    if (widget.motoristaVeiculo != null) {
      message += '🚙 *Veículo:* ${widget.motoristaVeiculo}\n';
    }
    
    if (widget.destino != null) {
      message += '📍 *Destino:* ${widget.destino}\n';
    }

    message += '''

📍 *Acompanhe minha viagem:*
$trackingLink

🛡️ *Recursos de Segurança:*
• Localização em tempo real
• Dados do motorista e veículo
• Rota completa da viagem
• Contato direto com central
• Botão SOS integrado

_Mensagem automática do Vello Passageiro_
_"Viajando com segurança e transparência."_
    ''';

    return message;
  }

  Future<void> _sendWhatsAppMessage(String phone, String message) async {
    try {
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
      if (!cleanPhone.startsWith('55')) {
        cleanPhone = '55$cleanPhone';
      }

      final whatsappUrl = 'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}';
      
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      LoggerService.info('Erro ao enviar WhatsApp: $e', context: context ?? 'UNKNOWN');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Erro'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Sucesso!'),
          ],
        ),
        content: Text('Viagem compartilhada! Os contatos receberão mensagens no WhatsApp com informações de segurança e tracking em tempo real.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: velloOrange)),
          ),
        ],
      ),
    );
  }
}