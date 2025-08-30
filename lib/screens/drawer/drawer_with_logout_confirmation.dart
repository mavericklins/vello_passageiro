import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';

Drawer buildDrawer(BuildContext context) {
  return Drawer(
    child: Container(
      color: Colors.orange,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.orange),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VELLO',
                  style: TextStyle(
                    color: VelloTokens.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/logo.png'),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: VelloTokens.white),
            title: const Text('Perfil', style: TextStyle(color: VelloTokens.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.history, color: VelloTokens.white),
            title: const Text('Histórico', style: TextStyle(color: VelloTokens.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.payment, color: VelloTokens.white),
            title: const Text('Pagamento', style: TextStyle(color: VelloTokens.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: VelloTokens.white),
            title: const Text('Minha Conta', style: TextStyle(color: VelloTokens.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: VelloTokens.white),
            title: const Text('Sair', style: TextStyle(color: VelloTokens.white)),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sair'),
                  content: const Text('Deseja realmente sair?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Não'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                      },
                      child: const Text('Sim'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
