import 'package:flutter/foundation.dart';

/// Serviço centralizado de logging estruturado
class LoggerService {
  /// Configurações do logger
  static bool _isInitialized = false;
  static LogLevel _currentLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Inicializa o serviço de logging
  static void initialize({LogLevel? level}) {
    _currentLevel = level ?? (kDebugMode ? LogLevel.debug : LogLevel.info);
    _isInitialized = true;
    _log(LogLevel.info, 'Logger Service inicializado', context: 'SYSTEM');
  }

  /// Log de informação
  static void info(String message, {String? context, dynamic data}) {
    final tag = context ?? 'UNKNOWN';
    _log(LogLevel.info, message, context: tag, data: data);
  }

  /// Log de sucesso
  static void success(String message, {String? context, dynamic data}) {
    final tag = context ?? 'UNKNOWN';
    _log(LogLevel.success, message, context: tag, data: data);
  }

  /// Log de aviso
  static void warning(String message, {String? context, dynamic data}) {
    final tag = context ?? 'UNKNOWN';
    _log(LogLevel.warning, message, context: tag, data: data);
  }

  /// Log de erro
  static void error(String message, {String? context, dynamic error, dynamic data}) {
    final tag = context ?? 'UNKNOWN';
    _log(LogLevel.error, message, context: tag, error: error, data: data);
  }

  /// Log de debug (apenas em modo debug)
  static void debug(String message, {String? context, dynamic data}) {
    final tag = context ?? 'UNKNOWN';
    _log(LogLevel.debug, message, context: tag, data: data);
  }

  /// Método principal de logging
  static void _log(
    LogLevel level,
    String message, {
    String? context,
    dynamic error,
    dynamic data,
  }) {
    // CORREÇÃO: Usar 'code' ao invés de 'index' para evitar conflito com Enum.index
    if (level.code < _currentLevel.code) return;

    if (!_isInitialized) {
      initialize();
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.toString().split('.').last.toUpperCase();

    String logMessage = '[$timestamp] [$levelStr] [$context] $message';

    // Adiciona dados extras se fornecidos
    if (data != null) {
      logMessage += ' | Data: $data';
    }

    if (error != null) {
      logMessage += ' | Error: $error';
    }

    // Em produção, usa debugPrint para evitar truncamento
    // Em debug, usa print comum para melhor visualização
    if (kReleaseMode) {
      debugPrint('[$timestamp] $logMessage');
    } else {
      // Em debug mode, usa print com formatação colorida
      debugPrint('[$timestamp] $logMessage');
    }

    // Em caso de erro crítico, força o output mesmo em release
    if (level == LogLevel.error) {
      debugPrint('🚨 CRITICAL ERROR: $message');
      if (error != null) {
        debugPrint('🚨 ERROR DETAILS: $error');
      }
    }
  }

  /// Define o nível mínimo de log
  static void setLogLevel(LogLevel level) {
    _currentLevel = level;
    _log(LogLevel.info, 'Nível de log alterado para: ${level.name}', context: 'SYSTEM');
  }

  /// Retorna o nível atual
  static LogLevel get currentLevel => _currentLevel;

  /// Log de evento de lifecycle
  static void lifecycle(String event, {String? context, dynamic data}) {
    _log(LogLevel.info, 'LIFECYCLE: $event', context: context, data: data);
  }

  /// Log de performance
  static void performance(String operation, Duration duration, {String? context}) {
    final ms = duration.inMilliseconds;
    _log(LogLevel.info, 'PERFORMANCE: $operation executado em ${ms}ms', context: context);
  }

  /// Wrapper para medir performance de operações
  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation, {
    String? context,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();
      performance(operationName, stopwatch.elapsed, context: context);
      return result;
    } catch (e) {
      stopwatch.stop();
      error('$operationName falhou após ${stopwatch.elapsedMilliseconds}ms',
            error: e, context: context);
      rethrow;
    }
  }

  // Helper para verificar se o log deve ser executado
  static bool _shouldLog(LogLevel level) {
    return level.code >= _currentLevel.code;
  }
}

/// Níveis de log disponíveis
enum LogLevel {
  // CORREÇÃO: Renomear 'index' para 'code' para evitar conflito com Enum.index
  debug(0, '🔍', 'DEBUG'),
  info(1, 'ℹ️', 'INFO'),
  success(2, '✅', 'SUCCESS'),
  warning(3, '⚠️', 'WARNING'),
  error(4, '❌', 'ERROR');

  const LogLevel(this.code, this.emoji, this.name);

  final int code;
  final String emoji;
  final String name;
}