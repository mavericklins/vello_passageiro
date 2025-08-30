import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../services/auth_permanente_service.dart';
import '../services/assistente_voz_service.dart';
import '../services/advanced_security_service.dart';
import '../services/secure_storage_service.dart';
import '../theme/vello_tokens.dart';
import '../screens/login_screen.dart';
import '../main.dart';
import '../theme/vello_tokens.dart';

class SplashLoadingScreen extends StatefulWidget {
  @override
  _SplashLoadingScreenState createState() => _SplashLoadingScreenState();
}

class _SplashLoadingScreenState extends State<SplashLoadingScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _currentStep = 'Iniciando...';
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    
    _animationController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // ✅ ETAPA 3: Future.wait para inicialização sem race conditions
      await Future.wait([
        _initFirebase(),
        _initSecureStorage(),
        _initAuthService(), 
        _initVoiceService(),
        _initSecurityService(),
      ]);

      // Verificar se usuário já está logado
      final usuarioLogado = await AuthPermanenteService.isUsuarioLogado();
      
      // Navegar para tela apropriada
      _navigateToNextScreen(usuarioLogado);
      
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _initFirebase() async {
    setState(() => _currentStep = 'Inicializando Firebase...');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  Future<void> _initSecureStorage() async {
    setState(() => _currentStep = 'Configurando armazenamento seguro...');
    await SecureStorageService.hasValidToken();
  }

  Future<void> _initAuthService() async {
    setState(() => _currentStep = 'Verificando autenticação...');
    await AuthPermanenteService.isUsuarioLogado();
  }

  Future<void> _initVoiceService() async {
    setState(() => _currentStep = 'Carregando assistente de voz...');
    final voiceService = AssistenteVozService();
    await voiceService.inicializar();
  }

  Future<void> _initSecurityService() async {
    setState(() => _currentStep = 'Configurando segurança...');
    final securityService = AdvancedSecurityService();
    await securityService.initialize();
  }

  void _navigateToNextScreen(bool usuarioLogado) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => usuarioLogado 
            ? PremiumFeaturesDemo() 
            : LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.azul,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: VelloTokens.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.stars, color: VelloTokens.laranja, size: 40),
              ),
              SizedBox(height: 40),
              Text(
                'Vello Passageiro Premium',
                style: TextStyle(
                  color: VelloTokens.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 60),
              if (_hasError) ...[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 32),
                      SizedBox(height: 12),
                      Text(
                        'Erro na Inicialização',
                        style: TextStyle(
                          color: VelloTokens.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _errorMessage ?? '',
                        style: TextStyle(color: VelloTokens.white70, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(VelloTokens.white),
                  strokeWidth: 3,
                ),
                SizedBox(height: 20),
                Text(
                  _currentStep,
                  style: TextStyle(
                    color: VelloTokens.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}