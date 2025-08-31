import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

/// Serviço para armazenamento seguro de dados sensíveis
/// Substitui o armazenamento de senha em texto plano por tokens seguros
class SecureStorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Chaves para armazenamento seguro
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserEmail = 'secure_user_email';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyLoginTimestamp = 'login_timestamp';

  /// Gera um token seguro baseado no uid do usuário
  static String _generateSecureToken(String uid) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$uid:$timestamp';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Salva token de autenticação seguro
  static Future<void> saveAuthToken(String userUid) async {
    try {
      final token = _generateSecureToken(userUid);
      await _secureStorage.write(key: _keyAuthToken, value: token);
      await _secureStorage.write(key: _keyLoginTimestamp, value: DateTime.now().toIso8601String());
      LoggerService.info('🔐 Token de autenticação salvo com segurança', context: 'SecureStorageService');
    } catch (e) {
      LoggerService.error('❌ Erro ao salvar token: $e', context: 'SecureStorageService');
    }
  }

  /// Obtém token de autenticação
  static Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: _keyAuthToken);
    } catch (e) {
      LoggerService.error(' Erro ao obter token: $e', context: 'SecureStorageService');
      return null;
    }
  }

  /// Salva email para funcionalidade "lembrar-me" (email não é senha)
  static Future<void> saveRememberMeData(String email, bool rememberMe) async {
    try {
      if (rememberMe) {
        await _secureStorage.write(key: _keyUserEmail, value: email);
        await _secureStorage.write(key: _keyRememberMe, value: 'true');
        LoggerService.info('📧 Dados "lembrar-me" salvos com segurança', context: 'SecureStorageService');
      } else {
        await _secureStorage.delete(key: _keyUserEmail);
        await _secureStorage.delete(key: _keyRememberMe);
        LoggerService.info('🗑️ Dados "lembrar-me" removidos', context: 'SecureStorageService');
      }
    } catch (e) {
      LoggerService.error(' Erro ao salvar dados lembrar-me: $e', context: 'SecureStorageService');
    }
  }

  /// Obtém dados salvos do "lembrar-me"
  static Future<Map<String, String?>> getRememberMeData() async {
    try {
      final email = await _secureStorage.read(key: _keyUserEmail);
      final rememberMe = await _secureStorage.read(key: _keyRememberMe);

      return {
        'email': email,
        'rememberMe': rememberMe,
      };
    } catch (e) {
      LoggerService.error(' Erro ao obter dados lembrar-me: $e', context: 'SecureStorageService');
      return {};
    }
  }

  /// Verifica se usuário tem token válido
  static Future<bool> hasValidToken() async {
    try {
      final token = await getAuthToken();
      final timestamp = await _secureStorage.read(key: _keyLoginTimestamp);

      if (token == null || timestamp == null) {
        return false;
      }

      // Token válido por 30 dias
      final loginTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(loginTime).inDays;

      return difference < 30;
    } catch (e) {
      LoggerService.error(' Erro ao validar token: $e', context: 'SecureStorageService');
      return false;
    }
  }

  /// Limpa todos os dados seguros (logout)
  static Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      LoggerService.info('🧹 Todos os dados seguros foram limpos', context: 'SecureStorageService');
    } catch (e) {
      LoggerService.error(' Erro ao limpar armazenamento seguro: $e', context: 'SecureStorageService');
    }
  }

  /// Limpa apenas tokens de autenticação (mantém "lembrar-me")
  static Future<void> clearAuthTokens() async {
    try {
      await _secureStorage.delete(key: _keyAuthToken);
      await _secureStorage.delete(key: _keyRefreshToken);
      await _secureStorage.delete(key: _keyLoginTimestamp);
      LoggerService.info('🔐 Tokens de autenticação limpos', context: 'SecureStorageService');
    } catch (e) {
      LoggerService.error(' Erro ao limpar tokens: $e', context: 'SecureStorageService');
    }
  }

  /// Obtém timestamp do último login
  static Future<DateTime?> getLastLoginTime() async {
    try {
      final timestamp = await _secureStorage.read(key: _keyLoginTimestamp);
      return timestamp != null ? DateTime.parse(timestamp) : null;
    } catch (e) {
      LoggerService.error(' Erro ao obter timestamp do login: $e', context: 'SecureStorageService');
      return null;
    }
  }
}