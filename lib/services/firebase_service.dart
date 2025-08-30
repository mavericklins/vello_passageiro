import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/logger_service.dart';

class FirebaseService {
  static Future<void> salvarEnderecoNoHistorico(String endereco) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      LoggerService.warning(' Usuário não autenticado para salvar histórico', context: context ?? 'UNKNOWN');
      return;
    }

    final historicoRef = FirebaseFirestore.instance
        .collection('passageiros')
        .doc(user.uid)
        .collection('historico_enderecos');

    await historicoRef.add({
      'endereco': endereco,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<String>> buscarUltimosEnderecos({int limite = 2}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      LoggerService.warning(' Usuário não autenticado para buscar histórico', context: context ?? 'UNKNOWN');
      return [];
    }

    final querySnapshot = await FirebaseFirestore.instance
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
}
