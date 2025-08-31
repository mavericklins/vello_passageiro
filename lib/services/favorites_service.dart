import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address_model.dart';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

enum FavoriteType { home, work, other }

class FavoriteAddress {
  final String id;
  final String name;
  final FavoriteType type;
  final AddressModel address;
  final DateTime createdAt;
  final String? icon;
  
  FavoriteAddress({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.createdAt,
    this.icon,
  });
  
  factory FavoriteAddress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteAddress(
      id: doc.id,
      name: data['name'] ?? '',
      type: FavoriteType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => FavoriteType.other,
      ),
      address: AddressModel.fromMap(data['address']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      icon: data['icon'],
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type.name,
      'address': address.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'icon': icon,
    };
  }
  
  String get displayIcon {
    switch (type) {
      case FavoriteType.home:
        return '🏠';
      case FavoriteType.work:
        return '🏢';
      case FavoriteType.other:
        return icon ?? '📍';
    }
  }
}

class FavoritesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static String? get _userId => _auth.currentUser?.uid;
  
  static CollectionReference? get _favoritesCollection {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('usuarios').doc(uid).collection('favoritos');
  }
  
  // Adicionar endereço favorito
  static Future<bool> addFavorite({
    required String name,
    required FavoriteType type,
    required AddressModel address,
    String? icon,
  }) async {
    try {
      final collection = _favoritesCollection;
      if (collection == null) {
        LoggerService.warning(' Usuário não autenticado para adicionar favorito', context: 'favorites_service');
        return false;
      }

      // Verificar se já existe um favorito do mesmo tipo (casa/trabalho)
      if (type != FavoriteType.other) {
        final existingQuery = await collection
            .where('type', isEqualTo: type.name)
            .get();
            
        if (existingQuery.docs.isNotEmpty) {
          // Atualizar o existente
          await existingQuery.docs.first.reference.update({
            'name': name,
            'address': address.toMap(),
            'icon': icon,
          });
          return true;
        }
      }
      
      final favorite = FavoriteAddress(
        id: '',
        name: name,
        type: type,
        address: address,
        createdAt: DateTime.now(),
        icon: icon,
      );
      
      await collection.add(favorite.toFirestore());
      return true;
    } catch (e) {
      LoggerService.info('Erro ao adicionar favorito: $e', context: 'favorites_service');
      return false;
    }
  }
  
  // Listar favoritos
  static Stream<List<FavoriteAddress>> getFavorites() {
    final collection = _favoritesCollection;
    if (collection == null) {
      return Stream.value([]); // Retorna stream vazio se não autenticado
    }
    
    return collection
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FavoriteAddress.fromFirestore(doc))
            .toList());
  }
  
  // Obter favorito específico por tipo
  static Future<FavoriteAddress?> getFavoriteByType(FavoriteType type) async {
    try {
      final collection = _favoritesCollection;
      if (collection == null) {
        LoggerService.warning(' Usuário não autenticado para buscar favorito', context: 'favorites_service');
        return null;
      }
      
      final query = await collection
          .where('type', isEqualTo: type.name)
          .limit(1)
          .get();
          
      if (query.docs.isNotEmpty) {
        return FavoriteAddress.fromFirestore(query.docs.first);
      }
      return null;
    } catch (e) {
      LoggerService.info('Erro ao buscar favorito: $e', context: 'favorites_service');
      return null;
    }
  }
  
  // Remover favorito
  static Future<bool> removeFavorite(String favoriteId) async {
    try {
      final collection = _favoritesCollection;
      if (collection == null) {
        LoggerService.warning(' Usuário não autenticado para remover favorito', context: 'favorites_service');
        return false;
      }
      
      await collection.doc(favoriteId).delete();
      return true;
    } catch (e) {
      LoggerService.info('Erro ao remover favorito: $e', context: 'favorites_service');
      return false;
    }
  }
  
  // Atualizar favorito
  static Future<bool> updateFavorite({
    required String favoriteId,
    required String name,
    String? icon,
  }) async {
    try {
      final collection = _favoritesCollection;
      if (collection == null) {
        LoggerService.warning(' Usuário não autenticado para atualizar favorito', context: 'favorites_service');
        return false;
      }
      
      await collection.doc(favoriteId).update({
        'name': name,
        'icon': icon,
      });
      return true;
    } catch (e) {
      LoggerService.info('Erro ao atualizar favorito: $e', context: 'favorites_service');
      return false;
    }
  }
  
  // Verificar se endereço já é favorito
  static Future<bool> isAddressFavorite(AddressModel address) async {
    try {
      final collection = _favoritesCollection;
      if (collection == null) {
        LoggerService.warning(' Usuário não autenticado para verificar favorito', context: 'favorites_service');
        return false;
      }
      
      final query = await collection
          .where('address.latitude', isEqualTo: address.latitude)
          .where('address.longitude', isEqualTo: address.longitude)
          .get();
          
      return query.docs.isNotEmpty;
    } catch (e) {
      LoggerService.info('Erro ao verificar favorito: $e', context: 'favorites_service');
      return false;
    }
  }
}