import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/trip_sharing.dart';
import '../../services/security/trip_sharing_service.dart';
import '../../theme/vello_tokens.dart';
import '../../theme/vello_tokens.dart';

/// Widget para compartilhamento de viagem com contatos
class TripSharingWidget extends StatefulWidget {
  final String tripId;
  final TripLocation startLocation;
  final TripLocation endLocation;
  final VoidCallback? onShared;
  final VoidCallback? onCancelled;

  const TripSharingWidget({
    Key? key,
    required this.tripId,
    required this.startLocation,
    required this.endLocation,
    this.onShared,
    this.onCancelled,
  }) : super(key: key);

  @override
  _TripSharingWidgetState createState() => _TripSharingWidgetState();
}

class _TripSharingWidgetState extends State<TripSharingWidget> {
  List<Contact> _contacts = [];
  List<SharedContact> _selectedContacts = [];
  bool _isLoading = false;
  bool _isLoadingContacts = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Cores da identidade Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = primaryColor; // Usando a cor do constants/colors.dart
  static const Color velloLightGray = VelloTokens.grayLight;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoadingContacts = true);
    
    try {
      if (await FlutterContacts.requestPermission()) {
        final contacts = await FlutterContacts.getContacts(withProperties: true);
        
        final contactsWithPhone = contacts.where((contact) => 
          contact.phones.isNotEmpty &&
          contact.displayName.isNotEmpty
        ).toList();

        contactsWithPhone.sort((a, b) => 
          a.displayName.compareTo(b.displayName));

        setState(() {
          _contacts = contactsWithPhone;
          _isLoadingContacts = false;
        });
      } else {
        setState(() => _isLoadingContacts = false);
        _showPermissionDialog();
      }
    } catch (e) {
      setState(() => _isLoadingContacts = false);
      _showErrorDialog('Erro ao carregar contatos: $e');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.contacts, color: velloOrange),
            SizedBox(width: 8),
            Text('Permissão Necessária'),
          ],
        ),
        content: Text(
          'Para compartilhar sua viagem, precisamos acessar seus contatos. '
          'Isso nos permite enviar notificações de segurança para pessoas de sua confiança.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: velloOrange),
            child: Text('Abrir Configurações', style: TextStyle(color: VelloTokens.white)),
          ),
        ],
      ),
    );
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

  List<Contact> get _filteredContacts {
    if (_searchQuery.isEmpty) return _contacts;
    
    return _contacts.where((contact) {
      final name = contact.displayName.toLowerCase();
      final phone = contact.phones.isNotEmpty ? contact.phones.first.number.toLowerCase() : '';
      return name.contains(_searchQuery) || phone.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
              color: velloOrange.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Indicador de arrastar
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
                        color: velloOrange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.security,
                        color: VelloTokens.white,
                        size: 20,
                      ),
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
                            'Selecione até 3 contatos para acompanhar sua viagem',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Contatos selecionados
          if (_selectedContacts.isNotEmpty) ...[
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: velloOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: velloOrange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, color: velloOrange, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Contatos Selecionados (${_selectedContacts.length}/3)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: velloBlue,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _selectedContacts.map((contact) => Chip(
                      label: Text(
                        contact.name,
                        style: TextStyle(fontSize: 12),
                      ),
                      deleteIcon: Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedContacts.remove(contact);
                        });
                      },
                      backgroundColor: VelloTokens.white,
                      side: BorderSide(color: velloOrange.withOpacity(0.5)),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],

          // Campo de busca
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar contatos...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: velloOrange),
                ),
                filled: true,
                fillColor: velloLightGray,
              ),
            ),
          ),

          SizedBox(height: 16),

          // Lista de contatos
          Expanded(
            child: _isLoadingContacts
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: velloOrange),
                        SizedBox(height: 16),
                        Text(
                          'Carregando contatos...',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : _filteredContacts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.contacts_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty 
                                  ? 'Nenhum contato encontrado'
                                  : 'Nenhum contato encontrado para "$_searchQuery"',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              SizedBox(height: 8),
                              TextButton(
                                onPressed: _loadContacts,
                                child: Text('Tentar novamente'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = _filteredContacts[index];
                          final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
                          final isSelected = _selectedContacts.any((c) => c.phone == phone);
                          
                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            elevation: 0,
                            color: isSelected ? velloOrange.withOpacity(0.1) : VelloTokens.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? velloOrange : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isSelected 
                                    ? velloOrange 
                                    : velloOrange.withOpacity(0.2),
                                child: Text(
                                  contact.displayName.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    color: isSelected ? VelloTokens.white : velloOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                contact.displayName,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                phone,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: isSelected 
                                  ? Icon(Icons.check_circle, color: velloOrange)
                                  : Icon(Icons.radio_button_unchecked, color: Colors.grey),
                              onTap: () => _toggleContact(contact),
                            ),
                          );
                        },
                      ),
          ),

          // Botões de ação
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: VelloTokens.white,
              boxShadow: [
                BoxShadow(
                  color: VelloTokens.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onCancelled?.call();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _selectedContacts.isEmpty || _isLoading 
                        ? null 
                        : _shareTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: velloOrange,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.share, color: VelloTokens.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Compartilhar (${_selectedContacts.length})',
                                style: TextStyle(
                                  color: VelloTokens.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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

  void _toggleContact(Contact contact) {
    final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
    final isSelected = _selectedContacts.any((c) => c.phone == phone);
    
    setState(() {
      if (isSelected) {
        _selectedContacts.removeWhere((c) => c.phone == phone);
      } else {
        if (_selectedContacts.length < 3) {
          _selectedContacts.add(SharedContact(
            name: contact.displayName,
            phone: phone,
            relationship: 'Contato',
          ));
        } else {
          _showMaxContactsDialog();
        }
      }
    });
  }

  void _showMaxContactsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: velloOrange),
            SizedBox(width: 8),
            Text('Limite Atingido'),
          ],
        ),
        content: Text(
          'Você pode selecionar no máximo 3 contatos para compartilhar sua viagem.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: velloOrange)),
          ),
        ],
      ),
    );
  }

  Future<void> _shareTrip() async {
    setState(() => _isLoading = true);
    
    try {
      // Criar informações fictícias do motorista (serão atualizadas quando motorista aceitar)
      final driverInfo = DriverInfo(
        name: 'Aguardando motorista...',
        photo: '',
        vehicle: VehicleInfo(
          model: 'Aguardando...',
          plate: '---',
          color: 'Aguardando',
        ),
        rating: 5.0,
      );

      final trackingLink = await TripSharingService.shareTrip(
        tripId: widget.tripId,
        contacts: _selectedContacts,
        startLocation: widget.startLocation,
        endLocation: widget.endLocation,
        driverInfo: driverInfo,
      );
      
      Navigator.pop(context);
      widget.onShared?.call();
      
      _showSuccessDialog(trackingLink);
    } catch (e) {
      _showErrorDialog('Erro ao compartilhar viagem: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String trackingLink) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Viagem Compartilhada!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sua viagem foi compartilhada com sucesso!'),
            SizedBox(height: 12),
            Text(
              'Os contatos selecionados receberam uma mensagem no WhatsApp com o link de acompanhamento.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: velloLightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                trackingLink,
                style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
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

