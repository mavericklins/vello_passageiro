import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';

class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;
  static const Color velloCardBackground = VelloTokens.white;

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
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          'Notificações',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: velloBlue,
        foregroundColor: VelloTokens.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: velloOrange,
          indicatorWeight: 3,
          labelColor: VelloTokens.white,
          unselectedLabelColor: VelloTokens.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: 'Novas'),
            Tab(text: 'Lidas'),
            Tab(text: 'Arquivadas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationTab(
            icon: Icons.notifications_active,
            title: 'Novas Notificações',
            subtitle: 'Você não tem notificações novas no momento',
            color: velloOrange,
          ),
          _buildNotificationTab(
            icon: Icons.mark_email_read_outlined,
            title: 'Notificações Lidas',
            subtitle: 'Suas notificações lidas aparecerão aqui',
            color: const VelloTokens.infoCyan,
          ),
          _buildNotificationTab(
            icon: Icons.archive_outlined,
            title: 'Notificações Arquivadas',
            subtitle: 'Suas notificações arquivadas aparecerão aqui',
            color: const VelloTokens.info,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTab({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 40,
              color: color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: velloBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: velloCardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: VelloTokens.black.withOpacity(0.04),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'As notificações da Vello ajudam você a ficar por dentro de suas corridas e atualizações importantes.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

