import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/assistente_voz_service.dart';
import '../../theme/vello_tokens.dart';

class ChatbotSupportScreen extends StatefulWidget {
  @override
  _ChatbotSupportScreenState createState() => _ChatbotSupportScreenState();
}

class _ChatbotSupportScreenState extends State<ChatbotSupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AssistenteVozService _voiceService = AssistenteVozService();
  
  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _voiceMode = false;

  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _voiceService.inicializar();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    _messages.add(
      ChatMessage(
        text: 'Olá! 👋 Sou o assistente virtual do Vello. Como posso ajudar você hoje?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
    
    // Adicionar sugestões de perguntas frequentes
    Future.delayed(Duration(milliseconds: 500), () {
      _addBotMessage('Aqui estão algumas coisas que posso te ajudar:\n\n'
          '🚗 Problemas com corridas\n'
          '💳 Questões de pagamento\n'
          '📱 Dúvidas sobre o app\n'
          '🛡️ Recursos de segurança\n'
          '📞 Contato com motorista\n\n'
          'Digite sua dúvida ou escolha um dos tópicos acima!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: velloOrange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.smart_toy,
                color: VelloTokens.white,
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assistente Vello',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: velloBlue,
                  ),
                ),
                Text(
                  'Online agora',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: VelloTokens.white,
        elevation: 2,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: velloOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back,
              color: velloOrange,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _voiceMode ? Icons.mic : Icons.mic_none,
              color: _voiceMode ? velloOrange : velloBlue,
            ),
            onPressed: _toggleVoiceMode,
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: velloBlue),
            onPressed: _showOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: velloOrange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.smart_toy,
                color: VelloTokens.white,
                size: 16,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser ? velloBlue : VelloTokens.white,
                borderRadius: BorderRadius.circular(16).copyWith(
                  topLeft: message.isUser ? Radius.circular(16) : Radius.circular(4),
                  topRight: message.isUser ? Radius.circular(4) : Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: VelloTokens.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: message.isUser ? VelloTokens.white : velloBlue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isUser 
                          ? VelloTokens.white.withOpacity(0.7) 
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: velloBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                color: VelloTokens.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: velloOrange,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.smart_toy,
              color: VelloTokens.white,
              size: 16,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: VelloTokens.white,
              borderRadius: BorderRadius.circular(16).copyWith(
                topLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: VelloTokens.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                SizedBox(width: 4),
                _buildDot(1),
                SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: (value + index * 0.3) % 1.0,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VelloTokens.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: velloLightGray,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: _voiceMode ? 'Modo voz ativado...' : 'Digite sua mensagem...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabled: !_voiceMode,
                  ),
                  maxLines: null,
                  onSubmitted: (text) => _sendMessage(text),
                ),
              ),
            ),
            SizedBox(width: 12),
            if (_voiceMode) ...[
              GestureDetector(
                onTapDown: (_) => _startListening(),
                onTapUp: (_) => _stopListening(),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _voiceService.speechListening ? Colors.red : velloOrange,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    _voiceService.speechListening ? Icons.mic : Icons.mic_none,
                    color: VelloTokens.white,
                  ),
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: () => _sendMessage(_messageController.text),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: velloBlue,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.send,
                    color: VelloTokens.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();
    _processBotResponse(text);
  }

  void _processBotResponse(String userMessage) {
    // Simular processamento
    Future.delayed(Duration(seconds: 2), () {
      final response = _generateBotResponse(userMessage);
      _addBotMessage(response);
    });
  }

  String _generateBotResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('corrida') || message.contains('viagem')) {
      return 'Entendo que você tem uma dúvida sobre corridas! 🚗\n\n'
          'Posso te ajudar com:\n'
          '• Cancelar ou modificar corrida\n'
          '• Problemas com motorista\n'
          '• Rota ou destino incorreto\n'
          '• Tempo de espera\n\n'
          'Me conte mais detalhes sobre o problema que você está enfrentando.';
    }

    if (message.contains('pagamento') || message.contains('cobrança') || message.contains('dinheiro')) {
      return 'Questões de pagamento são importantes! 💳\n\n'
          'Posso te auxiliar com:\n'
          '• Problemas na cobrança\n'
          '• Métodos de pagamento\n'
          '• Reembolsos\n'
          '• Cupons e promoções\n\n'
          'Você poderia me explicar qual é o problema específico?';
    }

    if (message.contains('motorista') || message.contains('contato')) {
      return 'Precisa falar com o motorista? 👨‍🚗\n\n'
          'Você pode:\n'
          '• Ligar diretamente pelo app\n'
          '• Enviar mensagem via chat\n'
          '• Compartilhar localização\n\n'
          'Se for uma emergência, use o botão SOS no app!';
    }

    if (message.contains('segurança') || message.contains('sos') || message.contains('emergência')) {
      return 'Sua segurança é nossa prioridade! 🛡️\n\n'
          'Recursos de segurança disponíveis:\n'
          '• Botão SOS para emergências\n'
          '• Compartilhamento de viagem\n'
          '• Contatos de emergência\n'
          '• Monitoramento em tempo real\n\n'
          'Para configurar, vá em Menu > Segurança no app.';
    }

    if (message.contains('app') || message.contains('aplicativo') || message.contains('problema')) {
      return 'Problemas técnicos podem ser frustrantes! 📱\n\n'
          'Tente estas soluções:\n'
          '• Feche e abra o app novamente\n'
          '• Verifique sua conexão com a internet\n'
          '• Atualize o app na loja\n'
          '• Reinicie seu celular\n\n'
          'Se o problema persistir, posso te conectar com suporte técnico.';
    }

    if (message.contains('obrigado') || message.contains('valeu') || message.contains('thanks')) {
      return 'Fico feliz em ter ajudado! 😊\n\n'
          'Lembre-se: estou sempre aqui quando precisar.\n'
          'Tenha uma ótima viagem! 🚗✨';
    }

    // Resposta padrão
    return 'Entendi sua mensagem! 🤔\n\n'
        'Para te ajudar melhor, você poderia me dizer mais especificamente:\n\n'
        '• Qual é o problema que você está enfrentando?\n'
        '• Quando isso aconteceu?\n'
        '• Já tentou alguma solução?\n\n'
        'Quanto mais detalhes, melhor posso te auxiliar! 😊';
  }

  void _addBotMessage(String text) {
    setState(() {
      _isTyping = false;
      _messages.add(
        ChatMessage(
          text: text,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });

    _scrollToBottom();

    // Falar a resposta se o modo voz estiver ativo
    if (_voiceMode) {
      _voiceService.falar(text);
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _toggleVoiceMode() {
    setState(() {
      _voiceMode = !_voiceMode;
    });

    if (_voiceMode) {
      _voiceService.falar('Modo voz ativado. Pressione e segure o botão do microfone para falar.');
    }
  }

  void _startListening() async {
    await _voiceService.iniciarEscuta();
  }

  void _stopListening() async {
    await _voiceService.pararEscuta();
    
    // Se algo foi reconhecido, enviar como mensagem
    if (_voiceService.lastWords.isNotEmpty) {
      _sendMessage(_voiceService.lastWords);
    }
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.history, color: velloBlue),
              title: Text('Histórico de Conversas'),
              onTap: () {
                Navigator.pop(context);
                // Implementar histórico
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback, color: velloBlue),
              title: Text('Avaliar Atendimento'),
              onTap: () {
                Navigator.pop(context);
                _showRatingDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: velloBlue),
              title: Text('Falar com Humano'),
              onTap: () {
                Navigator.pop(context);
                _connectToHuman();
              },
            ),
            ListTile(
              leading: Icon(Icons.clear, color: Colors.red),
              title: Text('Limpar Conversa'),
              onTap: () {
                Navigator.pop(context);
                _clearChat();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Avalie nosso atendimento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Como foi sua experiência com o assistente?'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _submitRating(index + 1);
                  },
                  icon: Icon(
                    Icons.star,
                    color: velloOrange,
                    size: 32,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _submitRating(int rating) {
    _addBotMessage('Obrigado pela sua avaliação! ⭐\n\nSua opinião é muito importante para melhorarmos nosso atendimento. 😊');
  }

  void _connectToHuman() {
    _addBotMessage('Conectando você com um atendente humano... 👨‍💼\n\n'
        'Aguarde um momento que em breve alguém da nossa equipe entrará em contato.\n\n'
        'Tempo estimado de espera: 2-5 minutos');
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _initializeChat();
    });
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}