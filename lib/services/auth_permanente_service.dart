import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_storage_service.dart';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

class AuthPermanenteService {
  static const String _keyUsuarioLogado = 'usuario_logado';
  static const String _keyUsuarioUid = 'usuario_uid';
  static const String _keyUsuarioEmail = 'usuario_email';
  static const String _keyUsuarioNome = 'usuario_nome';
  static const String _keyUsuarioTelefone = 'usuario_telefone';
  static const String _keyDataLogin = 'data_login';

  /// Salva dados do usuário para login permanente (SEM SENHA)
  static Future<void> salvarUsuarioLogado(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Buscar dados completos do usuário no Firestore
      Map<String, dynamic> dadosUsuario = {};
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          dadosUsuario = userDoc.data() ?? {};
        }
      } catch (e) {
        LoggerService.error('Erro ao buscar dados do usuário: $e', context: 'AUTH_SERVICE');
      }

      // Salvar dados localmente (dados não-sensíveis)
      await prefs.setBool(_keyUsuarioLogado, true);
      await prefs.setString(_keyUsuarioUid, user.uid);
      await prefs.setString(_keyUsuarioEmail, user.email ?? '');
      await prefs.setString(_keyUsuarioNome, dadosUsuario['nome'] ?? user.displayName ?? '');
      await prefs.setString(_keyUsuarioTelefone, dadosUsuario['telefone'] ?? user.phoneNumber ?? '');
      await prefs.setString(_keyDataLogin, DateTime.now().toIso8601String());

      // Salvar token seguro no armazenamento criptografado
      await SecureStorageService.saveAuthToken(user.uid);

      LoggerService.success('Usuário salvo localmente para login permanente: ${user.uid}', context: 'AUTH_SERVICE');
      LoggerService.info('🔐 Token seguro gerado e armazenado', context: 'AUTH_SERVICE');
    } catch (e) {
      LoggerService.error('Erro ao salvar usuário localmente: $e', context: 'AUTH_SERVICE');
    }
  }

  /// Verifica se usuário está logado permanentemente usando token seguro
  static Future<bool> isUsuarioLogado() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localLogin = prefs.getBool(_keyUsuarioLogado) ?? false;
      final hasToken = await SecureStorageService.hasValidToken();
      
      // Usuário está logado se tem dados locais E token seguro válido
      return localLogin && hasToken;
    } catch (e) {
      LoggerService.error('Erro ao verificar login: $e', context: 'AUTH_SERVICE');
      return false;
    }
  }

  /// Obtém dados do usuário salvos localmente
  static Future<Map<String, String?>> getDadosUsuarioLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return {
        'uid': prefs.getString(_keyUsuarioUid),
        'email': prefs.getString(_keyUsuarioEmail),
        'nome': prefs.getString(_keyUsuarioNome),
        'telefone': prefs.getString(_keyUsuarioTelefone),
        'dataLogin': prefs.getString(_keyDataLogin),
      };
    } catch (e) {
      LoggerService.error('Erro ao obter dados locais: $e', context: 'AUTH_SERVICE');
      return {};
    }
  }

  /// Remove dados do usuário (logout) - limpa TUDO incluindo armazenamento seguro
  static Future<void> logout() async {
    try {
      // 1. Limpar dados do SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // 2. Limpar todos os dados do armazenamento seguro
      await SecureStorageService.clearAll();
      
      // 3. Fazer logout do Firebase
      await FirebaseAuth.instance.signOut();
      
      LoggerService.success('Logout completo realizado', context: 'AUTH_SERVICE');
      LoggerService.info('🧹 Dados seguros limpos', context: 'AUTH_SERVICE');
    } catch (e) {
      LoggerService.error('Erro no logout: $e', context: 'AUTH_SERVICE');
    }
  }

  /// Força login permanente usando token seguro - sem nunca expor senha
  static Future<User?> getUsuarioSempreLogado() async {
    try {
      // 1. Tentar usuário do Firebase Auth primeiro
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        LoggerService.success('Usuário do Firebase Auth: ${user.uid}', context: 'AUTH_SERVICE');
        return user;
      }

      // 2. Verificar se há dados salvos localmente E token seguro válido
      final dadosLocais = await getDadosUsuarioLocal();
      final isLogado = await isUsuarioLogado();
      
      if (isLogado && dadosLocais['uid'] != null) {
        LoggerService.success('Usuário com token seguro válido: ${dadosLocais['uid']}', context: 'AUTH_SERVICE');
        
        // Tentar reautenticar silenciosamente
        try {
          // Aguardar um pouco para Firebase inicializar
          await Future.delayed(const Duration(seconds: 1));
          user = FirebaseAuth.instance.currentUser;
          
          if (user != null && user.uid == dadosLocais['uid']) {
            LoggerService.success('Reautenticação silenciosa bem-sucedida com token seguro', context: 'AUTH_SERVICE');
            return user;
          }
        } catch (e) {
          LoggerService.error('Erro na reautenticação silenciosa: $e', context: 'AUTH_SERVICE');
        }
        
        LoggerService.warning('Usando dados locais com token seguro como fallback', context: 'AUTH_SERVICE');
        return null; // Retorna null mas dados locais com token serão usados
      }

      LoggerService.error('Nenhum usuário encontrado ou token inválido', context: 'AUTH_SERVICE');
      return null;
    } catch (e) {
      LoggerService.error('Erro ao obter usuário sempre logado: $e', context: 'AUTH_SERVICE');
      return null;
    }
  }

  /// Limpa apenas os tokens de autenticação (mantém "lembrar-me")
  static Future<void> limparApenasTokens() async {
    try {
      await SecureStorageService.clearAuthTokens();
      LoggerService.info('🔐 Apenas tokens de autenticação foram limpos', context: 'AUTH_SERVICE');
    } catch (e) {
      LoggerService.error('Erro ao limpar tokens: $e', context: 'AUTH_SERVICE');
    }
  }

  /// Verifica se o token de autenticação ainda é válido
  static Future<bool> isTokenValido() async {
    return await SecureStorageService.hasValidToken();
  }

  /// Obtém dados do usuário logado
  static Future<Map<String, dynamic>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return {
        'uid': prefs.getString(_keyUsuarioUid) ?? '',
        'email': prefs.getString(_keyUsuarioEmail) ?? '',
        'nome': prefs.getString(_keyUsuarioNome) ?? '',
        'name': prefs.getString(_keyUsuarioNome) ?? '', // Alias para compatibilidade
        'telefone': prefs.getString(_keyUsuarioTelefone) ?? '',
        'dataLogin': prefs.getString(_keyDataLogin) ?? '',
      };
    } catch (e) {
      LoggerService.error('Erro ao obter dados do usuário: $e', context: 'AUTH_SERVICE');
      return {};
    }
  }
}