import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';

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

            // Lista de métodos
            VelloCard.standard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPaymentMethod(
                    icon: Icons.credit_card,
                    title: 'Cartão de Crédito',
                    subtitle: 'Visa **** 1234',
                    isDefault: true,
                  ),
                  const Divider(),
                  _buildPaymentMethod(
                    icon: Icons.account_balance,
                    title: 'Conta Bancária',
                    subtitle: 'Banco do Brasil',
                    isDefault: false,
                  ),
                  const Divider(),
                  _buildPaymentMethod(
                    icon: Icons.pix,
                    title: 'PIX',
                    subtitle: 'Pagamento instantâneo',
                    isDefault: false,
                  ),
                  const Divider(),
                  _buildPaymentMethod(
                    icon: Icons.money,
                    title: 'Dinheiro',
                    subtitle: 'Pagamento em espécie',
                    isDefault: false,
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
                // TODO: Implementar adição de método
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
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDefault,
  }) {
    return Padding(
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
        ],
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
}