import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';
import '../../widgets/common/vello_card.dart';

class HistoricoScreen extends StatelessWidget {
  const HistoricoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.surfaceBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text(
              'Histórico de Viagens',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: VelloTokens.brand,
            foregroundColor: VelloTokens.white,
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: VelloCard.standard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: VelloTokens.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Viagem Concluída',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const Text(
                                'R\$ 15,50',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: VelloTokens.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            children: [
                              Icon(Icons.location_on, color: VelloTokens.brand, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Rua das Flores, 123 → Shopping Center',
                                  style: TextStyle(
                                    color: VelloTokens.gray600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(Icons.access_time, color: VelloTokens.gray500, size: 16),
                              SizedBox(width: 8),
                              Text(
                                '15 min • 5,2 km',
                                style: TextStyle(
                                  color: VelloTokens.gray500,
                                  fontSize: 12,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '15/01/2024 - 14:30',
                                style: TextStyle(
                                  color: VelloTokens.gray500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}