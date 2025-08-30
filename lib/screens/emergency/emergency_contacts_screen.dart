import 'package:flutter/material.dart';
import '../../services/emergency_service.dart';
import '../../theme/vello_tokens.dart';
import '../../utils/validators.dart';
import '../../constants/strings.dart';

class EmergencyContactsScreen extends StatefulWidget {
  @override
  _EmergencyContactsScreenState createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  
  List<EmergencyContact> _contacts = [];
  bool _isLoading = false;

  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    
    EmergencyService.getEmergencyContacts().listen((contacts) {
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: Text(
          AppStrings.tituloContatosEmergencia,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: velloBlue,
          ),
        ),
        backgroundColor: VelloTokens.white,
        elevation: 2,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: velloOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back,
              color: velloOrange,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: velloBlue),
            onPressed: _showAddContactDialog,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: velloOrange),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  SizedBox(height: 24),
                  _buildContactsList(),
                  SizedBox(height: 24),
                  _buildEmergencyNumbers(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        backgroundColor: velloOrange,
        child: Icon(Icons.add, color: VelloTokens.white),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: velloBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: velloBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: velloBlue, size: 24),
              SizedBox(width: 12),
              Text(
                'Importante!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: velloBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Configure seus contatos de emergência para que sejam notificados automaticamente em caso de acionamento do SOS.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• Máximo 5 contatos\n'
            '• 1 contato principal\n'
            '• Notificação via WhatsApp\n'
            '• Localização em tempo real',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seus Contatos (${_contacts.length}/5)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: velloBlue,
          ),
        ),
        SizedBox(height: 16),
        
        if (_contacts.isEmpty)
          _buildEmptyState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              return _buildContactCard(_contacts[index]);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(40),
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
      child: Column(
        children: [
          Icon(
            Icons.contacts_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Nenhum contato cadastrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Adicione contatos de confiança para emergências',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showAddContactDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: velloOrange,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Adicionar Primeiro Contato',
              style: TextStyle(color: VelloTokens.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: contact.isPrimary ? velloOrange : velloBlue,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      contact.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: VelloTokens.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (contact.isPrimary)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: VelloTokens.white, width: 2),
                        ),
                        child: Icon(
                          Icons.star,
                          size: 8,
                          color: VelloTokens.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        contact.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: velloBlue,
                        ),
                      ),
                      if (contact.isPrimary) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'PRINCIPAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    contact.formattedPhone,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    contact.relationship,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: velloBlue),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'call',
                  child: Row(
                    children: [
                      Icon(Icons.call, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Ligar'),
                    ],
                  ),
                ),
                if (!contact.isPrimary)
                  PopupMenuItem(
                    value: 'primary',
                    child: Row(
                      children: [
                        Icon(Icons.star, color: velloOrange),
                        SizedBox(width: 8),
                        Text('Tornar Principal'),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Remover'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) => _handleContactAction(contact, value.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyNumbers() {
    final emergencyNumbers = [
      {'name': 'Polícia', 'number': '190', 'icon': Icons.local_police, 'color': Colors.blue},
      {'name': 'SAMU', 'number': '192', 'icon': Icons.medical_services, 'color': Colors.red},
      {'name': 'Bombeiros', 'number': '193', 'icon': Icons.fire_truck, 'color': Colors.orange},
      {'name': 'PRF', 'number': '191', 'icon': Icons.security, 'color': Colors.green},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Números de Emergência',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: velloBlue,
          ),
        ),
        SizedBox(height: 16),
        Container(
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
          child: Column(
            children: emergencyNumbers.asMap().entries.map((entry) {
              final index = entry.key;
              final service = entry.value;
              final isLast = index == emergencyNumbers.length - 1;
              
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (service['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        service['icon'] as IconData,
                        color: service['color'] as Color,
                      ),
                    ),
                    title: Text(
                      service['name'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: velloBlue,
                      ),
                    ),
                    subtitle: Text(
                      'Toque para ligar',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: service['color'] as Color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        service['number'] as String,
                        style: TextStyle(
                          color: VelloTokens.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () => EmergencyService.makeEmergencyCall(service['number'] as String),
                  ),
                  if (!isLast) Divider(height: 1, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showAddContactDialog({EmergencyContact? contact}) {
    final isEditing = contact != null;
    
    if (isEditing) {
      _nameController.text = contact.name;
      _phoneController.text = contact.phone;
      _relationshipController.text = contact.relationship;
    } else {
      _nameController.clear();
      _phoneController.clear();
      _relationshipController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Editar Contato' : 'Novo Contato de Emergência',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: velloBlue,
                ),
              ),
              SizedBox(height: 20),
              
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person, color: velloBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: velloOrange),
                  ),
                ),
              ),
              SizedBox(height: 16),
              
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
                    borderSide: BorderSide(color: velloOrange),
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              TextField(
                controller: _relationshipController,
                decoration: InputDecoration(
                  labelText: 'Parentesco/Relação',
                  prefixIcon: Icon(Icons.family_restroom, color: velloBlue),
                  hintText: 'Ex: Mãe, Pai, Irmão, Amigo...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: velloOrange),
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Cancelar'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => isEditing ? _editContact(contact) : _addContact(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: velloOrange,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEditing ? 'Salvar Alterações' : 'Adicionar Contato',
                        style: TextStyle(color: VelloTokens.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addContact() async {
    if (!_validateForm()) return;

    final success = await EmergencyService.addEmergencyContact(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      relationship: _relationshipController.text.trim(),
      isPrimary: _contacts.isEmpty, // Primeiro contato é automaticamente principal
    );

    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contato adicionado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar contato'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editContact(EmergencyContact contact) async {
    if (!_validateForm()) return;

    final success = await EmergencyService.updateEmergencyContact(
      contactId: contact.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      relationship: _relationshipController.text.trim(),
      isPrimary: contact.isPrimary,
    );

    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contato atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar contato'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nome é obrigatório'), backgroundColor: Colors.red),
      );
      return false;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Telefone é obrigatório'), backgroundColor: Colors.red),
      );
      return false;
    }

    if (_relationshipController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parentesco é obrigatório'), backgroundColor: Colors.red),
      );
      return false;
    }

    return true;
  }

  void _handleContactAction(EmergencyContact contact, String action) async {
    switch (action) {
      case 'edit':
        _showAddContactDialog(contact: contact);
        break;
        
      case 'call':
        await EmergencyService.makeEmergencyCall(contact.phone);
        break;
        
      case 'primary':
        final success = await EmergencyService.updateEmergencyContact(
          contactId: contact.id,
          name: contact.name,
          phone: contact.phone,
          relationship: contact.relationship,
          isPrimary: true,
        );
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${contact.name} agora é o contato principal'),
              backgroundColor: Colors.green,
            ),
          );
        }
        break;
        
      case 'delete':
        _showDeleteConfirmation(contact);
        break;
    }
  }

  void _showDeleteConfirmation(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remover Contato'),
        content: Text('Deseja remover ${contact.name} dos seus contatos de emergência?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await EmergencyService.removeEmergencyContact(contact.id);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Contato removido'),
                    backgroundColor: velloOrange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remover', style: TextStyle(color: VelloTokens.white)),
          ),
        ],
      ),
    );
  }
}