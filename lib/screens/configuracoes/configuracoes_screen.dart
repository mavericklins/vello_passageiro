import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';
import '../../widgets/common/vello_card.dart';
import '../../routes/app_routes.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  bool notificacoesAtivas = true;
  bool localizacaoAtiva = true;
  bool modoEscuro = false;
  bool vibracaoAtiva = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.surfaceBackground,
      appBar: AppBar(
        title: const Text(
          'Configurações',
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
            // Preferências
            _buildSectionCard(
              title: 'Preferências',
              icon: Icons.settings,
              children: [
                _buildSwitchItem(
                  icon: Icons.notifications,
                  title: 'Notificações',
                  subtitle: 'Receber notificações do app',
                  value: notificacoesAtivas,
                  onChanged: (value) {
                    setState(() {
                      notificacoesAtivas = value;
                    });
                  },
                ),
                const Divider(),
                _buildSwitchItem(
                  icon: Icons.location_on,
                  title: 'Localização',
                  subtitle: 'Permitir acesso à localização',
                  value: localizacaoAtiva,
                  onChanged: (value) {
                    setState(() {
                      localizacaoAtiva = value;
                    });
                  },
                ),
                const Divider(),
                _buildSwitchItem(
                  icon: Icons.dark_mode,
                  title: 'Modo Escuro',
                  subtitle: 'Tema escuro para economia de bateria',
                  value: modoEscuro,
                  onChanged: (value) {
                    setState(() {
                      modoEscuro = value;
                    });
                  },
                ),
                const Divider(),
                _buildSwitchItem(
                  icon: Icons.vibration,
                  title: 'Vibração',
                  subtitle: 'Feedback tátil nas interações',
                  value: vibracaoAtiva,
                  onChanged: (value) {
                    setState(() {
                      vibracaoAtiva = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Conta e Segurança
            _buildSectionCard(
              title: 'Conta e Segurança',
              icon: Icons.security,
              children: [
                _buildMenuItem(
                  icon: Icons.lock,
                  title: 'Alterar Senha',
                  subtitle: 'Modificar senha de acesso',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.alterarSenha);
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  icon: Icons.phone,
                  title: 'Telefone de Segurança',
                  subtitle: 'Contato de emergência',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.emergencyContacts);
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  icon: Icons.privacy_tip,
                  title: 'Privacidade',
                  subtitle: 'Configurações de privacidade',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.privacidade);
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Informações
            _buildSectionCard(
              title: 'Informações',
              icon: Icons.info,
              children: [
                _buildMenuItem(
                  icon: Icons.help,
                  title: 'Ajuda',
                  subtitle: 'FAQ e central de ajuda',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.suporte);
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  icon: Icons.description,
                  title: 'Termos de Uso',
                  subtitle: 'Termos e condições',
                  onTap: () {
                    _showTermsDialog(context);
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  icon: Icons.policy,
                  title: 'Política de Privacidade',
                  subtitle: 'Como tratamos seus dados',
                  onTap: () {
                    _showPrivacyDialog(context);
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  icon: Icons.info_outline,
                  title: 'Sobre o App',
                  subtitle: 'Versão 1.0.0',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.sobreApp);
                  },
                  isLast: true,
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return VelloCard.standard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da seção
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: VelloTokens.brand,
                  ),
                ),
              ],
            ),
          ),

          // Itens da seção
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: VelloTokens.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: VelloTokens.gray600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: VelloTokens.brand,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
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
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: VelloTokens.gray900,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: VelloTokens.gray600,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: VelloTokens.gray500,
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        ),
        if (isLast) const SizedBox(height: 12),
      ],
    );
  }

  // Diálogos implementados conforme especificado no prompt
  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Termos de Uso',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: VelloTokens.brand,
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              '''1. ACEITAÇÃO DOS TERMOS
Ao utilizar o aplicativo Vello, você concorda com estes termos de uso.

2. DESCRIÇÃO DO SERVIÇO
O Vello é uma plataforma que conecta passageiros e motoristas para transporte urbano.

3. RESPONSABILIDADES DO USUÁRIO
- Fornecer informações verdadeiras
- Respeitar motoristas e outros usuários
- Cumprir as leis de trânsito

4. PAGAMENTOS
- Tarifas são calculadas automaticamente
- Pagamentos processados via app
- Cancelamentos podem gerar taxas

5. PRIVACIDADE
Seus dados são protegidos conforme nossa Política de Privacidade.

6. LIMITAÇÃO DE RESPONSABILIDADE
O Vello não se responsabiliza por danos indiretos ou consequenciais.

7. MODIFICAÇÕES
Estes termos podem ser alterados a qualquer momento.

8. CONTATO
Para dúvidas: suporte@vello.com.br''',
              style: TextStyle(fontSize: 14),
            ),
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

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Política de Privacidade',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: VelloTokens.brand,
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              '''POLÍTICA DE PRIVACIDADE - VELLO

1. COLETA DE DADOS
Coletamos informações necessárias para fornecer nossos serviços:
- Dados pessoais (nome, telefone, email)
- Localização para viagens
- Informações de pagamento
- Histórico de viagens

2. USO DOS DADOS
Utilizamos seus dados para:
- Conectar você com motoristas
- Processar pagamentos
- Melhorar nossos serviços
- Comunicação sobre viagens

3. COMPARTILHAMENTO
Compartilhamos dados apenas:
- Com motoristas durante viagens
- Para processamento de pagamentos
- Quando exigido por lei

4. SEGURANÇA
Implementamos medidas de segurança para proteger seus dados:
- Criptografia de dados sensíveis
- Acesso restrito às informações
- Monitoramento de segurança

5. SEUS DIREITOS
Você pode:
- Acessar seus dados
- Corrigir informações
- Solicitar exclusão
- Revogar consentimentos

6. RETENÇÃO DE DADOS
Mantemos seus dados pelo tempo necessário para fornecer os serviços.

7. CONTATO
Para questões de privacidade: privacidade@vello.com.br

Última atualização: Janeiro 2024''',
              style: TextStyle(fontSize: 14),
            ),
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

