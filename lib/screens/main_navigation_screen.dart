import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'historico/historico_screen.dart';
import 'pagamentos/pagamentos_screen.dart';
import 'favoritos/favoritos_screen.dart';
import 'promocoes/promocoes_screen.dart';
import 'perfil/perfil_screen.dart';
import 'configuracoes/configuracoes_screen.dart';
import 'suporte/suporte_screen.dart';
import 'wallet/wallet_screen.dart';
import '../theme/vello_tokens.dart';
import '../theme/vello_tokens.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'Usuário';
    
    _screens = [
      HomeScreen(userName: userName),
      const ViagensTabScreen(),
      const PagamentosTabScreen(),
      const MaisTabScreen(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: VelloTokens.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: VelloTokens.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onTabTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Início',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_car_rounded),
                label: 'Viagens',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_rounded),
                label: 'Financeiro',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz_rounded),
                label: 'Mais',
              ),
            ],
            backgroundColor: Colors.transparent,
            selectedItemColor: VelloTokens.brand,
            unselectedItemColor: VelloTokens.gray500,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

// Tab de Viagens
class ViagensTabScreen extends StatelessWidget {
  const ViagensTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: VelloTokens.surfaceBackground,
        appBar: AppBar(
          title: const Text(
            'Minhas Viagens',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: VelloTokens.brand,
          foregroundColor: VelloTokens.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            labelColor: VelloTokens.white,
            unselectedLabelColor: VelloTokens.white70,
            indicatorColor: VelloTokens.white,
            tabs: [
              Tab(text: 'Histórico', icon: Icon(Icons.history_rounded, size: 20)),
              Tab(text: 'Favoritos', icon: Icon(Icons.favorite_rounded, size: 20)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HistoricoScreen(),
            FavoritosScreen(),
          ],
        ),
      ),
    );
  }
}

// Tab de Pagamentos
class PagamentosTabScreen extends StatelessWidget {
  const PagamentosTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: VelloTokens.surfaceBackground,
        appBar: AppBar(
          title: const Text(
            'Financeiro',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: VelloTokens.brand,
          foregroundColor: VelloTokens.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            labelColor: VelloTokens.white,
            unselectedLabelColor: VelloTokens.white70,
            indicatorColor: VelloTokens.white,
            isScrollable: true,
            tabs: [
              Tab(text: 'Métodos', icon: Icon(Icons.credit_card_rounded, size: 20)),
              Tab(text: 'Vello Points', icon: Icon(Icons.stars_rounded, size: 20)),
              Tab(text: 'Promoções', icon: Icon(Icons.local_offer_rounded, size: 20)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PagamentosScreen(),
            WalletScreen(),
            PromocoesScreen(),
          ],
        ),
      ),
    );
  }
}

// Tab "Mais" com menu de funcionalidades
class MaisTabScreen extends StatelessWidget {
  const MaisTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.surfaceBackground,
      appBar: AppBar(
        title: const Text(
          'Mais Opções',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: VelloTokens.brand,
        foregroundColor: VelloTokens.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SEÇÃO CONTA
          _buildSectionCard(
            context: context,
            title: 'Conta',
            icon: Icons.person_rounded,
            children: [
              _buildMenuItem(
                context: context,
                icon: Icons.person_rounded,
                title: 'Meu Perfil',
                subtitle: 'Dados pessoais e informações',
                color: VelloTokens.brand,
                onTap: () => Navigator.pushNamed(context, '/perfil'),
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.flag_rounded,
                title: 'Metas',
                subtitle: 'Acompanhe suas conquistas e objetivos',
                color: VelloTokens.success,
                onTap: () => Navigator.pushNamed(context, '/metas'),
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.analytics_rounded,
                title: 'Estatísticas',
                subtitle: 'Dados sobre seus gastos e viagens',
                color: VelloTokens.info,
                onTap: () => Navigator.pushNamed(context, '/stats'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // SEÇÃO SUPORTE
          _buildSectionCard(
            context: context,
            title: 'Ajuda & Suporte',
            icon: Icons.help_rounded,
            children: [
              _buildMenuItem(
                context: context,
                icon: Icons.support_agent_rounded,
                title: 'Suporte',
                subtitle: 'Central de ajuda e atendimento',
                color: VelloTokens.info,
                onTap: () => Navigator.pushNamed(context, '/suporte'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // SEÇÃO CONFIGURAÇÕES
          _buildSectionCard(
            context: context,
            title: 'Configurações',
            icon: Icons.settings_rounded,
            children: [
              _buildMenuItem(
                context: context,
                icon: Icons.settings_rounded,
                title: 'Configurações',
                subtitle: 'Preferências e configurações do app',
                color: VelloTokens.gray700,
                onTap: () => Navigator.pushNamed(context, '/configuracoes'),
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: VelloTokens.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: VelloTokens.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da seção
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: VelloTokens.brand.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: VelloTokens.brand,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: VelloTokens.brand,
                  ),
                ),
              ],
            ),
          ),

          // Itens da seção
          ...children,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: VelloTokens.brand,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: VelloTokens.gray500,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: VelloTokens.gray500,
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            color: VelloTokens.gray200,
          ),
        if (isLast) const SizedBox(height: 12),
      ],
    );
  }
}