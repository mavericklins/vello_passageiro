class AppConstants {
  // Informações do App
  static const String appName = 'Vello Passageiro';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Aplicativo para passageiros da Vello';
  
  // Firebase Collections
  static const String passageirosCollection = 'passageiros';
  static const String corridasCollection = 'corridas';
  static const String avaliacoesCollection = 'avaliacoes';
  static const String notificacoesCollection = 'notificacoes';
  static const String favoritosCollection = 'favoritos';
  
  // Status da Corrida
  static const String statusAguardando = 'aguardando';
  static const String statusBuscando = 'buscando';
  static const String statusEncontrado = 'encontrado';
  static const String statusAndamento = 'andamento';
  static const String statusConcluida = 'concluida';
  static const String statusCancelada = 'cancelada';
  
  // Mensagens
  static const String erroLogin = 'Erro ao fazer login. Verifique suas credenciais.';
  static const String erroConexao = 'Erro de conexão. Tente novamente.';
  static const String sucessoLogin = 'Login realizado com sucesso!';
  static const String sucessoCadastro = 'Cadastro realizado com sucesso!';
  static const String erroPermissaoLocalizacao = 'Permissão de localização necessária.';
  
  // Configurações de Mapa
  static const double zoomPadrao = 15.0;
  static const double zoomMinimo = 10.0;
  static const double zoomMaximo = 18.0;
  
  // Configurações de Interface
  static const double borderRadius = 12.0;
  static const double paddingPadrao = 16.0;
  static const double marginPadrao = 8.0;
  
  // Validações
  static const int tamanhoMinimoSenha = 6;
  static const String regexEmail = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
}