import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/trip_sharing.dart';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

/// Service responsável pelo compartilhamento de viagem em tempo real
class TripSharingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'trip_sharing';

  /// Compartilhar viagem com contatos selecionados
  static Future<String> shareTrip({
    required String tripId,
    required List<SharedContact> contacts,
    required TripLocation startLocation,
    required TripLocation endLocation,
    required DriverInfo driverInfo,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final trackingLink = _generateTrackingLink(tripId);
      
      final tripSharingData = TripSharingData(
        tripId: tripId,
        passengerId: user.uid,
        driverId: 'driver_temp', // Será atualizado quando motorista aceitar
        sharedContacts: contacts,
        tripData: TripData(
          startLocation: startLocation,
          endLocation: endLocation,
          currentLocation: startLocation, // Inicial igual ao ponto de partida
          estimatedArrival: DateTime.now().add(Duration(minutes: 20)),
          driverInfo: driverInfo,
        ),
        status: TripSharingStatus.waiting.value,
        trackingLink: trackingLink,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(tripId)
          .set(tripSharingData.toMap());
      
      // Enviar notificações para os contatos
      await _sendNotificationsToContacts(contacts, trackingLink, driverInfo);
      
      return trackingLink;
    } catch (e) {
      throw Exception('Erro ao compartilhar viagem: $e');
    }
  }

  /// Atualizar localização em tempo real durante a viagem
  static Future<void> updateTripLocation({
    required String tripId,
    required Position currentPosition,
    required String status,
    DateTime? estimatedArrival,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'tripData.currentLocation': TripLocation(
          lat: currentPosition.latitude,
          lng: currentPosition.longitude,
          address: 'Localização atual',
          timestamp: DateTime.now(),
        ).toMap(),
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (estimatedArrival != null) {
        updateData['tripData.estimatedArrival'] = Timestamp.fromDate(estimatedArrival);
      }

      await _firestore.collection(_collection).doc(tripId).update(updateData);
    } catch (e) {
      LoggerService.info('Erro ao atualizar localização: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Atualizar informações do motorista quando aceitar a corrida
  static Future<void> updateDriverInfo({
    required String tripId,
    required String driverId,
    required DriverInfo driverInfo,
  }) async {
    try {
      await _firestore.collection(_collection).doc(tripId).update({
        'driverId': driverId,
        'tripData.driverInfo': driverInfo.toMap(),
        'status': TripSharingStatus.inProgress.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notificar contatos sobre o motorista
      final tripDoc = await _firestore.collection(_collection).doc(tripId).get();
      if (tripDoc.exists) {
        final tripData = TripSharingData.fromMap(tripDoc.data()!);
        await _notifyDriverAssigned(tripData.sharedContacts, driverInfo, tripData.trackingLink);
      }
    } catch (e) {
      LoggerService.info('Erro ao atualizar informações do motorista: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Finalizar compartilhamento de viagem
  static Future<void> completeTripSharing(String tripId) async {
    try {
      await _firestore.collection(_collection).doc(tripId).update({
        'status': TripSharingStatus.completed.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notificar contatos sobre conclusão
      final tripDoc = await _firestore.collection(_collection).doc(tripId).get();
      if (tripDoc.exists) {
        final tripData = TripSharingData.fromMap(tripDoc.data()!);
        await _notifyTripCompleted(tripData.sharedContacts);
      }
    } catch (e) {
      LoggerService.info('Erro ao finalizar compartilhamento: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Cancelar compartilhamento de viagem
  static Future<void> cancelTripSharing(String tripId) async {
    try {
      await _firestore.collection(_collection).doc(tripId).update({
        'status': TripSharingStatus.cancelled.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notificar contatos sobre cancelamento
      final tripDoc = await _firestore.collection(_collection).doc(tripId).get();
      if (tripDoc.exists) {
        final tripData = TripSharingData.fromMap(tripDoc.data()!);
        await _notifyTripCancelled(tripData.sharedContacts);
      }
    } catch (e) {
      LoggerService.info('Erro ao cancelar compartilhamento: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Obter stream de dados de compartilhamento em tempo real
  static Stream<TripSharingData?> getTripSharingStream(String tripId) {
    return _firestore
        .collection(_collection)
        .doc(tripId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return TripSharingData.fromMap(doc.data()!);
      }
      return null;
    });
  }

  /// Obter dados de compartilhamento (uma vez)
  static Future<TripSharingData?> getTripSharingData(String tripId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(tripId).get();
      if (doc.exists && doc.data() != null) {
        return TripSharingData.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      LoggerService.info('Erro ao buscar dados de compartilhamento: $e', context: context ?? 'UNKNOWN');
      return null;
    }
  }

  /// Gerar link único de rastreamento
  static String _generateTrackingLink(String tripId) {
    return 'https://vello.app/track/$tripId';
  }

  /// Enviar notificações iniciais para contatos
  static Future<void> _sendNotificationsToContacts(
    List<SharedContact> contacts,
    String trackingLink,
    DriverInfo driverInfo,
  ) async {
    for (final contact in contacts) {
      final message = '''
🚗 *Vello - Compartilhamento de Viagem*

Olá ${contact.name}! 
Estou em uma viagem Vello e compartilhei com você para sua segurança.

📍 *Acompanhe em tempo real:*
$trackingLink

_Mensagem automática do app Vello_
_"Vai de Vello. Liberdade que te leva."_
      ''';

      await _sendWhatsAppMessage(contact.phone, message);
    }
  }

  /// Notificar sobre motorista designado
  static Future<void> _notifyDriverAssigned(
    List<SharedContact> contacts,
    DriverInfo driverInfo,
    String trackingLink,
  ) async {
    for (final contact in contacts) {
      final message = '''
🚗 *Vello - Motorista Designado*

Olá ${contact.name}!
O motorista foi designado para a viagem:

👤 *Motorista:* ${driverInfo.name}
⭐ *Avaliação:* ${driverInfo.rating.toStringAsFixed(1)}/5.0
🚙 *Veículo:* ${driverInfo.vehicle.model} ${driverInfo.vehicle.color}
🔢 *Placa:* ${driverInfo.vehicle.plate}

📍 *Acompanhe:* $trackingLink

_Mensagem automática do app Vello_
      ''';

      await _sendWhatsAppMessage(contact.phone, message);
    }
  }

  /// Notificar sobre conclusão da viagem
  static Future<void> _notifyTripCompleted(List<SharedContact> contacts) async {
    for (final contact in contacts) {
      final message = '''
✅ *Vello - Viagem Concluída*

Olá ${contact.name}!
A viagem foi concluída com sucesso.

Obrigado por acompanhar! 🙏

_Mensagem automática do app Vello_
      ''';

      await _sendWhatsAppMessage(contact.phone, message);
    }
  }

  /// Notificar sobre cancelamento da viagem
  static Future<void> _notifyTripCancelled(List<SharedContact> contacts) async {
    for (final contact in contacts) {
      final message = '''
❌ *Vello - Viagem Cancelada*

Olá ${contact.name}!
A viagem foi cancelada.

_Mensagem automática do app Vello_
      ''';

      await _sendWhatsAppMessage(contact.phone, message);
    }
  }

  /// Enviar mensagem via WhatsApp
  static Future<void> _sendWhatsAppMessage(String phone, String message) async {
    try {
      // Limpar o número de telefone (remover caracteres especiais)
      final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Garantir que o número tenha o código do país (+55 para Brasil)
      String formattedPhone = cleanPhone;
      if (!formattedPhone.startsWith('+')) {
        if (formattedPhone.startsWith('55')) {
          formattedPhone = '+$formattedPhone';
        } else {
          formattedPhone = '+55$formattedPhone';
        }
      }

      final whatsappUrl = 'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}';
      
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        LoggerService.info('Não foi possível abrir WhatsApp para: $phone', context: context ?? 'UNKNOWN');
      }
    } catch (e) {
      LoggerService.info('Erro ao enviar mensagem WhatsApp: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Verificar se usuário tem viagem ativa compartilhada
  static Future<String?> getActiveSharedTrip() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final query = await _firestore
          .collection(_collection)
          .where('passengerId', isEqualTo: user.uid)
          .where('status', whereIn: ['waiting', 'in_progress'])
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      }
      return null;
    } catch (e) {
      LoggerService.info('Erro ao verificar viagem ativa: $e', context: context ?? 'UNKNOWN');
      return null;
    }
  }

  /// Listar histórico de viagens compartilhadas
  static Future<List<TripSharingData>> getTripSharingHistory({int limit = 10}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final query = await _firestore
          .collection(_collection)
          .where('passengerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => TripSharingData.fromMap(doc.data()))
          .toList();
    } catch (e) {
      LoggerService.info('Erro ao buscar histórico: $e', context: context ?? 'UNKNOWN');
      return [];
    }
  }
}

