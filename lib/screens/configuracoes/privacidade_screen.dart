import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';

class PrivacidadeScreen extends StatelessWidget {
  const PrivacidadeScreen({super.key});

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
          'Privacidade',
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
            // Header
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
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const VelloTokens.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.privacy_tip,
                      size: 32,
                      color: VelloTokens.success,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Política de Privacidade',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: velloBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vello Mobilidade - Atualizada em Janeiro de 2025',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSection(
              title: 'Compromisso com sua Privacidade',
              icon: Icons.security,
              iconColor: const VelloTokens.success,
              content: 'A Vello Mobilidade está comprometida em proteger e respeitar sua privacidade. Esta Política de Privacidade explica como coletamos, usamos, armazenamos e protegemos suas informações pessoais quando você utiliza nosso aplicativo e serviços.\n\nNós valorizamos a confiança que você deposita em nós e nos esforçamos para ser transparentes sobre nossas práticas de dados. Esta política se aplica a todos os usuários da plataforma Vello, incluindo passageiros e motoristas parceiros.',
            ),

            _buildSection(
              title: 'Informações que Coletamos',
              icon: Icons.info_outline,
              iconColor: const VelloTokens.infoCyan,
              content: 'Para fornecer nossos serviços de mobilidade, coletamos diferentes tipos de informações:\n\n• Informações de Conta: Nome, e-mail, telefone, CPF e foto de perfil\n• Informações de Localização: Dados de GPS para facilitar corridas e navegação\n• Informações de Pagamento: Dados de cartões de crédito/débito (criptografados)\n• Informações de Viagem: Histórico de corridas, rotas, avaliações\n• Informações do Dispositivo: Modelo, sistema operacional, identificadores únicos\n• Informações de Uso: Como você interage com nosso aplicativo\n\nColetamos essas informações apenas quando necessário para fornecer nossos serviços e sempre com seu consentimento explícito.',
            ),

            _buildSection(
              title: 'Como Utilizamos suas Informações',
              icon: Icons.settings,
              iconColor: velloOrange,
              content: 'Utilizamos suas informações pessoais para:\n\n• Facilitar e processar suas viagens\n• Conectar passageiros e motoristas\n• Processar pagamentos de forma segura\n• Fornecer suporte ao cliente personalizado\n• Melhorar nossos serviços e experiência do usuário\n• Enviar notificações importantes sobre suas viagens\n• Garantir a segurança e prevenir fraudes\n• Cumprir obrigações legais e regulamentares\n• Realizar análises para otimizar nossas operações\n\nNunca vendemos suas informações pessoais para terceiros. Todos os usos são estritamente relacionados à prestação de nossos serviços de mobilidade.',
            ),

            _buildSection(
              title: 'Compartilhamento de Informações',
              icon: Icons.share,
              iconColor: const VelloTokens.info,
              content: 'Compartilhamos informações limitadas apenas quando necessário:\n\n• Com Motoristas Parceiros: Nome e localização para facilitar a corrida\n• Com Processadores de Pagamento: Dados necessários para transações seguras\n• Com Autoridades Legais: Quando exigido por lei ou ordem judicial\n• Com Prestadores de Serviços: Empresas que nos ajudam a operar (sempre com contratos de confidencialidade)\n• Em Emergências: Para proteger a segurança dos usuários\n\nTodos os parceiros e prestadores de serviços são rigorosamente selecionados e devem seguir nossos padrões de proteção de dados.',
            ),

            _buildSection(
              title: 'Proteção e Segurança dos Dados',
              icon: Icons.lock,
              iconColor: const VelloTokens.infoDark,
              content: 'Implementamos medidas de segurança robustas para proteger suas informações:\n\n• Criptografia de ponta a ponta para dados sensíveis\n• Servidores seguros com certificações internacionais\n• Acesso restrito aos dados por funcionários autorizados\n• Monitoramento contínuo contra ameaças cibernéticas\n• Backups seguros e redundantes\n• Auditorias regulares de segurança\n• Conformidade com LGPD e padrões internacionais\n\nSeus dados de pagamento são processados através de gateways certificados PCI DSS, garantindo máxima segurança nas transações.',
            ),

            _buildSection(
              title: 'Seus Direitos e Controles',
              icon: Icons.account_circle,
              iconColor: const VelloTokens.success,
              content: 'Você tem controle total sobre suas informações pessoais:\n\n• Acesso: Visualizar todos os dados que temos sobre você\n• Correção: Atualizar informações incorretas ou desatualizadas\n• Exclusão: Solicitar a remoção de seus dados pessoais\n• Portabilidade: Receber uma cópia de seus dados em formato estruturado\n• Limitação: Restringir o processamento de certas informações\n• Oposição: Opor-se ao processamento para fins específicos\n• Revogação: Retirar consentimento a qualquer momento\n\nPara exercer esses direitos, entre em contato conosco através dos canais oficiais. Responderemos em até 15 dias úteis.',
            ),

            _buildSection(
              title: 'Retenção de Dados',
              icon: Icons.schedule,
              iconColor: const VelloTokens.infoCyan,
              content: 'Mantemos suas informações apenas pelo tempo necessário:\n\n• Dados de Conta: Enquanto sua conta estiver ativa\n• Histórico de Viagens: Por 5 anos para fins fiscais e de segurança\n• Dados de Pagamento: Conforme exigências regulamentares\n• Dados de Localização: Excluídos após 30 dias da viagem\n• Logs de Sistema: Mantidos por 12 meses para segurança\n\nApós os períodos de retenção, os dados são permanentemente excluídos de nossos sistemas, exceto quando a manutenção for exigida por lei.',
            ),

            _buildSection(
              title: 'Cookies e Tecnologias Similares',
              icon: Icons.cookie,
              iconColor: velloOrange,
              content: 'Utilizamos cookies e tecnologias similares para:\n\n• Manter você conectado ao aplicativo\n• Lembrar suas preferências e configurações\n• Analisar o uso do aplicativo para melhorias\n• Personalizar sua experiência\n• Detectar e prevenir fraudes\n\nVocê pode gerenciar as configurações de cookies através das configurações do seu dispositivo. Note que desabilitar cookies pode afetar algumas funcionalidades do aplicativo.',
            ),

            _buildSection(
              title: 'Transferências Internacionais',
              icon: Icons.public,
              iconColor: const VelloTokens.info,
              content: 'Seus dados são processados principalmente no Brasil. Em casos específicos, podemos transferir dados para outros países para:\n\n• Processamento de pagamentos internacionais\n• Serviços de nuvem com padrões de segurança elevados\n• Suporte técnico especializado\n\nTodas as transferências seguem as diretrizes da LGPD e incluem salvaguardas adequadas para proteger suas informações.',
            ),

            _buildSection(
              title: 'Menores de Idade',
              icon: Icons.child_care,
              iconColor: const VelloTokens.success,
              content: 'Nossos serviços são destinados a usuários maiores de 18 anos. Não coletamos intencionalmente informações de menores de idade. Se descobrirmos que coletamos dados de um menor, tomaremos medidas imediatas para excluir essas informações.\n\nPais e responsáveis devem supervisionar o uso de dispositivos por menores e entrar em contato conosco se suspeitarem de uso não autorizado.',
            ),

            _buildSection(
              title: 'Atualizações desta Política',
              icon: Icons.update,
              iconColor: const VelloTokens.infoDark,
              content: 'Esta Política de Privacidade pode ser atualizada periodicamente para refletir mudanças em nossos serviços ou na legislação. Quando fizermos alterações significativas:\n\n• Notificaremos você através do aplicativo\n• Enviaremos um e-mail para sua conta registrada\n• Publicaremos a nova versão com destaque\n• Manteremos versões anteriores disponíveis para consulta\n\nO uso continuado de nossos serviços após as alterações constitui aceitação da nova política.',
            ),

            // Contato
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
                  const Icon(
                    Icons.contact_support,
                    size: 32,
                    color: VelloTokens.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Dúvidas sobre Privacidade?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: VelloTokens.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entre em contato com nosso Encarregado de Proteção de Dados:',
                    style: TextStyle(
                      fontSize: 14,
                      color: VelloTokens.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'E-mail: privacidade@vellomobilidade.com.br\nTelefone: +55 (14) 96000-0471',
                    style: TextStyle(
                      fontSize: 14,
                      color: VelloTokens.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: velloCardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    'Última atualização: Janeiro de 2025',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vello Mobilidade - Todos os direitos reservados',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: velloBlue,
                  ),
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
}

