import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static Future<void> salvarEnderecoNoHistorico(String endereco) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final historicoRef = FirebaseFirestore.instance
        .collection('passageiros')
        .doc(uid)
        .collection('historico_enderecos');

    await historicoRef.add({
      'endereco': endereco,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<String>> buscarUltimosEnderecos({int limite = 2}) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('passageiros')
        .doc(uid)
        .collection('historico_enderecos')
        .orderBy('timestamp', descending: true)
        .limit(limite)
        .get();

    return querySnapshot.docs
        .map((doc) => doc['endereco'] as String)
        .toList();
  }
}
