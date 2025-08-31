import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/logger_service.dart';
import '../models/address_model.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('Usuário não autenticado');
    }
    return uid;
  }

  // ===================== HISTÓRICO DE ENDEREÇOS =====================
  Future<void> salvarEnderecoNoHistorico(String endereco) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      LoggerService.warning('Usuário não autenticado para salvar histórico', context: 'FirebaseService');
      return;
    }

    final historicoRef = _db
        .collection('passageiros')
        .doc(user.uid)
        .collection('historico_enderecos');

    await historicoRef.add({
      'endereco': endereco,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> buscarUltimosEnderecos({int limite = 2}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      LoggerService.warning('Usuário não autenticado para buscar histórico', context: 'FirebaseService');
      return [];
    }

    final querySnapshot = await _db
        .collection('passageiros')
        .doc(user.uid)
        .collection('historico_enderecos')
        .orderBy('timestamp', descending: true)
        .limit(limite)
        .get();

    return querySnapshot.docs
        .map((doc) {
          final data = doc.data();
          return data['endereco'] as String? ?? '';
        })
        .where((endereco) => endereco.isNotEmpty)
        .toList();
  }

  // ===================== INCIDENTES =====================
  Future<void> reportIncident({
    required String type,
    required String description,
    required double lat,
    required double lng,
  }) async {
    await _db.collection('incidents').add({
      'userId': _uid,
      'type': type,
      'description': description,
      'location': {
        'latitude': lat,
        'longitude': lng,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'open',
    });
  }

  // ===================== ENDEREÇOS FAVORITOS =====================
  Future<void> addFavoriteAddress({
    required String label,
    required String address,
    required double lat,
    required double lng,
  }) async {
    final ref = _db
        .collection('passageiros')
        .doc(_uid)
        .collection('favorite_addresses');
    await ref.add({
      'label': label,
      'address': address,
      'location': {'latitude': lat, 'longitude': lng},
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteFavoriteAddress(String addressId) async {
    final ref = _db
        .collection('passageiros')
        .doc(_uid)
        .collection('favorite_addresses')
        .doc(addressId);
    await ref.delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFavoriteAddresses() {
    final ref = _db
        .collection('passageiros')
        .doc(_uid)
        .collection('favorite_addresses')
        .orderBy('createdAt', descending: true);
    return ref.snapshots();
  }

  // ===================== MOTORISTAS PREFERIDOS =====================
  Future<void> addPreferredDriver({
    required String driverId,
    required String name,
  }) async {
    final ref = _db
        .collection('passageiros')
        .doc(_uid)
        .collection('preferred_drivers')
        .doc(driverId);
    await ref.set({
      'driverId': driverId,
      'name': name,
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removePreferredDriver(String driverId) async {
    final ref = _db
        .collection('passageiros')
        .doc(_uid)
        .collection('preferred_drivers')
        .doc(driverId);
    await ref.delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPreferredDrivers() {
    final ref = _db
        .collection('passageiros')
        .doc(_uid)
        .collection('preferred_drivers')
        .orderBy('addedAt', descending: true);
    return ref.snapshots();
  }

  // ===================== PREFERÊNCIAS DE VIAGEM =====================
  Future<Map<String, dynamic>> getTravelPreferences() async {
    final doc = await _db
        .collection('passageiros')
        .doc(_uid)
        .collection('profile')
        .doc('travel_preferences')
        .get();
    return doc.data() ?? <String, dynamic>{};
  }

  Future<void> saveTravelPreferences(Map<String, dynamic> prefs) async {
    final ref = _db
        .collection('passageiros')
        .doc(_uid)
        .collection('profile')
        .doc('travel_preferences');
    await ref.set(
      {
        ...prefs,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ===================== CORRIDAS AGENDADAS =====================
  Future<String?> saveScheduledRide({
    required AddressModel origin,
    required AddressModel destination,
    required List<AddressModel> waypoints,
    required DateTime scheduledAt,
    required String vehicleType,
    required double priceEstimate,
    String? notes,
    String? couponCode,
  }) async {
    try {
      final data = {
        'passengerId': _uid,
        'origin': origin.toMap(),
        'destination': destination.toMap(),
        'waypoints': waypoints.map((w) => w.toMap()).toList(),
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'vehicleType': vehicleType,
        'priceEstimate': priceEstimate,
        'status': 'scheduled',
        'createdAt': FieldValue.serverTimestamp(),
        'notes': notes,
        'couponCode': couponCode,
      };

      final docRef = await _db.collection('corridas_agendadas').add(data);
      LoggerService.info('📅 Corrida agendada salva com sucesso', context: 'FirebaseService');
      return docRef.id;
    } catch (e) {
      LoggerService.error('❌ Erro ao salvar corrida agendada: $e', context: 'FirebaseService');
      return null;
    }
  }
}