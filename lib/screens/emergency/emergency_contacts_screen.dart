import 'package:flutter/material.dart';
import '../../services/emergency_service.dart';
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';

class EmergencyContactsScreen extends StatefulWidget {
  @override
  _EmergencyContactsScreenState createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;
  String? _error;

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

  void _loadContacts() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    EmergencyService.getEmergencyContacts().listen(
      (contacts) {
        if (mounted) {
          setState(() {
            _contacts = contacts;
            _isLoading = false;
            _error = null;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = 'Erro ao carregar contatos: $error';
          });
        }
        LoggerService.error('Erro ao carregar contatos de emergência: $error', context: 'EMERGENCY_CONTACTS');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          'Contatos de Emergência',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: velloBlue,
          ),
        ),
        backgroundColor: VelloTokens.white,
        foregroundColor: velloBlue,
        elevation: 2,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: velloOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: velloOrange,
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
                color: velloOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                color: velloOrange,
                size: 20,
              ),
            ),
            onPressed: () => _showAddContactDialog(),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(),
        backgroundColor: velloOrange,
        child: const Icon(
          Icons.add,
          color: VelloTokens.white,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: velloOrange),
            SizedBox(height: 16),
            Text(
              'Carregando contatos...',
              style: TextStyle(
                fontSize: 16,
                color: velloBlue,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadContacts,
              style: ElevatedButton.styleFrom(
                backgroundColor: velloOrange,
                foregroundColor: VelloTokens.white,
              ),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contacts,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum contato cadastrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: velloBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione contatos de emergência para\nmaior segurança nas suas viagens',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddContactDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Contato'),
              style: ElevatedButton.styleFrom(
                backgroundColor: velloOrange,
                foregroundColor: VelloTokens.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return _buildContactCard(contact);
      },
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: contact.isPrimary ? velloOrange.withOpacity(0.1) : velloBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.person,
                    color: contact.isPrimary ? velloOrange : velloBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              contact.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: velloBlue,
                              ),
                            ),
                          ),
                          if (contact.isPrimary) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: velloOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: velloOrange.withOpacity(0.3)),
                              ),
                              child: const Text(
                                'Principal',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: velloOrange,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
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
                PopupMenuButton<String>(
                  onSelected: (action) => _handleContactAction(contact, action),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'call',
                      child: Row(
                        children: [
                          Icon(Icons.phone, size: 18),
                          SizedBox(width: 8),
                          Text('Ligar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    if (!contact.isPrimary) ...[
                      const PopupMenuItem(
                        value: 'primary',
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 18),
                            SizedBox(width: 8),
                            Text('Tornar Principal'),
                          ],
                        ),
                      ),
                    ],
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isEditing ? Icons.edit : Icons.person_add,
              color: velloOrange,
            ),
            const SizedBox(width: 8),
            Text(
              isEditing ? 'Editar Contato' : 'Adicionar Contato',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: velloBlue,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome completo',
                  hintText: 'Ex: João Silva',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: velloOrange, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.person, color: velloBlue),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Telefone',
                  hintText: 'Ex: (11) 99999-9999',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: velloOrange, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.phone, color: velloBlue),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _relationshipController,
                decoration: InputDecoration(
                  labelText: 'Parentesco/Relação',
                  hintText: 'Ex: Mãe, Irmão, Amigo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: velloOrange, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.family_restroom, color: velloBlue),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => isEditing ? _editContact(contact) : _addContact(),
            style: ElevatedButton.styleFrom(
              backgroundColor: velloOrange,
              foregroundColor: VelloTokens.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isEditing ? 'Salvar Alterações' : 'Adicionar Contato',
              style: TextStyle(color: VelloTokens.white),
            ),
          ),
        ],
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