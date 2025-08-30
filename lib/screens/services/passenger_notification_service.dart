import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

/// Serviço de notificações para o app passageiro
class PassengerNotificationService {
  static final PassengerNotificationService _instance = PassengerNotificationService._internal();
  factory PassengerNotificationService() => _instance;
  PassengerNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Callbacks para diferentes tipos de notificação
  Function(String driverId, Map<String, dynamic> driverInfo)? onDriverAssigned;
  Function(String message)? onDriverArriving;
  Function(String message)? onRideStarted;
  Function(String message)? onRideCompleted;
  Function(String message)? onRideCancelled;
  Function(String message)? onPaymentUpdate;

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    try {
      // Solicita permissões
      await _requestPermissions();
      
      // Configura notificações locais
      await _setupLocalNotifications();
      
      // Configura Firebase Messaging
      await _setupFirebaseMessaging();
      
      // Subscreve aos tópicos relevantes
      await _subscribeToTopics();
      
      LoggerService.info('PassengerNotificationService inicializado com sucesso', context: context ?? 'UNKNOWN');
    } catch (e) {
      LoggerService.info('Erro ao inicializar PassengerNotificationService: $e', context: context ?? 'UNKNOWN');
      rethrow;
    }
  }

  /// Solicita permissões necessárias
  Future<void> _requestPermissions() async {
    // Permissões Firebase Messaging
    final messagingSettings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (messagingSettings.authorizationStatus == AuthorizationStatus.authorized) {
      LoggerService.info('Permissões FCM concedidas', context: context ?? 'UNKNOWN');
    } else {
      LoggerService.info('Permissões FCM negadas', context: context ?? 'UNKNOWN');
    }

    // Permissões notificações locais (Android)
    final localSettings = await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    LoggerService.info('Permissões locais: $localSettings', context: context ?? 'UNKNOWN');
  }

  /// Configura notificações locais
  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Cria canais de notificação (Android)
    await _createNotificationChannels();
  }

  /// Cria canais de notificação específicos
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      // Canal para motorista
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'driver_channel',
          'Motorista',
          description: 'Notificações relacionadas ao motorista',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound('notification_driver'),
        ),
      );

      // Canal para corrida
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'ride_channel',
          'Corrida',
          description: 'Notificações de status da corrida',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound('notification_ride'),
        ),
      );

      // Canal para pagamento
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'payment_channel',
          'Pagamento',
          description: 'Notificações de pagamento',
          importance: Importance.high,
        ),
      );

      // Canal geral
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'general_channel',
          'Geral',
          description: 'Notificações gerais do Vello',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  /// Configura Firebase Messaging
  Future<void> _setupFirebaseMessaging() async {
    // Token FCM
    final token = await _firebaseMessaging.getToken();
    LoggerService.info('FCM Token: $token', context: context ?? 'UNKNOWN');
    
    // Salva token no Firestore se usuário autenticado
    final user = _auth.currentUser;
    if (user != null && token != null) {
      await _firestore.collection('passageiros').doc(user.uid).update({
        'fcm_token': token,
        'last_token_update': FieldValue.serverTimestamp(),
      });
    }

    // Listeners para mensagens
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    // Verifica se app foi aberto por notificação
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // Listener para refresh do token
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('passageiros').doc(user.uid).update({
          'fcm_token': newToken,
          'last_token_update': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  /// Subscreve aos tópicos relevantes
  Future<void> _subscribeToTopics() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Tópico geral para passageiros
      await _firebaseMessaging.subscribeToTopic('passengers');
      
      // Tópico específico do usuário
      await _firebaseMessaging.subscribeToTopic('passenger_${user.uid}');
      
      LoggerService.info('Subscrito aos tópicos FCM', context: context ?? 'UNKNOWN');
    }
  }

  /// Manipula mensagens recebidas em foreground
  void _handleForegroundMessage(RemoteMessage message) {
    LoggerService.info('Mensagem recebida em foreground: ${message.messageId}', context: context ?? 'UNKNOWN');
    
    final data = message.data;
    final notification = message.notification;
    
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'Vello',
        body: notification.body ?? '',
        payload: data.toString(),
        channelId: data['channel'] ?? 'general_channel',
      );
    }
    
    _processNotificationData(data);
  }

  /// Manipula quando app é aberto via notificação
  void _handleMessageOpenedApp(RemoteMessage message) {
    LoggerService.info('App aberto via notificação: ${message.messageId}', context: context ?? 'UNKNOWN');
    _processNotificationData(message.data);
  }

  /// Processa dados da notificação
  void _processNotificationData(Map<String, dynamic> data) {
    final type = data['type'];
    
    switch (type) {
      case 'driver_assigned':
        final driverId = data['driver_id'];
        final driverInfo = Map<String, dynamic>.from(data);
        onDriverAssigned?.call(driverId, driverInfo);
        break;
        
      case 'driver_arriving':
        onDriverArriving?.call(data['message'] ?? 'Motorista chegando');
        break;
        
      case 'ride_started':
        onRideStarted?.call(data['message'] ?? 'Corrida iniciada');
        break;
        
      case 'ride_completed':
        onRideCompleted?.call(data['message'] ?? 'Corrida finalizada');
        break;
        
      case 'ride_cancelled':
        onRideCancelled?.call(data['message'] ?? 'Corrida cancelada');
        break;
        
      case 'payment_update':
        onPaymentUpdate?.call(data['message'] ?? 'Atualização de pagamento');
        break;
        
      default:
        LoggerService.info('Tipo de notificação desconhecido: $type', context: context ?? 'UNKNOWN');
    }
  }

  /// Callback quando notificação é tocada
  void _onNotificationTapped(NotificationResponse response) {
    LoggerService.info('Notificação tocada: ${response.payload}', context: context ?? 'UNKNOWN');
    // Aqui você pode navegar para telas específicas baseado no payload
  }

  /// Mostra notificação local
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'general_channel',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Obtém nome do canal
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'driver_channel': return 'Motorista';
      case 'ride_channel': return 'Corrida';
      case 'payment_channel': return 'Pagamento';
      default: return 'Geral';
    }
  }

  /// Obtém descrição do canal
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case 'driver_channel': return 'Notificações relacionadas ao motorista';
      case 'ride_channel': return 'Notificações de status da corrida';
      case 'payment_channel': return 'Notificações de pagamento';
      default: return 'Notificações gerais do Vello';
    }
  }

  /// Mostra notificação simples
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'general_channel',
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: payload,
      channelId: channelId,
    );
  }

  /// Cancela todas as notificações
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Remove subscrições e limpa recursos
  Future<void> dispose() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firebaseMessaging.unsubscribeFromTopic('passengers');
      await _firebaseMessaging.unsubscribeFromTopic('passenger_${user.uid}');
    }
  }
}

