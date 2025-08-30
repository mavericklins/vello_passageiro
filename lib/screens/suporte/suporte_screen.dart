import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';

class SuporteScreen extends StatelessWidget {
  const SuporteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.surfaceBackground,
      appBar: AppBar(
        title: const Text(
          'Central de Ajuda',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: VelloTokens.brand,
        foregroundColor: VelloTokens.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contatos rápidos
            const Text(
              'Contato Rápido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray900,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: VelloCard.standard(
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      // TODO: Implementar chat
                    },
                    child: const Column(
                      children: [
                        Icon(
                          Icons.chat_bubble,
                          color: VelloTokens.brand,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Chat',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Atendimento online',
                          style: TextStyle(
                            fontSize: 12,
                            color: VelloTokens.gray600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VelloCard.standard(
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      // TODO: Implementar ligação
                    },
                    child: const Column(
                      children: [
                        Icon(
                          Icons.phone,
                          color: VelloTokens.success,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ligar',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '0800 123 4567',
                          style: TextStyle(
                            fontSize: 12,
                            color: VelloTokens.gray600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VelloCard.standard(
                    padding: const EdgeInsets.all(16),
                    onTap: () {
                      // TODO: Implementar WhatsApp
                    },
                    child: const Column(
                      children: [
                        Icon(
                          Icons.message,
                          color: VelloTokens.success,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'WhatsApp',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Mensagem rápida',
                          style: TextStyle(
                            fontSize: 12,
                            color: VelloTokens.gray600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // FAQ
            const Text(
              'Perguntas Frequentes',
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
                  _buildFaqItem(
                    question: 'Como solicitar uma corrida?',
                    answer: 'Abra o app, defina seu destino e toque em "Solicitar Corrida".',
                  ),
                  const Divider(),
                  _buildFaqItem(
                    question: 'Como cancelar uma viagem?',
                    answer: 'Você pode cancelar através do botão "Cancelar" na tela de busca.',
                  ),
                  const Divider(),
                  _buildFaqItem(
                    question: 'Métodos de pagamento aceitos?',
                    answer: 'Aceitamos cartões de crédito, débito, PIX e dinheiro.',
                  ),
                  const Divider(),
                  _buildFaqItem(
                    question: 'Como avaliar o motorista?',
                    answer: 'Ao final da viagem, você pode dar uma nota de 1 a 5 estrelas.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Reportar problema
            const Text(
              'Reportar Problema',
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
                  _buildReportItem(
                    icon: Icons.error,
                    title: 'Problema com a Viagem',
                    subtitle: 'Motorista não chegou, cobrança incorreta, etc.',
                    color: VelloTokens.danger,
                    onTap: () {
                      // TODO: Reportar problema viagem
                    },
                  ),
                  const Divider(),
                  _buildReportItem(
                    icon: Icons.bug_report,
                    title: 'Problema no App',
                    subtitle: 'Erro técnico, travamento, funcionalidade',
                    color: VelloTokens.warning,
                    onTap: () {
                      // TODO: Reportar problema app
                    },
                  ),
                  const Divider(),
                  _buildReportItem(
                    icon: Icons.feedback,
                    title: 'Sugestão',
                    subtitle: 'Envie sua ideia para melhorar o app',
                    color: VelloTokens.info,
                    onTap: () {
                      // TODO: Enviar sugestão
                    },
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

  Widget _buildFaqItem({
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: VelloTokens.gray900,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            answer,
            style: const TextStyle(
              fontSize: 14,
              color: VelloTokens.gray600,
              height: 1.4,
            ),
          ),
        ),
      ],
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
    );
  }

  Widget _buildReportItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
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
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: VelloTokens.gray900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: VelloTokens.gray600,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: VelloTokens.gray500,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}