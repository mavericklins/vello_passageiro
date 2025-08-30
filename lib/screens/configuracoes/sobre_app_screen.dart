import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';

class SobreAppScreen extends StatelessWidget {
  const SobreAppScreen({super.key});

  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;
  static const Color velloCardBackground = VelloTokens.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          'Sobre o Aplicativo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: velloBlue,
        foregroundColor: VelloTokens.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com logo e título
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: velloCardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: VelloTokens.black.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: velloOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      size: 40,
                      color: velloOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Vello Mobilidade',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: velloBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Conectando pessoas, transformando cidades',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Seção Sobre
            _buildSection(
              title: 'Nossa História',
              icon: Icons.history,
              iconColor: const VelloTokens.infoCyan,
              content: 'Bem-vindo ao Vello Mobilidade! Nascemos da necessidade de revolucionar o transporte urbano no Brasil. Nossa plataforma foi desenvolvida com tecnologia de ponta para oferecer uma experiência de mobilidade eficiente, segura e sustentável.\n\nConectamos passageiros a motoristas parceiros de forma inteligente e intuitiva, garantindo que você chegue ao seu destino com máxima tranquilidade e conforto.',
            ),

            _buildSection(
              title: 'Nossa Missão',
              icon: Icons.flag,
              iconColor: velloOrange,
              content: 'Transformar a mobilidade urbana brasileira, proporcionando liberdade, flexibilidade e oportunidades para motoristas e passageiros. Acreditamos que a tecnologia pode simplificar o dia a dia das pessoas e criar um ecossistema de transporte mais justo e eficiente para todos.',
            ),

            _buildSection(
              title: 'Nossos Valores',
              icon: Icons.favorite,
              iconColor: const VelloTokens.success,
              content: '• Segurança em primeiro lugar\n• Transparência em todas as operações\n• Inovação constante\n• Respeito e inclusão\n• Sustentabilidade ambiental\n• Compromisso com a comunidade',
            ),

            _buildSection(
              title: 'O que oferecemos',
              icon: Icons.star,
              iconColor: const VelloTokens.info,
              content: '• Viagens seguras com monitoramento em tempo real\n• Motoristas parceiros verificados e qualificados\n• Preços justos e transparentes\n• Múltiplas opções de pagamento (PIX, cartão, dinheiro)\n• Sistema de avaliação bidirecional\n• Suporte 24/7 dedicado ao usuário\n• Tecnologia de geolocalização precisa\n• Histórico completo de viagens',
            ),

            _buildSection(
              title: 'Tecnologia e Inovação',
              icon: Icons.phone_android,
              iconColor: const VelloTokens.infoDark,
              content: 'Utilizamos as mais avançadas tecnologias de desenvolvimento mobile e inteligência artificial para garantir:\n\n• Interface intuitiva e responsiva\n• Algoritmos de otimização de rotas\n• Sistema de matching inteligente\n• Segurança de dados com criptografia\n• Atualizações constantes baseadas no feedback dos usuários',
            ),

            _buildSection(
              title: 'Compromisso Social',
              icon: Icons.people,
              iconColor: const VelloTokens.success,
              content: 'A Vello Mobilidade está comprometida com o desenvolvimento social e econômico das comunidades onde atua. Geramos oportunidades de renda para milhares de motoristas parceiros e contribuímos para a redução do trânsito urbano através do compartilhamento inteligente de viagens.',
            ),

            // Informações técnicas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: velloCardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: VelloTokens.black.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: velloOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: velloOrange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Informações Técnicas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: velloBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Versão do Aplicativo:', '2.1.0'),
                  _buildInfoRow('Última Atualização:', 'Janeiro 2025'),
                  _buildInfoRow('Desenvolvido por:', 'Equipe Vello Mobilidade'),
                  _buildInfoRow('Suporte:', 'contato@vellomobilidade.com.br'),
                  _buildInfoRow('WhatsApp:', '+55 (14) 96000-0471'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [velloBlue, velloBlue.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Obrigado por escolher a Vello!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: VelloTokens.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estamos constantemente trabalhando para melhorar sua experiência. Sua opinião é fundamental para nosso crescimento!',
                    style: TextStyle(
                      fontSize: 14,
                      color: VelloTokens.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: velloCardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: VelloTokens.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: velloBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: velloBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

