import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home/home_screen.dart';
import 'dart:async';
import '../theme/vello_tokens.dart';

class LoadScreen extends StatefulWidget {
  const LoadScreen({Key? key}) : super(key: key);

  @override
  State<LoadScreen> createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> with TickerProviderStateMixin {
  double _progress = 0.0;
  late Timer _timer;
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late Animation<double> _logoAnimation;
  late Animation<double> _pulseAnimation;

  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;
  static const Color velloCardBackground = VelloTokens.white;

  @override
  void initState() {
    super.initState();
    
    // Animação da logo
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    
    // Animação de pulso
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _logoController.forward();
    _pulseController.repeat(reverse: true);
    _startProgress();
  }

  void _startProgress() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (_progress < 1.0) {
          _progress += 0.02;
        } else {
          _timer.cancel();
          _checkLoginStatus();
        }
      });
    });
  }

  void _checkLoginStatus() async {
    // Verifica primeiro o SharedPreferences (persistência local)
    final prefs = await SharedPreferences.getInstance();
    final logado = prefs.getBool('logado') ?? false;
    final nomeUsuario = prefs.getString('nomeUsuario') ?? '';

    if (logado && nomeUsuario.isNotEmpty) {
      // Usuário já logado via SharedPreferences
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userName: nomeUsuario),
        ),
      );
    } else {
      // Verifica Firebase Auth como fallback
      User? user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // Usuário logado no Firebase, salva no SharedPreferences
        await prefs.setBool('logado', true);
        await prefs.setString('nomeUsuario', user.displayName ?? user.email ?? 'Usuário');
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(userName: user.displayName ?? user.email ?? 'Usuário'),
          ),
        );
      } else {
        // Usuário não logado
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _logoController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              velloCardBackground, // Branco no topo
              velloLightGray, // Cinza claro no meio
              velloCardBackground, // Branco na base
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animada da Vello
              AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: velloCardBackground,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: velloBlue.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Image(
                              image: const AssetImage('assets/logo.png'),
                              width: 120,
                              height: 120,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              
              // Indicador de progresso elegante
              Container(
                width: 200,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: 200 * _progress,
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [velloOrange, velloOrange.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: velloOrange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Porcentagem
              Text(
                '${(_progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: velloBlue,
                ),
              ),
              const SizedBox(height: 30),
              
              // Texto de carregamento
              Text(
                'Carregando Vello...',
                style: TextStyle(
                  fontSize: 18,
                  color: velloBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sua jornada começa aqui.',
                style: TextStyle(
                  fontSize: 14,
                  color: velloBlue.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

