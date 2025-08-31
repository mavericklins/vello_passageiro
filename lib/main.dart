import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/error_handler.dart';
import 'core/feature_flags.dart';
import 'core/logger_service.dart';
import 'firebase_options.dart';
import 'screens/emergency/emergency_contacts_screen.dart';
import 'screens/login_screen.dart';
import 'screens/schedule/enhanced_schedule_screen.dart';
import 'screens/security/sos_screen.dart';
import 'screens/splash_loading_screen.dart';
import 'screens/suporte/chatbot_support_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/advanced_security_service.dart';
import 'services/assistente_voz_service.dart';
import 'services/auth_permanente_service.dart';
import 'theme/vello_tokens.dart';

void main() {
  // Rode TUDO na mesma zone (incluindo ensureInitialized e runApp)
  runZonedGuarded(() async {
    // 1) Bindings na MESMA zone do runApp
    WidgetsFlutterBinding.ensureInitialized();

    // 2) Captura erros Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('Flutter Error: ${details.exceptionAsString()}');
      // Em release você pode enviar para Crashlytics/Sentry aqui
    };

    // 3) Firebase: verificação robusta de instância existente
    await _getOrCreateDefaultFirebase();

    // 4) Logger depois do Firebase (se ele usa Firebase)
    LoggerService.initialize();
    LoggerService.lifecycle('App iniciando', context: 'MAIN');

    // 5) Sobe a UI
    runApp(const VelloPassageiroPremiumApp());
  }, (error, stack) {
    // Fallback global sem derrubar a UI
    debugPrint('Async Error: $error\n$stack');
    LoggerService.error(
      'Async Error: $error',
      error: stack,
      context: 'AsyncErrorHandler',
    );
  });
}

/// Verificação robusta e reutilização da instância Firebase [DEFAULT]
Future<void> _getOrCreateDefaultFirebase() async {
  try {
    // Primeira tentativa: verificar se já existe uma instância padrão
    final app = Firebase.app();
    debugPrint('Firebase [DEFAULT] já existe: ${app.name}');
    return;
  } on FirebaseException catch (e) {
    // Se o código for 'no-app', significa que não existe instância padrão
    if (e.code == 'no-app') {
      debugPrint('Firebase [DEFAULT] não existe, criando nova instância...');
      
      try {
        // Criar nova instância com as opções corretas
        final app = await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('Firebase [DEFAULT] criado com sucesso: ${app.name}');
        return;
      } on FirebaseException catch (e2) {
        // Se ainda assim falhar, pode ser que já exista (race condition)
        if (e2.code == 'duplicate-app') {
          debugPrint('Firebase [DEFAULT] já existe (race condition detectada)');
          // Tentar acessar a instância existente
          try {
            final existingApp = Firebase.app();
            debugPrint('Usando instância existente: ${existingApp.name}');
            return;
          } catch (e3) {
            debugPrint('Erro ao acessar instância existente: $e3');
          }
        } else {
          debugPrint('Firebase initializeApp falhou: ${e2.code} ${e2.message}');
        }
      } catch (e2) {
        debugPrint('Erro inesperado ao inicializar Firebase: $e2');
      }
    } else {
      // Outro tipo de erro ao tentar acessar Firebase.app()
      debugPrint('Firebase.app() falhou com código: ${e.code} - ${e.message}');
    }
  } catch (e) {
    debugPrint('Erro inesperado no bootstrap do Firebase: $e');
  }
  
  // Se chegou até aqui, houve algum problema, mas não vamos impedir o app de iniciar
  debugPrint('Firebase pode não estar totalmente configurado, mas o app continuará');
}

class VelloPassageiroPremiumApp extends StatelessWidget {
  const VelloPassageiroPremiumApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AssistenteVozService()),
      ],
      child: MaterialApp(
        title: 'Vello Passageiro Premium',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: VelloTokens.brand,
            primary: VelloTokens.azul,
            secondary: VelloTokens.laranja,
            surface: VelloTokens.cinzaClaro,
          ),
          scaffoldBackgroundColor: VelloTokens.cinzaClaro,
          fontFamily: 'Poppins',
          textTheme: TextTheme(
            displayLarge: TextStyle(
              color: VelloTokens.azul,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: TextStyle(
              color: VelloTokens.azul,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: TextStyle(color: VelloTokens.cinza700),
            bodyMedium: TextStyle(color: VelloTokens.cinza600),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelloTokens.laranja,
              foregroundColor: VelloTokens.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: VelloTokens.white,
            foregroundColor: VelloTokens.azul,
            elevation: 2,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: VelloTokens.azul,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        home: SplashLoadingScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => _buildHomeScreen(),
          '/sos': (context) => SOSScreen(),
          '/chatbot': (context) => ChatbotSupportScreen(),
          '/emergency-contacts': (context) => EmergencyContactsScreen(),
        },
      ),
    );
  }

  Widget _buildHomeScreen() {
    return FutureBuilder<String>(
      future: _getUserName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final userName = snapshot.data ?? 'Usuário';
        return HomeScreen(userName: userName);
      },
    );
  }

  Future<String> _getUserName() async {
    try {
      final userData = await AuthPermanenteService.getUserData();
      return userData['nome'] ?? userData['name'] ?? 'Usuário';
    } catch (e) {
      return 'Usuário';
    }
  }
}

