import 'package:flutter/material.dart';
import '../../services/emergency_service.dart';
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);
  
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _emergencyTriggered = false;
  
  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _emergencyTriggered ? Colors.red[50] : velloLightGray,
      appBar: AppBar(
        title: const Text(
          'Emergência',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _emergencyTriggered ? Colors.red : VelloTokens.white,
        elevation: 0,
        foregroundColor: _emergencyTriggered ? VelloTokens.white : velloBlue,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _emergencyTriggered 
                  ? VelloTokens.white.withOpacity(0.2) 
                  : velloOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back,
              color: _emergencyTriggered ? VelloTokens.white : velloOrange,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _emergencyTriggered 
                    ? VelloTokens.white.withOpacity(0.2) 
                    : velloBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.settings,
                color: _emergencyTriggered ? VelloTokens.white : velloBlue,
                size: 20,
              ),
            ),
            onPressed: _showEmergencySettings,
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: _emergencyTriggered ? _buildEmergencyActiveView() : _buildNormalView(),
    );
  }
  
  Widget _buildNormalView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botão de emergência principal
          _buildEmergencyButton(),
          
          const SizedBox(height: 24),
          
          // Números de emergência
          _buildEmergencyNumbers(),
          
          const SizedBox(height: 24),
          
          // Contatos de emergência
          _buildEmergencyContacts(),
          
          const SizedBox(height: 24),
          
          // Histórico de alertas
          _buildAlertHistory(),
        ],
      ),
    );
  }
  
  Widget _buildEmergencyActiveView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.warning,
                size: 80,
                color: VelloTokens.white,
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'EMERGÊNCIA ATIVADA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Seus contatos de emergência foram notificados.\nAjuda está a caminho.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: VelloTokens.black87,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _callPolice,
                    icon: const Icon(Icons.phone, color: VelloTokens.white),
                    label: const Text(
                      'Ligar 190',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: VelloTokens.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _cancelEmergency,
                    icon: const Icon(Icons.cancel, color: VelloTokens.white),
                    label: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: VelloTokens.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmergencyButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: VelloTokens.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: VelloTokens.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Botão de Emergência',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: velloBlue,
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Pressione e segure por 3 segundos para ativar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 24),
            
            GestureDetector(
              onLongPress: _triggerEmergency,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.warning,
                    size: 50,
                    color: VelloTokens.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'EMERGÊNCIA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmergencyNumbers() {
    return Container(
      decoration: BoxDecoration(
        color: VelloTokens.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: VelloTokens.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Números de Emergência',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: velloBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            ...EmergencyService.defaultEmergencyNumbers.entries.map(
              (entry) => _buildEmergencyNumberCard(entry.key, entry.value),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmergencyNumberCard(String name, String number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: velloLightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNumberColor(name).withOpacity(0.1),
          child: Icon(
            _getNumberIcon(name),
            color: _getNumberColor(name),
            size: 20,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: velloBlue,
          ),
        ),
        trailing: Text(
          number,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _getNumberColor(name),
          ),
        ),
        onTap: () => EmergencyService.makeEmergencyCall(number),
      ),
    );
  }
  
  Color _getNumberColor(String name) {
    switch (name) {
      case 'Polícia':
        return Colors.blue;
      case 'SAMU':
        return Colors.red;
      case 'Bombeiros':
        return Colors.orange;
      case 'Polícia Rodoviária':
        return Colors.green;
      default:
        return velloBlue;
    }
  }
  
  IconData _getNumberIcon(String name) {
    switch (name) {
      case 'Polícia':
        return Icons.local_police;
      case 'SAMU':
        return Icons.local_hospital;
      case 'Bombeiros':
        return Icons.local_fire_department;
      case 'Polícia Rodoviária':
        return Icons.traffic;
      default:
        return Icons.phone;
    }
  }
  
  Widget _buildEmergencyContacts() {
    return Container(
      decoration: BoxDecoration(
        color: VelloTokens.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: VelloTokens.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: velloOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.contact_phone,
                    color: velloOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Contatos de Emergência',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: velloBlue,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addEmergencyContact,
                  icon: const Icon(Icons.add, color: velloOrange),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            StreamBuilder<List<EmergencyContact>>(
              stream: EmergencyService.getEmergencyContacts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: velloOrange),
                  );
                }
                
                final contacts = snapshot.data ?? [];
                
                if (contacts.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: velloLightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_add_alt,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhum contato cadastrado',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _addEmergencyContact,
                          child: const Text('Adicionar contato'),
                        ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  children: contacts.map((contact) => _buildContactCard(contact)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactCard(EmergencyContact contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: velloLightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: contact.isPrimary ? velloOrange.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          child: Icon(
            contact.isPrimary ? Icons.star : Icons.person,
            color: contact.isPrimary ? velloOrange : Colors.grey,
            size: 20,
          ),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: velloBlue,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.formattedPhone,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              contact.relationship,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
          onSelected: (value) {
            switch (value) {
              case 'call':
                EmergencyService.makeEmergencyCall(contact.phone);
                break;
              case 'whatsapp':
                // Implementar compartilhamento via WhatsApp
                break;
              case 'edit':
                _editEmergencyContact(contact);
                break;
              case 'delete':
                _deleteEmergencyContact(contact);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'call',
              child: Row(
                children: [
                  Icon(Icons.phone, size: 16),
                  SizedBox(width: 8),
                  Text('Ligar'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'whatsapp',
              child: Row(
                children: [
                  Icon(Icons.chat, size: 16),
                  SizedBox(width: 8),
                  Text('WhatsApp'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAlertHistory() {
    return Container(
      decoration: BoxDecoration(
        color: VelloTokens.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: VelloTokens.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Histórico de Alertas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: velloBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            StreamBuilder<List<EmergencyAlert>>(
              stream: EmergencyService.getUserAlerts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: velloOrange),
                  );
                }
                
                final alerts = snapshot.data ?? [];
                
                if (alerts.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: velloLightGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Nenhum alerta registrado',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  );
                }
                
                return Column(
                  children: alerts.take(5).map((alert) => _buildAlertCard(alert)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAlertCard(EmergencyAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: velloLightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _getAlertStatusColor(alert.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getAlertIcon(alert.type),
              color: _getAlertStatusColor(alert.status),
              size: 16,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getAlertTypeLabel(alert.type),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: velloBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(alert.triggeredAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getAlertStatusColor(alert.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getAlertStatusLabel(alert.status),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getAlertStatusColor(alert.status),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getAlertStatusColor(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.active:
        return Colors.red;
      case EmergencyStatus.resolved:
        return Colors.green;
      case EmergencyStatus.cancelled:
        return Colors.grey;
    }
  }
  
  IconData _getAlertIcon(EmergencyType type) {
    switch (type) {
      case EmergencyType.general:
        return Icons.warning;
      case EmergencyType.medical:
        return Icons.local_hospital;
      case EmergencyType.safety:
        return Icons.security;
      case EmergencyType.accident:
        return Icons.car_crash;
      case EmergencyType.harassment:
        return Icons.report;
    }
  }
  
  String _getAlertTypeLabel(EmergencyType type) {
    switch (type) {
      case EmergencyType.general:
        return 'Emergência Geral';
      case EmergencyType.medical:
        return 'Emergência Médica';
      case EmergencyType.safety:
        return 'Segurança';
      case EmergencyType.accident:
        return 'Acidente';
      case EmergencyType.harassment:
        return 'Assédio';
    }
  }
  
  String _getAlertStatusLabel(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.active:
        return 'Ativo';
      case EmergencyStatus.resolved:
        return 'Resolvido';
      case EmergencyStatus.cancelled:
        return 'Cancelado';
    }
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora';
    }
  }
  
  Future<void> _triggerEmergency() async {
    setState(() {
      _emergencyTriggered = true;
    });
    
    try {
      await EmergencyService.triggerEmergencyAlert(
        type: EmergencyType.general,
        notes: 'Alerta de emergência ativado pelo usuário',
      );
      
      // Simular notificação
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alerta de emergência ativado! Contatos notificados.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      LoggerService.info('Erro ao ativar emergência: $e', context: context ?? 'UNKNOWN');
      setState(() {
        _emergencyTriggered = false;
      });
    }
  }
  
  Future<void> _cancelEmergency() async {
    setState(() {
      _emergencyTriggered = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alerta de emergência cancelado.'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Future<void> _callPolice() async {
    await EmergencyService.makeEmergencyCall('190');
  }
  
  void _showEmergencySettings() {
    // Implementar tela de configurações de emergência
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurações de Emergência'),
        content: const Text('Configurações em desenvolvimento...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _addEmergencyContact() {
    // Implementar dialog para adicionar contato
    showDialog(
      context: context,
      builder: (context) => _AddEmergencyContactDialog(),
    );
  }
  
  void _editEmergencyContact(EmergencyContact contact) {
    // Implementar dialog para editar contato
    showDialog(
      context: context,
      builder: (context) => _EditEmergencyContactDialog(contact: contact),
    );
  }
  
  void _deleteEmergencyContact(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Contato'),
        content: Text('Tem certeza que deseja excluir ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await EmergencyService.removeEmergencyContact(contact.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contato excluído com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir', style: TextStyle(color: VelloTokens.white)),
          ),
        ],
      ),
    );
  }
}

// Dialog para adicionar contato de emergência
class _AddEmergencyContactDialog extends StatefulWidget {
  @override
  State<_AddEmergencyContactDialog> createState() => _AddEmergencyContactDialogState();
}

class _AddEmergencyContactDialogState extends State<_AddEmergencyContactDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  bool _isPrimary = false;
  bool _isLoading = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }
  
  Future<void> _saveContact() async {
    if (_nameController.text.trim().isEmpty || 
        _phoneController.text.trim().isEmpty ||
        _relationshipController.text.trim().isEmpty) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await EmergencyService.addEmergencyContact(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        relationship: _relationshipController.text.trim(),
        isPrimary: _isPrimary,
      );
      
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contato adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar contato: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Contato de Emergência'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Telefone',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: _relationshipController,
            decoration: const InputDecoration(
              labelText: 'Parentesco/Relação',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          CheckboxListTile(
            title: const Text('Contato principal'),
            subtitle: const Text('Será o primeiro a ser notificado'),
            value: _isPrimary,
            onChanged: (value) {
              setState(() {
                _isPrimary = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveContact,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Adicionar'),
        ),
      ],
    );
  }
}

// Dialog para editar contato de emergência
class _EditEmergencyContactDialog extends StatefulWidget {
  final EmergencyContact contact;
  
  const _EditEmergencyContactDialog({required this.contact});
  
  @override
  State<_EditEmergencyContactDialog> createState() => _EditEmergencyContactDialogState();
}

class _EditEmergencyContactDialogState extends State<_EditEmergencyContactDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _relationshipController;
  late bool _isPrimary;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact.name);
    _phoneController = TextEditingController(text: widget.contact.phone);
    _relationshipController = TextEditingController(text: widget.contact.relationship);
    _isPrimary = widget.contact.isPrimary;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }
  
  Future<void> _updateContact() async {
    if (_nameController.text.trim().isEmpty || 
        _phoneController.text.trim().isEmpty ||
        _relationshipController.text.trim().isEmpty) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await EmergencyService.updateEmergencyContact(
        contactId: widget.contact.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        relationship: _relationshipController.text.trim(),
        isPrimary: _isPrimary,
      );
      
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contato atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar contato: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Contato de Emergência'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Telefone',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: _relationshipController,
            decoration: const InputDecoration(
              labelText: 'Parentesco/Relação',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          CheckboxListTile(
            title: const Text('Contato principal'),
            subtitle: const Text('Será o primeiro a ser notificado'),
            value: _isPrimary,
            onChanged: (value) {
              setState(() {
                _isPrimary = value ?? false;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateContact,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salvar'),
        ),
      ],
    );
  }
}