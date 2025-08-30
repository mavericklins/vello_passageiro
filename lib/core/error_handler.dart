import 'package:flutter/foundation.dart';
import 'logger_service.dart';

/// Sistema centralizado de tratamento de erros
class ErrorHandler {
  /// Mapa de mensagens amigáveis para tipos de erro comuns
  static const Map<String, String> _friendlyMessages = {
    'network': 'Problema de conexão. Verifique sua internet.',
    'auth': 'Erro de autenticação. Faça login novamente.',
    'permission': 'Permissão necessária não foi concedida.',
    'location': 'Não foi possível obter sua localização.',
    'firebase': 'Erro no servidor. Tente novamente em alguns instantes.',
    'validation': 'Dados inseridos são inválidos.',
    'timeout': 'Operação demorou muito. Tente novamente.',
    'unknown': 'Algo deu errado. Tente novamente.',
  };

  /// Trata um erro e retorna mensagem amigável
  static String handleError(
    dynamic error, {
    String? context,
    bool showUserMessage = true,
  }) {
    final errorInfo = _analyzeError(error);
    final contextStr = context != null ? '[$context]' : '';
    
    // Log estruturado do erro
    LoggerService.error(
      'Erro capturado $contextStr: ${errorInfo.technicalMessage}',
      error: error,
      context: context,
    );

    // Em modo debug, mostra erro técnico
    if (kDebugMode && showUserMessage) {
      LoggerService.debug('Detalhes técnicos: $error');
    }

    return errorInfo.userMessage;
  }

  /// Analisa o erro e retorna informações estruturadas
  static ErrorInfo _analyzeError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    // Erros de rede
    if (errorStr.contains('socketexception') || 
        errorStr.contains('network') ||
        errorStr.contains('connection')) {
      return ErrorInfo(
        type: 'network',
        userMessage: _friendlyMessages['network']!,
        technicalMessage: error.toString(),
      );
    }
    
    // Erros de autenticação
    if (errorStr.contains('auth') || 
        errorStr.contains('credential') ||
        errorStr.contains('token')) {
      return ErrorInfo(
        type: 'auth',
        userMessage: _friendlyMessages['auth']!,
        technicalMessage: error.toString(),
      );
    }
    
    // Erros de permissão
    if (errorStr.contains('permission') || 
        errorStr.contains('denied')) {
      return ErrorInfo(
        type: 'permission',
        userMessage: _friendlyMessages['permission']!,
        technicalMessage: error.toString(),
      );
    }
    
    // Erros de localização
    if (errorStr.contains('location') || 
        errorStr.contains('gps') ||
        errorStr.contains('geolocator')) {
      return ErrorInfo(
        type: 'location',
        userMessage: _friendlyMessages['location']!,
        technicalMessage: error.toString(),
      );
    }
    
    // Erros do Firebase
    if (errorStr.contains('firebase') || 
        errorStr.contains('firestore') ||
        errorStr.contains('cloud')) {
      return ErrorInfo(
        type: 'firebase',
        userMessage: _friendlyMessages['firebase']!,
        technicalMessage: error.toString(),
      );
    }
    
    // Timeout
    if (errorStr.contains('timeout') || 
        errorStr.contains('deadline')) {
      return ErrorInfo(
        type: 'timeout',
        userMessage: _friendlyMessages['timeout']!,
        technicalMessage: error.toString(),
      );
    }
    
    // Erro genérico
    return ErrorInfo(
      type: 'unknown',
      userMessage: _friendlyMessages['unknown']!,
      technicalMessage: error.toString(),
    );
  }

  /// Wrapper para operações assíncronas com tratamento automático
  static Future<T?> safeAsync<T>(
    Future<T> Function() operation, {
    String? context,
    T? fallback,
    bool showUserMessage = true,
  }) async {
    try {
      return await operation();
    } catch (e) {
      handleError(e, context: context, showUserMessage: showUserMessage);
      return fallback;
    }
  }

  /// Wrapper para operações síncronas com tratamento automático
  static T? safeSync<T>(
    T Function() operation, {
    String? context,
    T? fallback,
    bool showUserMessage = true,
  }) {
    try {
      return operation();
    } catch (e) {
      handleError(e, context: context, showUserMessage: showUserMessage);
      return fallback;
    }
  }
}

/// Informações estruturadas sobre um erro
class ErrorInfo {
  final String type;
  final String userMessage;
  final String technicalMessage;

  const ErrorInfo({
    required this.type,
    required this.userMessage,
    required this.technicalMessage,
  });
}