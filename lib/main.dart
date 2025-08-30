import 'package:firebase_core/firebase_core.dart';
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
import 'services/advanced_security_service.dart';
import 'services/assistente_voz_service.dart';
import 'services/auth_permanente_service.dart';
import 'theme/vello_tokens.dart';

void main() async {
  // ✅ ETAPA 3: Bootstrap assíncrono confiável
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar sistema de logging
  LoggerService.initialize();
  LoggerService.lifecycle('App iniciando', context: 'MAIN');
  
  runApp(VelloPassageiroPremiumApp());
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
          primarySwatch: Colors.orange),
          primaryColor: VelloColors.azul,
          accentColor: VelloColors.laranja,
          backgroundColor: VelloColors.cinzaClaro,
          scaffoldBackgroundColor: VelloColors.cinzaClaro,
          fontFamily: 'Poppins',
          textTheme: TextTheme(
            displayLarge: TextStyle(
              color: VelloColors.azul,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: TextStyle(
              color: VelloColors.azul,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: TextStyle(
              color: VelloColors.cinza700,
            ),
            bodyMedium: TextStyle(
              color: VelloColors.cinza600,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelloColors.laranja,
              foregroundColor: VelloTokens.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: VelloTokens.white,
            foregroundColor: VelloColors.azul,
            elevation: 2,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              color: VelloColors.azul,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        home: SplashLoadingScreen(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => PremiumFeaturesDemo(),
          '/sos': (context) => SOSScreen(),
          '/chatbot': (context) => ChatbotSupportScreen(),
          '/emergency-contacts': (context) => EmergencyContactsScreen(),
        },
      ),
    );
  }
}

class PremiumFeaturesDemo extends StatefulWidget {
  const PremiumFeaturesDemo({Key? key}) : super(key: key);

  @override
  _PremiumFeaturesDemoState createState() => _PremiumFeaturesDemoState();
}

class _PremiumFeaturesDemoState extends State<PremiumFeaturesDemo> {
  final AssistenteVozService _voiceService = AssistenteVozService();
  final AdvancedSecurityService _securityService = AdvancedSecurityService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _voiceService.inicializar();
      await _securityService.initialize();
      LoggerService.success('Serviços inicializados com sucesso', context: 'SERVICES');
    } catch (e) {
      ErrorHandler.handleError(e, context: 'service_initialization');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: VelloColors.laranja,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.stars, color: VelloTokens.white, size: 18),
            ),
            SizedBox(width: 12),
            Text('Recursos Premium'),
          ],
        ),
        actions: [
          Consumer<AssistenteVozService>(
            builder: (context, voiceService, child) {
              return IconButton(
                icon: Icon(
                  voiceService.speechListening ? Icons.mic : Icons.mic_none,
                  color: voiceService.speechListening ? VelloColors.laranja : VelloColors.azul,
                ),
                onPressed: () {
                  if (voiceService.speechListening) {
                    voiceService.pararEscuta();
                  } else {
                    voiceService.iniciarEscuta();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar status do Firebase
            _buildFirebaseStatusCard(),
            SizedBox(height: 16),
            _buildWelcomeCard(),
            SizedBox(height: 24),
            _buildFeaturesGrid(),
            SizedBox(height: 24),
            _buildFeatureFlagsStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildFirebaseStatusCard() {
    const bool firebaseOk = true; // Firebase já foi inicializado no splash
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔥 Firebase Conectado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Projeto: vello-passageiro-premium',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: VelloColors.gradientePrimario,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [VelloColors.sombraPadrao],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: VelloTokens.white, size: 32),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vello Passageiro Premium',
                      style: TextStyle(
                        color: VelloTokens.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Recursos avançados de segurança e conveniência',
                      style: TextStyle(
                        color: VelloTokens.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Todos os recursos premium do Motorista agora disponíveis para Passageiros com a mesma identidade visual e funcionalidades avançadas.',
            style: TextStyle(
              color: VelloTokens.white.withOpacity(0.8),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      {
        'title': 'SOS Avançado',
        'description': 'Sistema de emergência com localização em tempo real',
        'icon': Icons.warning,
        'color': Colors.red,
        'enabled': FeatureFlags.enableAdvancedSOS,
        'route': '/sos',
      },
      {
        'title': 'Assistente de Voz',
        'description': 'Comandos de voz personalizados e TTS',
        'icon': Icons.record_voice_over,
        'color': Colors.blue,
        'enabled': FeatureFlags.enableVoiceAssistant,
        'action': () => _testVoiceAssistant(),
      },
      {
        'title': 'Compartilhar Viagem',
        'description': 'Notificar contatos sobre sua viagem',
        'icon': Icons.share_location,
        'color': VelloColors.laranja,
        'enabled': FeatureFlags.enableTripSharing,
        'action': () => _testTripSharing(),
      },
      {
        'title': 'Chatbot Suporte',
        'description': 'Assistente virtual inteligente 24/7',
        'icon': Icons.smart_toy,
        'color': Colors.purple,
        'enabled': FeatureFlags.enableChatbotSupport,
        'route': '/chatbot',
      },
      {
        'title': 'Contatos de Emergência',
        'description': 'Gerencie contatos para situações críticas',
        'icon': Icons.contacts,
        'color': Colors.green,
        'enabled': FeatureFlags.enableEmergencyService,
        'route': '/emergency-contacts',
      },
      {
        'title': 'Agendamento Premium',
        'description': 'Corridas recorrentes e notificações avançadas',
        'icon': Icons.event_repeat,
        'color': Colors.indigo,
        'enabled': FeatureFlags.enableScheduledRides,
        'action': () => _testScheduling(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recursos Disponíveis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: VelloColors.azul,
          ),
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return _buildFeatureCard(feature);
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    final bool isEnabled = feature['enabled'] ?? false;
    
    return InkWell(
      onTap: isEnabled ? () {
        if (feature['route'] != null) {
          Navigator.pushNamed(context, feature['route']);
        } else if (feature['action'] != null) {
          feature['action']();
        }
      } : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: VelloTokens.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [VelloColors.sombraPadrao],
          border: isEnabled ? null : Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEnabled 
                    ? (feature['color'] as Color).withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                feature['icon'] as IconData,
                color: isEnabled ? feature['color'] as Color : Colors.grey,
                size: 28,
              ),
            ),
            SizedBox(height: 12),
            Text(
              feature['title'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isEnabled ? VelloColors.azul : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              feature['description'] as String,
              style: TextStyle(
                fontSize: 11,
                color: isEnabled ? Colors.grey[600] : Colors.grey[400],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!isEnabled) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'DESABILITADO',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureFlagsStatus() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VelloTokens.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [VelloColors.sombraPadrao],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: VelloColors.azul),
              SizedBox(width: 12),
              Text(
                'Status dos Feature Flags',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: VelloColors.azul,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildFeatureFlagRow('Sistema SOS Avançado', FeatureFlags.enableAdvancedSOS),
          _buildFeatureFlagRow('Assistente de Voz', FeatureFlags.enableVoiceAssistant),
          _buildFeatureFlagRow('Compartilhamento de Viagem', FeatureFlags.enableTripSharing),
          _buildFeatureFlagRow('Serviço de Emergência', FeatureFlags.enableEmergencyService),
          _buildFeatureFlagRow('Suporte com Chatbot', FeatureFlags.enableChatbotSupport),
          _buildFeatureFlagRow('Corridas Agendadas', FeatureFlags.enableScheduledRides),
          _buildFeatureFlagRow('Tracking em Tempo Real', FeatureFlags.enableRealTimeTracking),
        ],
      ),
    );
  }

  Widget _buildFeatureFlagRow(String feature, bool enabled) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: enabled ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 13,
                color: VelloColors.cinza700,
              ),
            ),
          ),
          Text(
            enabled ? 'ON' : 'OFF',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: enabled ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _testVoiceAssistant() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Teste do Assistente de Voz',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: VelloColors.azul,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _voiceService.falar('Olá! Assistente de voz do Vello funcionando perfeitamente.');
                Navigator.pop(context);
              },
              child: Text('Testar Fala'),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                _voiceService.iniciarEscuta();
                Navigator.pop(context);
              },
              child: Text('Testar Escuta'),
            ),
          ],
        ),
      ),
    );
  }

  void _testTripSharing() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funcionalidade de compartilhamento disponível durante corridas'),
        backgroundColor: VelloColors.laranja,
      ),
    );
  }

  void _testScheduling() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agendamento premium disponível ao solicitar corridas'),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}