import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';

class PromocoesScreen extends StatelessWidget {
  const PromocoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.surfaceBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Promoções Ativas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray900,
              ),
            ),
            const SizedBox(height: 16),

            // Promoção principal
            VelloCard.gradient(
              padding: const EdgeInsets.all(20),
              gradient: const LinearGradient(
                colors: [VelloTokens.success, VelloTokens.successLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.local_offer,
                        color: VelloTokens.white,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'OFERTA ESPECIAL',
                        style: TextStyle(
                          color: VelloTokens.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '50% OFF',
                    style: TextStyle(
                      color: VelloTokens.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'na sua próxima viagem',
                    style: TextStyle(
                      color: VelloTokens.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Válido até 31/01/2024',
                          style: TextStyle(
                            color: VelloTokens.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      VelloButton.secondary(
                        text: 'Usar Agora',
                        size: VelloButtonSize.small,
                        backgroundColor: VelloTokens.white,
                        color: VelloTokens.success,
                        onPressed: () {
                          // TODO: Usar promoção
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Lista de cupons
            const Text(
              'Meus Cupons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray900,
              ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final List<Map<String, dynamic>> cupons = [
                  {
                    'code': 'PRIMEIRA10',
                    'title': '10% de desconto',
                    'subtitle': 'Para primeira viagem',
                    'expiry': 'Expira em 15 dias',
                    'color': VelloTokens.brand,
                    'isActive': true,
                  },
                  {
                    'code': 'FIDELIDADE20',
                    'title': '20% de desconto',
                    'subtitle': 'Cliente fidelidade',
                    'expiry': 'Expira em 30 dias',
                    'color': VelloTokens.warning,
                    'isActive': true,
                  },
                  {
                    'code': 'WEEKEND15',
                    'title': '15% de desconto',
                    'subtitle': 'Viagens de fim de semana',
                    'expiry': 'Expira em 7 dias',
                    'color': VelloTokens.info,
                    'isActive': true,
                  },
                  {
                    'code': 'PROMO5',
                    'title': 'R\$ 5,00 OFF',
                    'subtitle': 'Viagem mínima R\$ 20,00',
                    'expiry': 'Expirado',
                    'color': VelloTokens.gray400,
                    'isActive': false,
                  },
                ];

                final cupom = cupons[index];

                return VelloCard.standard(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: cupom['isActive'] ? null : VelloTokens.gray100,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (cupom['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (cupom['color'] as Color).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          cupom['isActive'] ? Icons.local_offer : Icons.local_offer_outlined,
                          color: cupom['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (cupom['color'] as Color).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: (cupom['color'] as Color).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    cupom['code'] as String,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: cupom['color'] as Color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cupom['title'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: cupom['isActive'] ? VelloTokens.gray900 : VelloTokens.gray500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              cupom['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: cupom['isActive'] ? VelloTokens.gray600 : VelloTokens.gray400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cupom['expiry'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: cupom['isActive'] ? VelloTokens.warning : VelloTokens.danger,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (cupom['isActive'])
                        VelloButton.ghost(
                          text: 'Usar',
                          size: VelloButtonSize.small,
                          onPressed: () {
                            // TODO: Usar cupom
                          },
                        ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Inserir código promocional
            VelloCard.outlined(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tem um código promocional?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: VelloTokens.gray900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Digite seu código',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      VelloButton.primary(
                        text: 'Aplicar',
                        size: VelloButtonSize.small,
                        onPressed: () {
                          // TODO: Aplicar código
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}