import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../routes/app_routes.dart';

class PagamentosScreen extends StatelessWidget {
  const PagamentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.surfaceBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Métodos de pagamento
            const Text(
              'Métodos de Pagamento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray900,
              ),
            ),
            const SizedBox(height: 16),

            // Cartão principal
            VelloCard.gradient(
              padding: const EdgeInsets.all(20),
              gradient: const LinearGradient(
                colors: [VelloTokens.brand, VelloTokens.brandLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cartão Principal',
                        style: TextStyle(
                          color: VelloTokens.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.credit_card,
                        color: VelloTokens.white,
                        size: 24,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    '**** **** **** 1234',
                    style: TextStyle(
                      color: VelloTokens.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'João Silva',
                    style: TextStyle(
                      color: VelloTokens.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '12/28',
                    style: TextStyle(
                      color: VelloTokens.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Lista de métodos - Agora com navegação para telas órfãs
            VelloCard.standard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPaymentMethod(
                    context: context,
                    icon: Icons.credit_card,
                    title: 'Cartão de Crédito',
                    subtitle: 'Visa **** 1234',
                    isDefault: true,
                    onTap: () {
                      // Navegar para tela de crédito
                      _showPaymentMethodDialog(context, 'Cartão de Crédito');
                    },
                  ),
                  const Divider(),
                  _buildPaymentMethod(
                    context: context,
                    icon: Icons.account_balance_wallet,
                    title: 'Cartão de Débito',
                    subtitle: 'Mastercard **** 5678',
                    isDefault: false,
                    onTap: () {
                      // Navegar para tela de débito
                      _showPaymentMethodDialog(context, 'Cartão de Débito');
                    },
                  ),
                  const Divider(),
                  _buildPaymentMethod(
                    context: context,
                    icon: Icons.pix,
                    title: 'PIX',
                    subtitle: 'Pagamento instantâneo',
                    isDefault: false,
                    onTap: () {
                      // Navegar para tela de PIX
                      _showPaymentMethodDialog(context, 'PIX');
                    },
                  ),
                  const Divider(),
                  _buildPaymentMethod(
                    context: context,
                    icon: Icons.money,
                    title: 'Dinheiro',
                    subtitle: 'Pagamento em espécie',
                    isDefault: false,
                    onTap: () {
                      // Navegar para tela de dinheiro
                      _showPaymentMethodDialog(context, 'Dinheiro');
                    },
                  ),
                  const Divider(),
                  _buildPaymentMethod(
                    context: context,
                    icon: Icons.account_balance_wallet,
                    title: 'Carteira Digital',
                    subtitle: 'Saldo disponível: R\$ 50,00',
                    isDefault: false,
                    onTap: () {
                      // Navegar para tela de carteira digital
                      _showPaymentMethodDialog(context, 'Carteira Digital');
                    },
                  ),
                  const Divider(),
                  _buildPaymentMethod(
                    context: context,
                    icon: Icons.stars,
                    title: 'Vello Points',
                    subtitle: '1.250 pontos disponíveis',
                    isDefault: false,
                    onTap: () {
                      // Navegar para tela de Vello Points
                      _showPaymentMethodDialog(context, 'Vello Points');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Botão adicionar método
            VelloButton.outlined(
              text: 'Adicionar Método de Pagamento',
              icon: Icons.add,
              isFullWidth: true,
              onPressed: () {
                _showAddPaymentMethodDialog(context);
              },
            ),

            const SizedBox(height: 20),

            // Histórico financeiro
            const Text(
              'Histórico Financeiro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray900,
              ),
            ),
            const SizedBox(height: 12),

            VelloCard.standard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTransactionItem(
                    icon: Icons.directions_car,
                    title: 'Viagem para Shopping Center',
                    subtitle: '15/01/2024 - 14:30',
                    amount: 'R\$ 15,50',
                    isPositive: false,
                  ),
                  const Divider(),
                  _buildTransactionItem(
                    icon: Icons.local_offer,
                    title: 'Desconto Primeira Viagem',
                    subtitle: '15/01/2024 - 14:30',
                    amount: 'R\$ 5,00',
                    isPositive: true,
                  ),
                  const Divider(),
                  _buildTransactionItem(
                    icon: Icons.directions_car,
                    title: 'Viagem para Aeroporto',
                    subtitle: '14/01/2024 - 08:15',
                    amount: 'R\$ 32,80',
                    isPositive: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDefault,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: VelloTokens.gray900,
                    ),
                  ),
                  const SizedBox(height: 2),
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
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: VelloTokens.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: VelloTokens.success.withOpacity(0.3),
                  ),
                ),
                child: const Text(
                  'Padrão',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: VelloTokens.success,
                  ),
                ),
              ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: VelloTokens.gray500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required bool isPositive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isPositive ? VelloTokens.success : VelloTokens.gray400).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isPositive ? VelloTokens.success : VelloTokens.gray600,
              size: 20,
            ),
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
                    fontWeight: FontWeight.w600,
                    color: VelloTokens.gray900,
                  ),
                ),
                const SizedBox(height: 2),
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
          Text(
            '${isPositive ? '+' : '-'} $amount',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isPositive ? VelloTokens.success : VelloTokens.gray900,
            ),
          ),
        ],
      ),
    );
  }

  // Diálogos para simular as telas de pagamento órfãs
  void _showPaymentMethodDialog(BuildContext context, String paymentType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            paymentType,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: VelloTokens.brand,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configurações para $paymentType'),
              const SizedBox(height: 16),
              if (paymentType == 'PIX') ...[
                const Text('• Pagamento instantâneo'),
                const Text('• Sem taxas adicionais'),
                const Text('• Disponível 24h'),
              ] else if (paymentType == 'Carteira Digital') ...[
                const Text('• Saldo atual: R\$ 50,00'),
                const Text('• Recarregue sua carteira'),
                const Text('• Pagamentos rápidos'),
              ] else if (paymentType == 'Vello Points') ...[
                const Text('• 1.250 pontos disponíveis'),
                const Text('• 1 ponto = R\$ 0,01'),
                const Text('• Ganhe pontos a cada viagem'),
              ] else if (paymentType == 'Dinheiro') ...[
                const Text('• Pagamento em espécie'),
                const Text('• Tenha o valor exato'),
                const Text('• Confirme com o motorista'),
              ] else ...[
                const Text('• Cartão seguro e confiável'),
                const Text('• Pagamento automático'),
                const Text('• Histórico de transações'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Fechar',
                style: TextStyle(color: VelloTokens.gray600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$paymentType configurado como padrão!'),
                    backgroundColor: VelloTokens.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: VelloTokens.brand,
                foregroundColor: VelloTokens.white,
              ),
              child: const Text('Definir como Padrão'),
            ),
          ],
        );
      },
    );
  }

  void _showAddPaymentMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Adicionar Método de Pagamento',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: VelloTokens.brand,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.credit_card, color: VelloTokens.brand),
                title: const Text('Cartão de Crédito'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showPaymentMethodDialog(context, 'Cartão de Crédito');
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: VelloTokens.brand),
                title: const Text('Cartão de Débito'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showPaymentMethodDialog(context, 'Cartão de Débito');
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance, color: VelloTokens.brand),
                title: const Text('Conta Bancária'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidade em desenvolvimento'),
                      backgroundColor: VelloTokens.warning,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: VelloTokens.gray600),
              ),
            ),
          ],
        );
      },
    );
  }
}

