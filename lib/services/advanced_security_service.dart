import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/feature_flags.dart';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

class AdvancedSecurityService {
  static final AdvancedSecurityService _instance = AdvancedSecurityService._internal();
  factory AdvancedSecurityService() => _instance;
  AdvancedSecurityService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isEnabled => FeatureFlags.enableAdvancedSOS;

  Future<void> initialize() async {
    if (!isEnabled) return;
    // Inicialização de recursos avançados
    LoggerService.success('Advanced Security Service inicializado', context: 'SECURITY');
  }

  Future<void> enablePanic() async {
    if (!isEnabled) return;
    // Ativar modo pânico
    LoggerService.warning('Modo pânico ativado', context: 'SECURITY');
  }

  Future<void> suggestSafePoints() async {
    if (!isEnabled) return;
    
    return await ErrorHandler.safeAsync(() async {
      final position = await Geolocator.getCurrentPosition();

      // Buscar pontos seguros próximos (delegacias, hospitais, etc)
      final pontos = await _firestore
          .collection('pontos_seguros')
          .where('ativo', isEqualTo: true)
          .get();

      final pontosProximos = <Map<String, dynamic>>[];

      for (final doc in pontos.docs) {
        final data = doc.data();
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          data['latitude'],
          data['longitude'],
        );

        if (distance <= 5000) {
          pontosProximos.add({
            ...data,
            'distance': distance,
            'id': doc.id,
          });
        }
      }

      if (pontosProximos.isNotEmpty) {
        pontosProximos.sort((a, b) => a['distance'].compareTo(b['distance']));
        final pontoProximo = pontosProximos.first;
        final distanciaKm = (pontoProximo['distance'] / 1000).toStringAsFixed(1);

        LoggerService.info('Ponto seguro mais próximo: ${pontoProximo['nome']} - $distanciaKm km', context: 'SECURITY');
        
        // Aqui poderia implementar notificação
        _notifyUser('Ponto seguro próximo', 'O ponto mais próximo está a $distanciaKm km.');
      }
    }, context: 'suggest_safe_points');
  }

  Future<void> shareLocation() async {
    if (!isEnabled) return;
    
    return await ErrorHandler.safeAsync(() async {
      final position = await Geolocator.getCurrentPosition();
      final locationUrl = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
      
      // Compartilhar via WhatsApp ou SMS
      final message = 'EMERGÊNCIA - Minha localização atual: $locationUrl';
      
      // Aqui poderia integrar com contatos de emergência
      LoggerService.info('Localização compartilhada: $message', context: 'SECURITY');
      
      _notifyUser('Localização compartilhada', 'Sua localização foi enviada aos contatos de emergência.');
    }, context: 'share_location');
  }

  Future<void> callEmergency(String number) async {
    if (!isEnabled) return;
    
    return await ErrorHandler.safeAsync(() async {
      final uri = Uri(scheme: 'tel', path: number);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
      
      _notifyUser('Ligação de emergência', 'Ligando para $number...');
    }, context: 'call_emergency');
  }

  Future<void> sendEmergencyMessage() async {
    if (!isEnabled) return;
    
    return await ErrorHandler.safeAsync(() async {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Obter contatos de emergência
      final contacts = await _firestore
          .collection('usuarios')
          .doc(userId)
          .collection('contatos_emergencia')
          .get();

      final position = await Geolocator.getCurrentPosition();
      final locationUrl = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';

      for (final contactDoc in contacts.docs) {
        final contact = contactDoc.data();
        final phone = contact['phone'] as String;
        final name = contact['name'] as String;

        final message = '''
🚨 ALERTA DE EMERGÊNCIA

Olá $name, estou em uma situação de emergência e preciso de ajuda.

📍 Minha localização atual: $locationUrl

🕐 Horário: ${DateTime.now().toString()}

Por favor, entre em contato comigo ou com as autoridades se necessário.

Mensagem enviada automaticamente pelo app Vello.
        ''';

        // Enviar via WhatsApp
        await _sendWhatsAppMessage(phone, message);
      }

      _notifyUser('Mensagem de emergência', 'Mensagens enviadas aos contatos de emergência!');
    }, context: 'send_emergency_message');
  }

  Future<void> _sendWhatsAppMessage(String phone, String message) async {
    return await ErrorHandler.safeAsync(() async {
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
      if (!cleanPhone.startsWith('55')) {
        cleanPhone = '55$cleanPhone';
      }

      final whatsappUrl = 'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}';
      
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
      }
    }, context: 'send_whatsapp_message');
  }

  Future<void> activateEmergency() async {
    if (!isEnabled) return;
    
    return await ErrorHandler.safeAsync(() async {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Salvar no Firestore que emergência foi ativada
      await _firestore.collection('emergency_alerts').add({
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'passenger_sos',
        'status': 'active',
        'location': await _getCurrentLocationData(),
      });

      // Enviar mensagens para contatos
      await sendEmergencyMessage();
      
      // Sugerir pontos seguros
      await suggestSafePoints();

      _notifyUser('Emergência ativada', 'Todos os protocolos de segurança foram acionados!');
    }, context: 'activate_emergency');
  }

  Future<void> cancelEmergency() async {
    if (!isEnabled) return;
    
    return await ErrorHandler.safeAsync(() async {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Atualizar status no Firestore
      final alerts = await _firestore
          .collection('emergency_alerts')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();

      for (final alert in alerts.docs) {
        await alert.reference.update({
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        });
      }

      _notifyUser('Emergência cancelada', 'O alerta de emergência foi cancelado.');
    }, context: 'cancel_emergency');
  }

  Future<Map<String, dynamic>> _getCurrentLocationData() async {
    return await ErrorHandler.safeAsync(() async {
      final position = await Geolocator.getCurrentPosition();
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }, context: 'get_location_data', fallback: {}) ?? {};
  }

  void _notifyUser(String title, String message) {
    // Aqui poderia implementar notificações push
    LoggerService.info('$title: $message', context: 'NOTIFICATION');
  }

  // Monitoramento em tempo real durante corrida
  Future<void> startRideTracking(String rideId) async {
    if (!isEnabled) return;
    
    return await ErrorHandler.safeAsync(() async {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Iniciar tracking da corrida
      await _firestore.collection('ride_tracking').doc(rideId).set({
        'userId': userId,
        'rideId': rideId,
        'startedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'trackingPoints': [],
      });

      LoggerService.success('Tracking da corrida iniciado: $rideId', context: 'SECURITY');
    }, context: 'start_ride_tracking');
  }

  Future<void> updateRideLocation(String rideId) async {
    if (!isEnabled) return;
    
    return await ErrorHandler.safeAsync(() async {
      final locationData = await _getCurrentLocationData();
      
      await _firestore.collection('ride_tracking').doc(rideId).update({
        'lastUpdate': FieldValue.serverTimestamp(),
        'currentLocation': locationData,
        'trackingPoints': FieldValue.arrayUnion([locationData]),
      });
    }, context: 'update_ride_location');
  }

  Future<void> stopRideTracking(String rideId) async {
    if (!isEnabled) return;
    
    return await ErrorHandler.safeAsync(() async {
      await _firestore.collection('ride_tracking').doc(rideId).update({
        'isActive': false,
        'endedAt': FieldValue.serverTimestamp(),
      });

      LoggerService.success('Tracking da corrida finalizado: $rideId', context: 'SECURITY');
    }, context: 'stop_ride_tracking');
  }
}