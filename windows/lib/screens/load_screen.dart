import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home/home_screen.dart';
import 'dart:async';

class LoadScreen extends StatefulWidget {
  const LoadScreen({Key? key}) : super(key: key);

  @override
  State<LoadScreen> createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen> {
  double _progress = 0.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: const AssetImage('assets/logo.png'),
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Carregando Vello...', 
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

