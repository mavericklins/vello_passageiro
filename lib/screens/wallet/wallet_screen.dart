import 'package:flutter/material.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../theme/vello_tokens.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Dados simulados - adaptado para passageiro
  final double _saldoVelloPoints = 1250.0;
  final int _corridasEstesMes = 18;
  final String _metaEconomia = "R\$ 500";
  final double _progressoMeta = 0.72;
  final double _cashbackTotal = 85.40;

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
      backgroundColor: VelloTokens.gray50,
      appBar: AppBar(
        title: const Text(
          'Vello Points',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: VelloTokens.white,
          ),
        ),
        backgroundColor: VelloTokens.brand,
        foregroundColor: VelloTokens.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/historico'),
            tooltip: 'Histórico',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/configuracoes'),
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderCard(),
          _buildTabsSection(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPointsTab(),
                _buildCarteiraTab(),
                _buildMetasTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: VelloCard.gradient(
        gradient: const LinearGradient(
          colors: [VelloTokens.brand, VelloTokens.brandLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saldo Vello Points',
                        style: TextStyle(
                          color: VelloTokens.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_saldoVelloPoints.toStringAsFixed(0)} pts',
                        style: const TextStyle(
                          color: VelloTokens.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: VelloTokens.white.withOpacity(0.2),
                      borderRadius: VelloTokens.radiusMedium,
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: VelloTokens.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Corridas Mês',
                      '$_corridasEstesMes',
                      Icons.directions_car,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      'Meta Economia',
                      _metaEconomia,
                      Icons.savings,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VelloTokens.white.withOpacity(0.15),
        borderRadius: VelloTokens.radiusMedium,
        border: Border.all(
          color: VelloTokens.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: VelloTokens.white,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: VelloTokens.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: VelloTokens.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: VelloCard(
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: VelloTokens.brand,
            borderRadius: VelloTokens.radiusMedium,
          ),
          labelColor: VelloTokens.white,
          unselectedLabelColor: VelloTokens.gray600,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Points'),
            Tab(text: 'Carteira'),
            Tab(text: 'Metas'),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCashbackCard(),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 24),
          _buildTransacoesList(),
        ],
      ),
    );
  }

  Widget _buildCarteiraTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSaldoCard(),
          const SizedBox(height: 16),
          _buildBeneficiosPoints(),
          const SizedBox(height: 16),
          _buildResgateOptions(),
        ],
      ),
    );
  }

  Widget _buildMetasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMetaEconomiaCard(),
          const SizedBox(height: 16),
          _buildMetasSemana(),
        ],
      ),
    );
  }

  Widget _buildCashbackCard() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: VelloTokens.success.withOpacity(0.1),
                    borderRadius: VelloTokens.radiusMedium,
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: VelloTokens.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cashback Este Mês',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: VelloTokens.gray600,
                        ),
                      ),
                      Text(
                        '$_corridasEstesMes corridas realizadas',
                        style: const TextStyle(
                          fontSize: 12,
                          color: VelloTokens.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'R\$ ${_cashbackTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: VelloTokens.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: VelloButton.icon(
            onPressed: () => _showResgateDialog(),
            icon: Icons.redeem,
            text: 'Resgatar',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: VelloButton.icon(
            onPressed: () => _showTransferirDialog(),
            icon: Icons.send,
            text: 'Transferir',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: VelloButton.icon(
            onPressed: () => _showExtratoDialog(),
            icon: Icons.receipt_long,
            text: 'Extrato',
          ),
        ),
      ],
    );
  }

  Widget _buildSaldoCard() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Saldo Disponível',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: VelloTokens.gray600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_saldoVelloPoints.toStringAsFixed(0)} Vello Points',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: VelloTokens.gray800,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VelloTokens.gray50,
                borderRadius: VelloTokens.radiusMedium,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Seus pontos nunca expiram e podem ser trocados por descontos em viagens',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: VelloTokens.gray600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeneficiosPoints() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Como Ganhar Points',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray800,
              ),
            ),
            const SizedBox(height: 16),
            _buildBeneficioItem(
              'Viagens Completadas',
              'Ganhe 50 points por viagem',
              Icons.directions_car,
              VelloTokens.brand,
            ),
            const SizedBox(width: 12),
            _buildBeneficioItem(
              'Avaliações 5 Estrelas',
              'Bônus de 20 points extras',
              Icons.star,
              VelloTokens.warning,
            ),
            const SizedBox(width: 12),
            _buildBeneficioItem(
              'Indicações de Amigos',
              'Ganhe 200 points por indicação',
              Icons.group_add,
              VelloTokens.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeneficioItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: VelloTokens.radiusMedium,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: VelloTokens.radiusSmall,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: VelloTokens.gray600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: VelloTokens.gray400,
          ),
        ],
      ),
    );
  }

  Widget _buildResgateOptions() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resgate Rápido',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickRedeemButton('R\$ 10', '500 pts'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickRedeemButton('R\$ 25', '1000 pts'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickRedeemButton('R\$ 50', '2000 pts'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickRedeemButton(String value, String points) {
    return VelloButton(
      text: '$value\n$points',
      onPressed: () => _showResgateDialog(),
      type: VelloButtonType.secondary,
      size: VelloButtonSize.small,
    );
  }

  Widget _buildMetaEconomiaCard() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Meta de Economia Mensal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: VelloTokens.gray800,
                  ),
                ),
                Text(
                  '${(_progressoMeta * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: VelloTokens.brand,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _metaEconomia,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: VelloTokens.gray800,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: VelloTokens.radiusSmall,
              child: LinearProgressIndicator(
                value: _progressoMeta,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(VelloTokens.brand),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'R\$ ${(500 * _progressoMeta).toStringAsFixed(0)} de R\$ 500',
              style: const TextStyle(
                fontSize: 12,
                color: VelloTokens.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetasSemana() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metas da Semana',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray800,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetaItem('5 Viagens', 3, 5),
            const SizedBox(height: 12),
            _buildMetaItem('250 Vello Points', 180, 250),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(String title, double atual, double meta) {
    final progress = (atual / meta).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: VelloTokens.gray700,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: progress >= 1.0 ? VelloTokens.success : VelloTokens.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: VelloTokens.radiusSmall,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? VelloTokens.success : VelloTokens.warning
            ),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${atual.toStringAsFixed(0)} de ${meta.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 12,
            color: VelloTokens.gray500,
          ),
        ),
      ],
    );
  }

  Widget _buildTransacoesList() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Últimas Transações',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray800,
              ),
            ),
            const SizedBox(height: 16),
            _buildTransactionItem(
              'Viagem Centro - Shopping',
              'Hoje às 14:30',
              '+ 50 pts',
              VelloTokens.success,
              Icons.directions_car,
            ),
            const SizedBox(height: 12),
            _buildTransactionItem(
              'Avaliação 5 Estrelas',
              'Hoje às 14:35',
              '+ 20 pts',
              VelloTokens.success,
              Icons.star,
            ),
            const SizedBox(height: 12),
            _buildTransactionItem(
              'Desconto Aplicado',
              'Ontem às 18:00',
              '- 100 pts',
              VelloTokens.danger,
              Icons.redeem,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String title, String subtitle, String value, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: VelloTokens.radiusSmall,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: VelloTokens.gray800,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: VelloTokens.gray500,
                ),
              ),
            ],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showResgateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: const Text('Resgatar Points'),
        content: const Text('Escolha como deseja resgatar seus Vello Points.'),
        actions: [
          VelloButton(
            text: 'Entendi',
            onPressed: () => Navigator.pop(context),
            type: VelloButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _showTransferirDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: const Text('Transferir Points'),
        content: const Text('Transfira seus Vello Points para amigos.'),
        actions: [
          VelloButton(
            text: 'Entendi',
            onPressed: () => Navigator.pop(context),
            type: VelloButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _showExtratoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: const Text('Extrato Detalhado'),
        content: const Text('Veja seu histórico completo de Vello Points.'),
        actions: [
          VelloButton(
            text: 'Entendi',
            onPressed: () => Navigator.pop(context),
            type: VelloButtonType.primary,
          ),
        ],
      ),
    );
  }
}