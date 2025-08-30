import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;
import '../core/logger_service.dart';
import '../core/error_handler.dart';

class PassengerAnalyticsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  static final FirebasePerformance _performance = FirebasePerformance.instance;

  /// Inicializar serviço de analytics
  static Future<void> inicializar() async {
    try {
      LoggerService.info('📊 Inicializando serviço de analytics do passageiro...', context: context ?? 'UNKNOWN');

      // Configurar Crashlytics
      await _configurarCrashlytics();

      // Configurar Analytics
      await _configurarAnalytics();

      // Configurar Performance Monitoring
      await _configurarPerformance();

      // Registrar informações do dispositivo
      await _registrarInfoDispositivo();

      // Iniciar monitoramento de sessão
      await _iniciarSessao();

      LoggerService.success(' Serviço de analytics do passageiro inicializado', context: context ?? 'UNKNOWN');
    } catch (e) {
      LoggerService.error(' Erro ao inicializar analytics: $e', context: context ?? 'UNKNOWN');
      await registrarErro('passenger_analytics_init_error', e);
    }
  }

  /// Configurar Crashlytics
  static Future<void> _configurarCrashlytics() async {
    // Habilitar coleta de crash reports
    await _crashlytics.setCrashlyticsCollectionEnabled(true);

    // Configurar usuário
    final user = _auth.currentUser;
    if (user != null) {
      await _crashlytics.setUserIdentifier(user.uid);
    }

    // Configurar handler de erros Flutter
    FlutterError.onError = (errorDetails) {
      _crashlytics.recordFlutterFatalError(errorDetails);
    };

    // Configurar handler de erros assíncronos
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Configurar Analytics
  static Future<void> _configurarAnalytics() async {
    // Habilitar coleta de dados
    await _analytics.setAnalyticsCollectionEnabled(true);

    // Configurar propriedades de usuário
    final user = _auth.currentUser;
    if (user != null) {
      await _analytics.setUserId(id: user.uid);
      await _analytics.setUserProperty(name: 'user_type', value: 'passageiro');
    }

    // Configurar propriedades do app
    final packageInfo = await PackageInfo.fromPlatform();
    await _analytics.setUserProperty(name: 'app_version', value: packageInfo.version);
    await _analytics.setUserProperty(name: 'app_build', value: packageInfo.buildNumber);
  }

  /// Configurar Performance Monitoring
  static Future<void> _configurarPerformance() async {
    // Habilitar coleta de performance
    await _performance.setPerformanceCollectionEnabled(true);
  }

  /// Registrar informações do dispositivo
  static Future<void> _registrarInfoDispositivo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      Map<String, dynamic> infoDispositivo = {
        'app_version': packageInfo.version,
        'app_build': packageInfo.buildNumber,
        'platform': Platform.operatingSystem,
      };

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        infoDispositivo.addAll({
          'device_model': androidInfo.model,
          'device_brand': androidInfo.brand,
          'android_version': androidInfo.version.release,
          'api_level': androidInfo.version.sdkInt,
          'is_physical_device': androidInfo.isPhysicalDevice,
        });
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        infoDispositivo.addAll({
          'device_model': iosInfo.model,
          'ios_version': iosInfo.systemVersion,
          'is_physical_device': iosInfo.isPhysicalDevice,
        });
      }

      // Salvar no Firestore
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('passenger_analytics_dispositivos').doc(user.uid).set({
          ...infoDispositivo,
          'ultima_atualizacao': Timestamp.now(),
        }, SetOptions(merge: true));
      }

      // Configurar propriedades no Analytics
      for (final entry in infoDispositivo.entries) {
        if (entry.value is String) {
          await _analytics.setUserProperty(name: entry.key, value: entry.value);
        }
      }
    } catch (e) {
      LoggerService.error(' Erro ao registrar info do dispositivo: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Iniciar sessão
  static Future<void> _iniciarSessao() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final posicao = await _obterPosicaoAtual();

      await _firestore.collection('passenger_analytics_sessoes').add({
        'passageiroId': user.uid,
        'inicio_sessao': Timestamp.now(),
        'posicao_inicial': posicao != null ? {
          'latitude': posicao.latitude,
          'longitude': posicao.longitude,
        } : null,
        'ativa': true,
      });

      // Registrar evento no Analytics
      await _analytics.logEvent(
        name: 'passenger_session_start',
        parameters: {
          'user_id': user.uid,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      LoggerService.error(' Erro ao iniciar sessão: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Finalizar sessão
  static Future<void> finalizarSessao() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Buscar sessão ativa
      final sessaoQuery = await _firestore
          .collection('passenger_analytics_sessoes')
          .where('passageiroId', isEqualTo: user.uid)
          .where('ativa', isEqualTo: true)
          .orderBy('inicio_sessao', descending: true)
          .limit(1)
          .get();

      if (sessaoQuery.docs.isNotEmpty) {
        final sessaoDoc = sessaoQuery.docs.first;
        final inicioSessao = (sessaoDoc.data()['inicio_sessao'] as Timestamp).toDate();
        final duracaoMinutos = DateTime.now().difference(inicioSessao).inMinutes;

        final posicao = await _obterPosicaoAtual();

        await sessaoDoc.reference.update({
          'fim_sessao': Timestamp.now(),
          'duracao_minutos': duracaoMinutos,
          'posicao_final': posicao != null ? {
            'latitude': posicao.latitude,
            'longitude': posicao.longitude,
          } : null,
          'ativa': false,
        });

        // Registrar evento no Analytics
        await _analytics.logEvent(
          name: 'passenger_session_end',
          parameters: {
            'user_id': user.uid,
            'duration_minutes': duracaoMinutos,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        );
      }
    } catch (e) {
      LoggerService.error(' Erro ao finalizar sessão: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Registrar evento de viagem
  static Future<void> registrarEventoViagem({
    required String evento,
    required String viagemId,
    Map<String, dynamic>? parametrosAdicionais,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final parametros = {
        'user_id': user.uid,
        'trip_id': viagemId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?parametrosAdicionais,
      };

      // Registrar no Analytics
      await _analytics.logEvent(name: evento, parameters: Map<String, Object>.from(parametros));

      // Salvar no Firestore para análise detalhada
      await _firestore.collection('passenger_analytics_eventos').add({
        'passageiroId': user.uid,
        'evento': evento,
        'viagemId': viagemId,
        'parametros': parametros,
        'timestamp': Timestamp.now(),
      });

      LoggerService.info('📊 Evento registrado: $evento', context: context ?? 'UNKNOWN');
    } catch (e) {
      LoggerService.error(' Erro ao registrar evento de viagem: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Registrar evento personalizado
  static Future<void> registrarEvento({
    required String nomeEvento,
    Map<String, dynamic>? parametros,
  }) async {
    try {
      final user = _auth.currentUser;

      final parametrosCompletos = {
        'user_id': user?.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?parametros,
      };

      // Registrar no Analytics
      await _analytics.logEvent(name: nomeEvento, parameters: Map<String, Object>.from(parametrosCompletos));

      // Salvar no Firestore
      await _firestore.collection('passenger_analytics_eventos').add({
        'passageiroId': user?.uid,
        'evento': nomeEvento,
        'parametros': parametrosCompletos,
        'timestamp': Timestamp.now(),
      });

      LoggerService.info('📊 Evento personalizado registrado: $nomeEvento', context: context ?? 'UNKNOWN');
    } catch (e) {
      LoggerService.error(' Erro ao registrar evento personalizado: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Registrar erro
  static Future<void> registrarErro(String erro, dynamic exception, [StackTrace? stackTrace]) async {
    try {
      // Registrar no Crashlytics
      await _crashlytics.recordError(exception, stackTrace, fatal: false);

      // Registrar no Analytics
      await _analytics.logEvent(
        name: 'passenger_app_error',
        parameters: {
          'error_type': erro,
          'error_message': exception.toString(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // Salvar no Firestore
      final user = _auth.currentUser;
      await _firestore.collection('passenger_analytics_erros').add({
        'passageiroId': user?.uid,
        'tipo_erro': erro,
        'mensagem': exception.toString(),
        'stack_trace': stackTrace?.toString(),
        'timestamp': Timestamp.now(),
      });

      LoggerService.info('🚨 Erro registrado: $erro', context: context ?? 'UNKNOWN');
    } catch (e) {
      LoggerService.error(' Erro ao registrar erro: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Monitorar performance de operação
  static Future<T> monitorarPerformance<T>(
    String nomeOperacao,
    Future<T> Function() operacao,
  ) async {
    final trace = _performance.newTrace(nomeOperacao);
    await trace.start();

    try {
      final resultado = await operacao();
      trace.setMetric('success', 1);
      return resultado;
    } catch (e) {
      trace.setMetric('error', 1);
      await registrarErro('passenger_performance_error_$nomeOperacao', e);
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Registrar métricas de uso
  static Future<void> registrarMetricasUso({
    required String categoria,
    required String acao,
    String? valor,
    int? valorNumerico,
  }) async {
    try {
      final user = _auth.currentUser;

      // Registrar no Analytics
      await _analytics.logEvent(
        name: 'passenger_user_action',
        parameters: {
          'category': categoria,
          'action': acao,
          'value': valor ?? '',
          'numeric_value': valorNumerico ?? 0,
          'user_id': user?.uid ?? '',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // Salvar métricas detalhadas
      await _firestore.collection('passenger_analytics_metricas').add({
        'passageiroId': user?.uid,
        'categoria': categoria,
        'acao': acao,
        'valor': valor,
        'valor_numerico': valorNumerico,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      LoggerService.error(' Erro ao registrar métricas de uso: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Obter relatório de analytics
  static Future<Map<String, dynamic>> obterRelatorioAnalytics({
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final inicio = dataInicio ?? DateTime.now().subtract(Duration(days: 30));
      final fim = dataFim ?? DateTime.now();

      // Buscar eventos
      final eventosQuery = _firestore
          .collection('passenger_analytics_eventos')
          .where('passageiroId', isEqualTo: user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(fim));

      final eventosSnapshot = await eventosQuery.get();

      // Buscar sessões
      final sessoesQuery = _firestore
          .collection('passenger_analytics_sessoes')
          .where('passageiroId', isEqualTo: user.uid)
          .where('inicio_sessao', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
          .where('inicio_sessao', isLessThanOrEqualTo: Timestamp.fromDate(fim));

      final sessoesSnapshot = await sessoesQuery.get();

      // Processar dados
      final eventos = eventosSnapshot.docs.map((doc) => doc.data()).toList();
      final sessoes = sessoesSnapshot.docs.map((doc) => doc.data()).toList();

      // Calcular estatísticas
      final totalEventos = eventos.length;
      final totalSessoes = sessoes.length;
      final duracaoMediaSessao = sessoes.isNotEmpty
          ? sessoes
              .where((s) => s['duracao_minutos'] != null)
              .map((s) => s['duracao_minutos'] as int)
              .reduce((a, b) => a + b) / sessoes.length
          : 0.0;

      // Eventos por tipo
      final eventosPorTipo = <String, int>{};
      for (final evento in eventos) {
        final tipo = evento['evento'] as String;
        eventosPorTipo[tipo] = (eventosPorTipo[tipo] ?? 0) + 1;
      }

      return {
        'periodo': {
          'inicio': inicio.toIso8601String(),
          'fim': fim.toIso8601String(),
        },
        'resumo': {
          'total_eventos': totalEventos,
          'total_sessoes': totalSessoes,
          'duracao_media_sessao_minutos': duracaoMediaSessao,
        },
        'eventos_por_tipo': eventosPorTipo,
        'eventos_detalhados': eventos,
        'sessoes': sessoes,
      };
    } catch (e) {
      LoggerService.error(' Erro ao obter relatório de analytics: $e', context: context ?? 'UNKNOWN');
      return {};
    }
  }

  /// Configurar propriedades de usuário
  static Future<void> configurarPropriedadesUsuario(Map<String, String> propriedades) async {
    try {
      for (final entry in propriedades.entries) {
        await _analytics.setUserProperty(name: entry.key, value: entry.value);
      }

      // Salvar no Firestore também
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('passenger_analytics_usuarios').doc(user.uid).set({
          ...propriedades,
          'ultima_atualizacao': Timestamp.now(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      LoggerService.error(' Erro ao configurar propriedades de usuário: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Registrar gasto
  static Future<void> registrarGasto({
    required String tipoGasto,
    required double valor,
    String? moeda = 'BRL',
  }) async {
    try {
      await _analytics.logEvent(
        name: 'passenger_expense',
        parameters: {
          'expense_type': tipoGasto,
          'value': valor,
          'currency': moeda ?? 'BRL',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // Salvar gasto detalhado
      final user = _auth.currentUser;
      await _firestore.collection('passenger_analytics_gastos').add({
        'passageiroId': user?.uid,
        'tipo': tipoGasto,
        'valor': valor,
        'moeda': moeda,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      LoggerService.error(' Erro ao registrar gasto: $e', context: context ?? 'UNKNOWN');
    }
  }

  /// Métodos auxiliares privados
  static Future<Position?> _obterPosicaoAtual() async {
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  /// Registrar eventos específicos do passageiro
  static Future<void> registrarSolicitacaoViagem() async {
    await registrarEvento(nomeEvento: 'passenger_trip_requested');
  }

  static Future<void> registrarCancelamentoViagem() async {
    await registrarEvento(nomeEvento: 'passenger_trip_cancelled');
  }

  static Future<void> registrarViagemSolicitada(String viagemId, double valor) async {
    await registrarEventoViagem(
      evento: 'trip_requested',
      viagemId: viagemId,
      parametrosAdicionais: {'trip_value': valor},
    );
  }

  static Future<void> registrarViagemConcluida(String viagemId, double valor, int duracaoMinutos) async {
    await registrarEventoViagem(
      evento: 'trip_completed',
      viagemId: viagemId,
      parametrosAdicionais: {
        'trip_value': valor,
        'duration_minutes': duracaoMinutos,
      },
    );

    // Registrar como gasto também
    await registrarGasto(tipoGasto: 'trip_completed', valor: valor);
  }

  static Future<void> registrarViagemCancelada(String viagemId, String motivo) async {
    await registrarEventoViagem(
      evento: 'trip_cancelled',
      viagemId: viagemId,
      parametrosAdicionais: {'cancellation_reason': motivo},
    );
  }

  static Future<void> registrarPagamentoRealizado(double valor, String metodo) async {
    await registrarEvento(
      nomeEvento: 'payment_made',
      parametros: {
        'amount': valor,
        'payment_method': metodo,
      },
    );

    // Registrar como gasto
    await registrarGasto(tipoGasto: 'payment_made', valor: valor);
  }

  static Future<void> registrarAvaliacaoMotorista(String viagemId, int nota) async {
    await registrarEventoViagem(
      evento: 'driver_rated',
      viagemId: viagemId,
      parametrosAdicionais: {'rating': nota},
    );
  }
}