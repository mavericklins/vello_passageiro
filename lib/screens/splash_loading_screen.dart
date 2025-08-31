import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../services/auth_permanente_service.dart';
import '../services/assistente_voz_service.dart';
import '../services/advanced_security_service.dart';
import '../services/secure_storage_service.dart';
import '../theme/vello_tokens.dart';
import '../screens/login_screen.dart';
import '../screens/home/home_screen.dart';

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
      duration: const Duration(seconds: 2),
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
        _verifyFirebase(),
        _initSecureStorage(),
        _initAuthService(), 
        _initVoiceService(),
        _initSecurityService(),
      ]);

      // Verificar se usuário já está logado
      final usuarioLogado = await AuthPermanenteService.isUsuarioLogado();
      
      // Navegar para tela apropriada
      await _navigateToNextScreen(usuarioLogado);
      
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  /// Verifica se o Firebase já foi inicializado, não tenta inicializar novamente
  Future<void> _verifyFirebase() async {
    setState(() => _currentStep = 'Verificando Firebase...');
    
    try {
      // Tenta acessar a instância padrão do Firebase
      Firebase.app();
      // Se chegou aqui, o Firebase já está inicializado
      setState(() => _currentStep = 'Firebase já inicializado ✓');
    } on FirebaseException catch (e) {
      if (e.code == 'no-app') {
        // Firebase não foi inicializado, vamos inicializar
        setState(() => _currentStep = 'Inicializando Firebase...');
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
        setState(() => _currentStep = 'Firebase inicializado ✓');
      } else {
        // Outro erro do Firebase
        throw Exception('Erro no Firebase: ${e.message}');
      }
    } catch (e) {
      // Erro inesperado
      throw Exception('Erro inesperado no Firebase: $e');
    }
  }

  Future<void> _initSecureStorage() async {
    setState(() => _currentStep = 'Configurando armazenamento seguro...');
    await SecureStorageService.hasValidToken();
    setState(() => _currentStep = 'Armazenamento seguro ✓');
  }

  Future<void> _initAuthService() async {
    setState(() => _currentStep = 'Verificando autenticação...');
    await AuthPermanenteService.isUsuarioLogado();
    setState(() => _currentStep = 'Autenticação verificada ✓');
  }

  Future<void> _initVoiceService() async {
    setState(() => _currentStep = 'Carregando assistente de voz...');
    try {
      final voiceService = AssistenteVozService();
      await voiceService.inicializar();
      setState(() => _currentStep = 'Assistente de voz ✓');
    } catch (e) {
      // Não é crítico se o assistente de voz falhar
      setState(() => _currentStep = 'Assistente de voz (opcional) ⚠️');
    }
  }

  Future<void> _initSecurityService() async {
    setState(() => _currentStep = 'Configurando segurança...');
    try {
      final securityService = AdvancedSecurityService();
      await securityService.initialize();
      setState(() => _currentStep = 'Segurança configurada ✓');
    } catch (e) {
      // Não é crítico se o serviço de segurança falhar
      setState(() => _currentStep = 'Segurança (opcional) ⚠️');
    }
  }

  Future<void> _navigateToNextScreen(bool usuarioLogado) async {
    setState(() => _currentStep = 'Carregando interface...');
    
    // Pequeno delay para mostrar o status final
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (usuarioLogado) {
      // Obter nome do usuário
      setState(() => _currentStep = 'Carregando dados do usuário...');
      final userName = await _getUserName();
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomeScreen(userName: userName),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    }
  }

  Future<String> _getUserName() async {
    try {
      final userData = await AuthPermanenteService.getUserData();
      return userData['nome'] ?? userData['name'] ?? 'Usuário';
    } catch (e) {
      return 'Usuário';
    }
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
                child: const Icon(Icons.stars, color: VelloTokens.laranja, size: 40),
              ),
              const SizedBox(height: 40),
              const Text(
                'Vello Passageiro Premium',
                style: TextStyle(
                  color: VelloTokens.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),
              if (_hasError) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 32),
                      const SizedBox(height: 12),
                      const Text(
                        'Erro na Inicialização',
                        style: TextStyle(
                          color: VelloTokens.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage ?? '',
                        style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _errorMessage = null;
                            _currentStep = 'Tentando novamente...';
                          });
                          _initializeApp();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VelloTokens.white,
                          foregroundColor: VelloTokens.azul,
                        ),
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(VelloTokens.white),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 20),
                Text(
                  _currentStep,
                  style: const TextStyle(
                    color: Color(0xB3FFFFFF),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

