import 'package:flutter/material.dart';
import 'alterar_senha_screen.dart';
import 'sobre_app_screen.dart';
import 'privacidade_screen.dart';
import 'notificacoes_screen.dart';
import 'suporte_screen.dart';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Alterar Senha'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlterarSenhaScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Sobre o Aplicativo'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SobreAppScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Privacidade'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacidadeScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Notificações'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificacoesScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Suporte'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SuporteScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}


