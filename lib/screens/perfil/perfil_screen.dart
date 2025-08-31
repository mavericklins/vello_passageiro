import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/vello_tokens.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../routes/app_routes.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'Usuário';
    final userEmail = user?.email ?? 'email@exemplo.com';

    return Scaffold(
      backgroundColor: VelloTokens.surfaceBackground,
      appBar: AppBar(
        title: const Text(
          'Meu Perfil',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: VelloTokens.brand,
        foregroundColor: VelloTokens.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card do usuário
            VelloCard.standard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: VelloTokens.brand.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: VelloTokens.brand.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: VelloTokens.brand,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: VelloTokens.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      fontSize: 14,
                      color: VelloTokens.gray600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  VelloButton.outlined(
                    text: 'Editar Perfil',
                    onPressed: () {
                      _showEditProfileDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Informações pessoais
            VelloCard.standard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informações Pessoais',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: VelloTokens.brand,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(
                    icon: Icons.phone,
                    label: 'Telefone',
                    value: '(11) 99999-9999',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    icon: Icons.location_city,
                    label: 'Cidade',
                    value: 'São Paulo, SP',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    icon: Icons.cake,
                    label: 'Data de Nascimento',
                    value: '15/03/1990',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Seção de Preferências conforme especificado no prompt
            VelloCard.standard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preferências',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: VelloTokens.brand,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPreferenceItem(
                    context: context,
                    icon: Icons.location_on,
                    title: 'Endereços Favoritos',
                    subtitle: 'Gerencie seus locais favoritos',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.favoriteAddresses);
                    },
                  ),
                  const Divider(),
                  _buildPreferenceItem(
                    context: context,
                    icon: Icons.person,
                    title: 'Motoristas Preferidos',
                    subtitle: 'Seus motoristas de confiança',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.preferredDrivers);
                    },
                  ),
                  const Divider(),
                  _buildPreferenceItem(
                    context: context,
                    icon: Icons.settings,
                    title: 'Preferências de Viagem',
                    subtitle: 'Configure suas preferências',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.travelPreferences);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Estatísticas
            VelloCard.standard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Minhas Estatísticas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: VelloTokens.brand,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.directions_car,
                          label: 'Viagens',
                          value: '127',
                          color: VelloTokens.brand,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.star,
                          label: 'Avaliação',
                          value: '4.9',
                          color: VelloTokens.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.route,
                          label: 'Km Total',
                          value: '2.5k',
                          color: VelloTokens.success,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.savings,
                          label: 'Economia',
                          value: 'R\$ 450',
                          color: VelloTokens.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
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
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: VelloTokens.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: VelloTokens.gray900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: VelloTokens.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Editar Perfil',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: VelloTokens.brand,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Funcionalidade em desenvolvimento.'),
              SizedBox(height: 12),
              Text('Em breve você poderá:'),
              Text('• Alterar foto de perfil'),
              Text('• Editar informações pessoais'),
              Text('• Atualizar dados de contato'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Fechar',
                style: TextStyle(color: VelloTokens.brand),
              ),
            ),
          ],
        );
      },
    );
  }
}

