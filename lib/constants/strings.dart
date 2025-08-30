/// Classe para centralização de todas as strings da aplicação
/// Organizada por funcionalidades para fácil manutenção e internacionalização futura
class AppStrings {
  
  // ===== GERAL =====
  static const String appName = 'Vello';
  static const String ok = 'OK';
  static const String cancelar = 'Cancelar';
  static const String salvar = 'Salvar';
  static const String editar = 'Editar';
  static const String remover = 'Remover';
  static const String adicionar = 'Adicionar';
  static const String confirmar = 'Confirmar';
  static const String voltar = 'Voltar';
  static const String continuar = 'Continuar';
  static const String sim = 'Sim';
  static const String nao = 'Não';
  static const String carregando = 'Carregando...';
  static const String erro = 'Erro';
  static const String sucesso = 'Sucesso';
  static const String atencao = 'Atenção';
  static const String importante = 'Importante!';
  
  // ===== CAMPOS DE FORMULÁRIO =====
  
  // Labels
  static const String labelNome = 'Nome completo';
  static const String labelEmail = 'Email';
  static const String labelSenha = 'Senha';
  static const String labelConfirmarSenha = 'Confirmar senha';
  static const String labelCpf = 'CPF';
  static const String labelCelular = 'Celular';
  static const String labelTelefone = 'Telefone (com DDD)';
  static const String labelParentesco = 'Parentesco/Relação';
  static const String labelNumeroCartao = 'Número do cartão';
  static const String labelNomeCartao = 'Nome no cartão';
  static const String labelValidadeCartao = 'Validade';
  static const String labelCvv = 'CVV';
  
  // Hints/Placeholders
  static const String hintEmail = 'seu@email.com';
  static const String hintSenha = 'Digite sua senha';
  static const String hintTelefone = '11999999999';
  static const String hintParentesco = 'Ex: Mãe, Pai, Irmão, Amigo...';
  static const String hintNumeroCartao = '0000 0000 0000 0000';
  static const String hintValidadeCartao = 'MM/AA';
  static const String hintCvv = '123';
  
  // ===== LOGIN =====
  static const String tituloLogin = 'Bem-vindo de volta!';
  static const String subtituloLogin = 'Faça login para continuar';
  static const String botaoEntrar = 'Entrar';
  static const String lembrarMe = 'Lembrar-me';
  static const String esqueceuSenha = 'Esqueceu a senha?';
  static const String naoTemConta = 'Não tem uma conta? ';
  static const String linkCadastrese = 'Cadastre-se';
  static const String infoSeguranca = 'Seus dados são protegidos com criptografia segura. Nenhuma senha é armazenada em texto plano.';
  
  // ===== CADASTRO/REGISTRO =====
  static const String tituloCriarConta = 'Criar Conta';
  static const String subtituloCriarConta = 'Preencha seus dados para começar';
  static const String botaoRegistrar = 'Registrar';
  static const String jaTemConta = 'Já tem uma conta? Faça login';
  static const String escolherFoto = 'Escolher foto';
  static const String galeria = 'Galeria';
  static const String camera = 'Câmera';
  
  // ===== CONTATOS DE EMERGÊNCIA =====
  static const String tituloContatosEmergencia = 'Contatos de Emergência';
  static const String novoContatoEmergencia = 'Novo Contato de Emergência';
  static const String editarContato = 'Editar Contato';
  static const String removerContato = 'Remover Contato';
  static const String tornarPrincipal = 'Tornar Principal';
  static const String ligar = 'Ligar';
  static const String principal = 'PRINCIPAL';
  static const String seusContatos = 'Seus Contatos';
  static const String numerosEmergencia = 'Números de Emergência';
  static const String nenhumContatoCadastrado = 'Nenhum contato cadastrado';
  static const String adicionarContatosConfianca = 'Adicione contatos de confiança para emergências';
  static const String adicionarPrimeiroContato = 'Adicionar Primeiro Contato';
  static const String salvarAlteracoes = 'Salvar Alterações';
  static const String adicionarContato = 'Adicionar Contato';
  static const String toqueParaLigar = 'Toque para ligar';
  
  // Informações sobre contatos de emergência
  static const String infoContatosEmergencia = 'Configure seus contatos de emergência para que sejam notificados automaticamente em caso de acionamento do SOS.';
  static const String regrasContatos = '• Máximo 5 contatos\n'
      '• 1 contato principal\n'
      '• Notificação via WhatsApp\n'
      '• Localização em tempo real';
  
  // ===== PAGAMENTO =====
  static const String tituloPagamentoDebito = 'Pagamento - Débito';
  static const String valorCorrida = 'Valor da Corrida';
  static const String dadosCartaoDebito = 'Dados do Cartão de Débito';
  static const String botaoPagar = 'Pagar';
  static const String pagamentoAprovado = 'Pagamento Aprovado!';
  static const String pagamentoProcessadoSucesso = 'Seu pagamento foi processado com sucesso.';
  static const String valor = 'Valor';
  
  // ===== MENSAGENS DE SUCESSO =====
  static const String loginRealizadoSucesso = 'Login realizado com sucesso!';
  static const String cadastroRealizadoSucesso = 'Cadastro realizado com sucesso!';
  static const String contatoAdicionadoSucesso = 'Contato adicionado com sucesso!';
  static const String contatoAtualizadoSucesso = 'Contato atualizado com sucesso!';
  static const String contatoRemovidoSucesso = 'Contato removido';
  static const String contatoPrincipalDefinido = 'agora é o contato principal';
  
  // ===== MENSAGENS DE ERRO - VALIDAÇÃO =====
  
  // Email
  static const String erroEmailObrigatorio = 'Por favor, insira seu email';
  static const String erroEmailInvalido = 'Por favor, insira um email válido';
  
  // Senha
  static const String erroSenhaObrigatoria = 'Por favor, insira sua senha';
  static const String erroSenhaMinima = 'A senha deve ter pelo menos 6 caracteres';
  static const String erroSenhaForte = 'A senha deve conter entre 8 e 20 caracteres, com letra maiúscula, minúscula, número e caractere especial';
  
  // Nome
  static const String erroNomeObrigatorio = 'Por favor, insira seu nome';
  static const String erroNomeCompleto = 'Informe nome e sobrenome';
  static const String erroNomeCartaoObrigatorio = 'Digite o nome no cartão';
  
  // CPF
  static const String erroCpfObrigatorio = 'Por favor, insira seu CPF';
  static const String erroCpfInvalido = 'CPF inválido';
  static const String erroCpfJaCadastrado = 'CPF já cadastrado';
  
  // Telefone
  static const String erroTelefoneObrigatorio = 'Telefone é obrigatório';
  static const String erroTelefoneInvalido = 'Telefone inválido';
  
  // Parentesco
  static const String erroParentescoObrigatorio = 'Parentesco é obrigatório';
  
  // Cartão
  static const String erroNumeroCartaoObrigatorio = 'Digite o número do cartão';
  static const String erroNumeroCartaoInvalido = 'Número do cartão inválido';
  static const String erroValidadeObrigatoria = 'Digite a validade';
  static const String erroValidadeInvalida = 'Validade inválida';
  static const String erroCvvObrigatorio = 'Digite o CVV';
  static const String erroCvvInvalido = 'CVV inválido';
  
  // Campos obrigatórios
  static const String erroCamposObrigatorios = 'Por favor, preencha todos os campos';
  
  // ===== MENSAGENS DE ERRO - AUTENTICAÇÃO =====
  static const String erroUsuarioNaoEncontrado = 'Usuário não encontrado. Verifique o email.';
  static const String erroSenhaIncorreta = 'Senha incorreta. Tente novamente.';
  static const String erroEmailJaCadastrado = 'E-mail já cadastrado';
  static const String erroContaDesabilitada = 'Esta conta foi desabilitada.';
  static const String erroMuitasTentativas = 'Muitas tentativas. Tente novamente mais tarde.';
  static const String erroInesperado = 'Erro inesperado. Tente novamente.';
  static const String erroSalvarCadastro = 'Erro ao salvar cadastro';
  static const String erroAdicionarContato = 'Erro ao adicionar contato';
  static const String erroAtualizarContato = 'Erro ao atualizar contato';
  
  // ===== CONFIRMAÇÕES =====
  static const String confirmarRemocaoContato = 'Deseja remover {name} dos seus contatos de emergência?';
  
  // ===== NÚMEROS DE EMERGÊNCIA =====
  static const String policia = 'Polícia';
  static const String samu = 'SAMU';
  static const String bombeiros = 'Bombeiros';
  static const String prf = 'PRF';
  
  // Método auxiliar para substituir placeholders em strings
  static String replaceInString(String template, Map<String, String> replacements) {
    String result = template;
    replacements.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}