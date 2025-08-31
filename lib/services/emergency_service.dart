import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relationship;
  final bool isPrimary;
  final DateTime createdAt;
  
  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
    required this.isPrimary,
    required this.createdAt,
  });
  
  factory EmergencyContact.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmergencyContact(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      relationship: data['relationship'] ?? '',
      isPrimary: data['isPrimary'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'relationship': relationship,
      'isPrimary': isPrimary,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
  
  String get formattedPhone {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
    } else if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    }
    return phone;
  }
}

class EmergencyAlert {
  final String id;
  final String userId;
  final DateTime triggeredAt;
  final double? latitude;
  final double? longitude;
  final String? currentAddress;
  final String? rideId;
  final String? driverId;
  final EmergencyType type;
  final String? notes;
  final EmergencyStatus status;
  final DateTime? resolvedAt;
  
  EmergencyAlert({
    required this.id,
    required this.userId,
    required this.triggeredAt,
    this.latitude,
    this.longitude,
    this.currentAddress,
    this.rideId,
    this.driverId,
    required this.type,
    this.notes,
    required this.status,
    this.resolvedAt,
  });
  
  factory EmergencyAlert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmergencyAlert(
      id: doc.id,
      userId: data['userId'] ?? '',
      triggeredAt: (data['triggeredAt'] as Timestamp).toDate(),
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      currentAddress: data['currentAddress'],
      rideId: data['rideId'],
      driverId: data['driverId'],
      type: EmergencyType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => EmergencyType.general,
      ),
      notes: data['notes'],
      status: EmergencyStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => EmergencyStatus.active,
      ),
      resolvedAt: data['resolvedAt'] != null 
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'triggeredAt': Timestamp.fromDate(triggeredAt),
      'latitude': latitude,
      'longitude': longitude,
      'currentAddress': currentAddress,
      'rideId': rideId,
      'driverId': driverId,
      'type': type.name,
      'notes': notes,
      'status': status.name,
      'resolvedAt': resolvedAt != null 
          ? Timestamp.fromDate(resolvedAt!)
          : null,
    };
  }
}

enum EmergencyType { 
  general,    // Emergência geral
  medical,    // Emergência médica
  safety,     // Segurança pessoal
  accident,   // Acidente
  harassment  // Assédio
}

enum EmergencyStatus { 
  active,     // Alerta ativo
  resolved,   // Resolvido
  cancelled   // Cancelado
}

class EmergencyService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static String? get _userId => _auth.currentUser?.uid;
  
  // CORREÇÃO: Tratar null-safety adequadamente
  static CollectionReference? get _contactsCollection {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('usuarios').doc(uid).collection('contatos_emergencia');
  }
      
  static CollectionReference get _alertsCollection =>
      _firestore.collection('alertas_emergencia');
  
  // Números de emergência padrão
  static const Map<String, String> defaultEmergencyNumbers = {
    'Polícia': '190',
    'SAMU': '192',
    'Bombeiros': '193',
    'Polícia Rodoviária': '191',
  };
  
  // Adicionar contato de emergência
  static Future<bool> addEmergencyContact({
    required String name,
    required String phone,
    required String relationship,
    bool isPrimary = false,
  }) async {
    try {
      final collection = _contactsCollection;
      if (collection == null) {
        // CORREÇÃO: Usar string fixa ao invés de context inexistente
        LoggerService.warning('Usuário não autenticado para adicionar contato', context: 'EMERGENCY_SERVICE');
        return false;
      }

      // Se for contato primário, desmarcar outros
      if (isPrimary) {
        final existingPrimary = await collection
            .where('isPrimary', isEqualTo: true)
            .get();
            
        for (final doc in existingPrimary.docs) {
          await doc.reference.update({'isPrimary': false});
        }
      }
      
      final contact = EmergencyContact(
        id: '',
        name: name,
        phone: phone,
        relationship: relationship,
        isPrimary: isPrimary,
        createdAt: DateTime.now(),
      );
      
      await collection.add(contact.toFirestore());
      return true;
    } catch (e) {
      LoggerService.error('Erro ao adicionar contato: $e', context: 'EMERGENCY_SERVICE');
      return false;
    }
  }
  
  // Listar contatos de emergência
  static Stream<List<EmergencyContact>> getEmergencyContacts() {
    final collection = _contactsCollection;
    if (collection == null) {
      return Stream.value([]); // Retorna stream vazio se não autenticado
    }
    
    return collection
        .orderBy('isPrimary', descending: true)
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmergencyContact.fromFirestore(doc))
            .toList());
  }
  
  // Remover contato de emergência
  static Future<bool> removeEmergencyContact(String contactId) async {
    try {
      final collection = _contactsCollection;
      if (collection == null) return false;
      
      await collection.doc(contactId).delete();
      return true;
    } catch (e) {
      LoggerService.error('Erro ao remover contato: $e', context: 'EMERGENCY_SERVICE');
      return false;
    }
  }
  
  // Atualizar contato de emergência
  static Future<bool> updateEmergencyContact({
    required String contactId,
    required String name,
    required String phone,
    required String relationship,
    bool isPrimary = false,
  }) async {
    try {
      final collection = _contactsCollection;
      if (collection == null) return false;
      
      // Se for contato primário, desmarcar outros
      if (isPrimary) {
        final existingPrimary = await collection
            .where('isPrimary', isEqualTo: true)
            .get();
            
        for (final doc in existingPrimary.docs) {
          if (doc.id != contactId) {
            await doc.reference.update({'isPrimary': false});
          }
        }
      }
      
      await collection.doc(contactId).update({
        'name': name,
        'phone': phone,
        'relationship': relationship,
        'isPrimary': isPrimary,
      });
      
      return true;
    } catch (e) {
      LoggerService.error('Erro ao atualizar contato: $e', context: 'EMERGENCY_SERVICE');
      return false;
    }
  }
  
  // Disparar alerta de emergência
  static Future<String?> triggerEmergencyAlert({
    required EmergencyType type,
    String? notes,
    String? rideId,
    String? driverId,
  }) async {
    try {
      final uid = _userId;
      if (uid == null) {
        LoggerService.warning('Usuário não autenticado para disparar alerta', context: 'EMERGENCY_SERVICE');
        return null;
      }

      // Obter localização atual
      Position? position;
      String? currentAddress;
      
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        
        // Aqui poderia fazer reverse geocoding para obter endereço
        // Por simplicidade, vamos usar coordenadas
        currentAddress = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      } catch (e) {
        LoggerService.error('Erro ao obter localização: $e', context: 'EMERGENCY_SERVICE');
      }
      
      final alert = EmergencyAlert(
        id: '',
        userId: uid,
        triggeredAt: DateTime.now(),
        latitude: position?.latitude,
        longitude: position?.longitude,
        currentAddress: currentAddress,
        rideId: rideId,
        driverId: driverId,
        type: type,
        notes: notes,
        status: EmergencyStatus.active,
      );
      
      final docRef = await _alertsCollection.add(alert.toFirestore());
      
      // Notificar contatos de emergência
      await _notifyEmergencyContacts(docRef.id, alert);
      
      return docRef.id;
    } catch (e) {
      LoggerService.error('Erro ao disparar alerta: $e', context: 'EMERGENCY_SERVICE');
      return null;
    }
  }
  
  // Notificar contatos de emergência
  static Future<void> _notifyEmergencyContacts(String alertId, EmergencyAlert alert) async {
    try {
      final collection = _contactsCollection;
      if (collection == null) return;
      
      final contacts = await collection.get();
      
      for (final contactDoc in contacts.docs) {
        final contact = EmergencyContact.fromFirestore(contactDoc);
        
        // Aqui poderia integrar com serviço de SMS/WhatsApp
        // Por enquanto, apenas log
        LoggerService.info('Notificando ${contact.name} (${contact.phone}) sobre emergência', context: 'EMERGENCY_SERVICE');
        
        // Se tiver integração com SMS, seria algo como:
        // await SmsService.sendEmergencyAlert(contact.phone, alert);
      }
    } catch (e) {
      LoggerService.error('Erro ao notificar contatos: $e', context: 'EMERGENCY_SERVICE');
    }
  }
  
  // Resolver alerta de emergência
  static Future<bool> resolveEmergencyAlert(String alertId) async {
    try {
      await _alertsCollection.doc(alertId).update({
        'status': EmergencyStatus.resolved.name,
        'resolvedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      LoggerService.error('Erro ao resolver alerta: $e', context: 'EMERGENCY_SERVICE');
      return false;
    }
  }
  
  // Cancelar alerta de emergência
  static Future<bool> cancelEmergencyAlert(String alertId) async {
    try {
      await _alertsCollection.doc(alertId).update({
        'status': EmergencyStatus.cancelled.name,
        'resolvedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      LoggerService.error('Erro ao cancelar alerta: $e', context: 'EMERGENCY_SERVICE');
      return false;
    }
  }
  
  // Listar alertas do usuário
  static Stream<List<EmergencyAlert>> getUserAlerts() {
    final uid = _userId;
    if (uid == null) {
      return Stream.value([]); // Retorna stream vazio se não autenticado
    }
    
    return _alertsCollection
        .where('userId', isEqualTo: uid)
        .orderBy('triggeredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EmergencyAlert.fromFirestore(doc))
            .toList());
  }
  
  // Fazer ligação de emergência
  static Future<bool> makeEmergencyCall(String phoneNumber) async {
    try {
      final uri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      return false;
    } catch (e) {
      LoggerService.error('Erro ao fazer ligação: $e', context: 'EMERGENCY_SERVICE');
      return false;
    }
  }
  
  // Enviar localização via WhatsApp
  static Future<bool> shareLocationWhatsApp(String phoneNumber, double lat, double lng) async {
    try {
      final message = 'EMERGÊNCIA - Minha localização atual: https://maps.google.com/?q=$lat,$lng';
      final uri = Uri(
        scheme: 'https',
        host: 'wa.me',
        path: '/$phoneNumber',
        queryParameters: {'text': message},
      );
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      LoggerService.error('Erro ao compartilhar no WhatsApp: $e', context: 'EMERGENCY_SERVICE');
      return false;
    }
  }
}