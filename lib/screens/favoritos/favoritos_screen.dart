import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';

class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

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
              'Lugares Favoritos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray900,
              ),
            ),
            const SizedBox(height: 16),

            // Lista de favoritos
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final List<Map<String, dynamic>> favoritos = [
                  {
                    'icon': Icons.home,
                    'title': 'Casa',
                    'address': 'Rua das Flores, 123 - Centro',
                    'color': VelloTokens.success,
                  },
                  {
                    'icon': Icons.work,
                    'title': 'Trabalho',
                    'address': 'Av. Paulista, 456 - Bela Vista',
                    'color': VelloTokens.brand,
                  },
                  {
                    'icon': Icons.local_hospital,
                    'title': 'Hospital',
                    'address': 'Rua da Saúde, 789 - Vila Mariana',
                    'color': VelloTokens.danger,
                  },
                  {
                    'icon': Icons.shopping_cart,
                    'title': 'Shopping Center',
                    'address': 'Av. das Nações, 321 - Moema',
                    'color': VelloTokens.warning,
                  },
                  {
                    'icon': Icons.school,
                    'title': 'Universidade',
                    'address': 'Rua do Conhecimento, 654 - Cidade Universitária',
                    'color': VelloTokens.info,
                  },
                ];

                final favorito = favoritos[index];

                return VelloCard.standard(
                  padding: const EdgeInsets.all(16),
                  onTap: () {
                    // TODO: Ação ao tocar no favorito
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (favorito['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (favorito['color'] as Color).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          favorito['icon'] as IconData,
                          color: favorito['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              favorito['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: VelloTokens.gray900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              favorito['address'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                color: VelloTokens.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          // TODO: Implementar ações do menu
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'editar',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'remover',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: VelloTokens.danger),
                                SizedBox(width: 8),
                                Text('Remover', style: TextStyle(color: VelloTokens.danger)),
                              ],
                            ),
                          ),
                        ],
                        child: const Icon(
                          Icons.more_vert,
                          color: VelloTokens.gray500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Botão adicionar favorito
            VelloButton.outlined(
              text: 'Adicionar Lugar Favorito',
              icon: Icons.add_location,
              isFullWidth: true,
              onPressed: () {
                // TODO: Implementar adição de favorito
              },
            ),
          ],
        ),
      ),
    );
  }
}