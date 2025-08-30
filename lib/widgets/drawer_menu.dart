import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text("Menu"),
          ),
          ListTile(title: Text("Perfil")),
          ListTile(title: Text("Histórico")),
          ListTile(title: Text("Sair")),
        ],
      ),
    );
  }
}
