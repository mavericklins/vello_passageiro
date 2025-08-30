import 'package:flutter/material.dart';

class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Novas'),
            Tab(text: 'Lidas'),
            Tab(text: 'Arquivadas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(child: Text('Conteúdo das Novas Notificações')),
          Center(child: Text('Conteúdo das Notificações Lidas')),
          Center(child: Text('Conteúdo das Notificações Arquivadas')),
        ],
      ),
    );
  }
}


