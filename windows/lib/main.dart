import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/load_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _verificarLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final logado = prefs.getBool('logado') ?? false;
    final nomeUsuario = prefs.getString('nomeUsuario') ?? '';

    if (logado && nomeUsuario.isNotEmpty) {
      return HomeScreen(userName: nomeUsuario);
    } else {
      return const LoadScreen(); // Exibe LoadScreen apenas se não estiver logado
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vello Passageiro',
           debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: FutureBuilder(
        future: _verificarLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!;
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

