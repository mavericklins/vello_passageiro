import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/feature_flags.dart';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

class AssistenteVozService extends ChangeNotifier {
  static final AssistenteVozService _instance = AssistenteVozService._internal();
  factory AssistenteVozService() => _instance;
  AssistenteVozService._internal();

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _speechEnabled = false;
  bool _speechListening = false;
  bool _ttsEnabled = true;
  String _lastWords = '';
  List<Map<String, dynamic>> _comandosPersonalizados = [];

  // Getters
  bool get speechEnabled => _speechEnabled;
  bool get speechListening => _speechListening;
  bool get ttsEnabled => _ttsEnabled;
  String get lastWords => _lastWords;
  List<Map<String, dynamic>> get comandosPersonalizados => _comandosPersonalizados;

  // Feature flag getter
  bool get isEnabled => FeatureFlags.enableVoiceAssistant;

  // Inicializar assistente
  Future<void> inicializar() async {
    if (!isEnabled) {
      LoggerService.info('Assistente de voz não está habilitado', context: context ?? 'UNKNOWN');
      return;
    }

    await _inicializarSpeechToText();
    await _inicializarTTS();
    await _carregarComandosPersonalizados();
  }

  // Inicializar Speech-to-Text
  Future<void> _inicializarSpeechToText() async {
    try {
      // Solicitar permissão de microfone
      var status = await Permission.microphone.request();

      if (status == PermissionStatus.granted) {
        _speechEnabled = await _speechToText.initialize(
          onStatus: (status) => LoggerService.debug('STT Status: $status', context: 'VOICE'),
          onError: (error) => LoggerService.error('STT Erro: $error', context: 'VOICE'),
        );
      }
    } catch (e) {
      LoggerService.info('Erro ao inicializar Speech-to-Text: $e', context: context ?? 'UNKNOWN');
      _speechEnabled = false;
    }

    notifyListeners();
  }

  // Inicializar Text-to-Speech
  Future<void> _inicializarTTS() async {
    if (!isEnabled) return;
    try {
      await _flutterTts.setLanguage('pt-BR');
      await _flutterTts.setSpeechRate(0.8);
      await _flutterTts.setVolume(0.8);
      await _flutterTts.setPitch(1.0);

      _ttsEnabled = true;
    } catch (e) {
      LoggerService.info('Erro ao inicializar TTS: $e', context: context ?? 'UNKNOWN');
      _ttsEnabled = false;
    }
  }

  // Começar escuta
  Future<void> iniciarEscuta() async {
    if (!isEnabled || !_speechEnabled || _speechListening) return;

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        partialResults: true,
        localeId: 'pt_BR',
        cancelOnError: true,
      );

      _speechListening = true;
      notifyListeners();

      // Som de início
      await falar('Estou escutando...');
    } catch (e) {
      LoggerService.info('Erro ao iniciar escuta: $e', context: context ?? 'UNKNOWN');
    }
  }

  // Parar escuta
  Future<void> pararEscuta() async {
    if (!isEnabled) return;
    await _speechToText.stop();
    _speechListening = false;
    notifyListeners();
  }

  // Callback para resultado da fala
  void _onSpeechResult(result) {
    _lastWords = result.recognizedWords;
    notifyListeners();

    if (result.finalResult) {
      _processarComando(_lastWords);
      _speechListening = false;
      notifyListeners();
    }
  }

  // Processar comando de voz
  Future<void> _processarComando(String comando) async {
    if (!isEnabled) return;

    final comandoLower = comando.toLowerCase().trim();

    LoggerService.info('Comando recebido: $comandoLower', context: context ?? 'UNKNOWN');

    // Comandos básicos para passageiro
    if (comandoLower.contains('chamar') && comandoLower.contains('uber')) {
      await _executarComandoChamarVeiculo();
    } else if (comandoLower.contains('cancelar') && comandoLower.contains('corrida')) {
      await _executarComandoCancelarCorrida();
    } else if (comandoLower.contains('onde') && comandoLower.contains('motorista')) {
      await _executarComandoLocalizarMotorista();
    } else if (comandoLower.contains('emergência') || comandoLower.contains('sos')) {
      await _executarComandoEmergencia();
    } else if (comandoLower.contains('destino') || comandoLower.contains('ir para')) {
      await _executarComandoDefinirDestino(comandoLower);
    } else if (comandoLower.contains('preço') || comandoLower.contains('valor')) {
      await _executarComandoConsultarPreco();
    } else if (comandoLower.contains('historico') || comandoLower.contains('histórico')) {
      await _executarComandoHistorico();
    } else if (comandoLower.contains('ajuda')) {
      await _mostrarComandosDisponiveis();
    } else if (comandoLower.contains('status') || comandoLower.contains('situação')) {
      await _informarStatus();
    } else {
      // Verificar comandos personalizados
      bool comandoEncontrado = false;
      for (var cmd in _comandosPersonalizados) {
        if (comandoLower.contains(cmd['gatilho'].toLowerCase())) {
          await _executarComandoPersonalizado(cmd);
          comandoEncontrado = true;
          break;
        }
      }

      if (!comandoEncontrado) {
        await falar('Comando não reconhecido. Diga "ajuda" para ver os comandos disponíveis.');
      }
    }
  }

  // Executar comandos específicos para passageiro
  Future<void> _executarComandoChamarVeiculo() async {
    await falar('Buscando veículos disponíveis próximos a você...');
    // Implementar lógica de chamar veículo
  }

  Future<void> _executarComandoCancelarCorrida() async {
    await falar('Cancelando corrida atual...');
    // Implementar lógica de cancelar corrida
  }

  Future<void> _executarComandoLocalizarMotorista() async {
    await falar('O motorista está a caminho da sua localização...');
    // Implementar lógica de localizar motorista
  }

  Future<void> _executarComandoEmergencia() async {
    await falar('Acionando emergência. Mantendo-me a disposição para ajudar.');
    // Implementar lógica de emergência
  }

  Future<void> _executarComandoDefinirDestino(String comando) async {
    await falar('Definindo destino baseado no seu comando...');
    // Implementar lógica de definir destino por voz
  }

  Future<void> _executarComandoConsultarPreco() async {
    await falar('Consultando preços dos veículos disponíveis...');
    // Implementar lógica de consultar preço
  }

  Future<void> _executarComandoHistorico() async {
    await falar('Abrindo histórico de corridas...');
    // Implementar lógica de mostrar histórico
  }

  Future<void> _mostrarComandosDisponiveis() async {
    final comandos = [
      'Chamar Uber - para solicitar um veículo',
      'Cancelar corrida - para cancelar viagem atual',
      'Onde está o motorista - para localizar o motorista',
      'Emergência ou SOS - para acionar ajuda',
      'Ir para [local] - para definir destino',
      'Qual o preço - para consultar valores',
      'Histórico - para ver viagens anteriores',
      'Status - para saber sua situação atual',
    ];

    await falar('Comandos disponíveis: ${comandos.join(', ')}');
  }

  Future<void> _informarStatus() async {
    // Obter status atual do passageiro
    try {
      final passageiroId = FirebaseAuth.instance.currentUser?.uid;
      if (passageiroId == null) {
        await falar('Usuário não identificado');
        return;
      }

      final doc = await _firestore.collection('usuarios').doc(passageiroId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final nome = data['nome'] ?? 'Passageiro';
        
        // Verificar se há corrida ativa
        final corridaAtiva = await _firestore
            .collection('corridas')
            .where('passageiroId', isEqualTo: passageiroId)
            .where('status', whereIn: ['solicitada', 'aceita', 'em_andamento'])
            .limit(1)
            .get();

        if (corridaAtiva.docs.isNotEmpty) {
          final corrida = corridaAtiva.docs.first.data();
          final status = corrida['status'];
          await falar('Olá $nome, você tem uma corrida $status no momento.');
        } else {
          await falar('Olá $nome, você não tem corridas ativas no momento.');
        }
      } else {
        await falar('Não foi possível obter seu status atual');
      }
    } catch (e) {
      await falar('Erro ao obter informações de status');
    }
  }

  // Executar comando personalizado
  Future<void> _executarComandoPersonalizado(Map<String, dynamic> comando) async {
    await falar(comando['resposta'] ?? 'Comando personalizado executado');

    // Log do uso do comando
    await _salvarLogComando(comando['nome'], _lastWords);
  }

  // Falar texto
  Future<void> falar(String texto) async {
    if (!isEnabled || !_ttsEnabled) return;

    try {
      await _flutterTts.speak(texto);
    } catch (e) {
      LoggerService.info('Erro ao falar: $e', context: context ?? 'UNKNOWN');
    }
  }

  // Parar fala
  Future<void> pararFala() async {
    if (!isEnabled) return;
    try {
      await _flutterTts.stop();
    } catch (e) {
      LoggerService.info('Erro ao parar fala: $e', context: context ?? 'UNKNOWN');
    }
  }

  // Toggle TTS
  void toggleTTS() {
    if (!isEnabled) return;
    _ttsEnabled = !_ttsEnabled;
    notifyListeners();
  }

  // Configurar velocidade da fala
  Future<void> configurarVelocidadeFala(double velocidade) async {
    if (!isEnabled) return;
    try {
      await _flutterTts.setSpeechRate(velocidade.clamp(0.1, 2.0));
    } catch (e) {
      LoggerService.info('Erro ao configurar velocidade: $e', context: context ?? 'UNKNOWN');
    }
  }

  // Configurar volume
  Future<void> configurarVolume(double volume) async {
    if (!isEnabled) return;
    try {
      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      LoggerService.info('Erro ao configurar volume: $e', context: context ?? 'UNKNOWN');
    }
  }

  // Adicionar comando personalizado
  Future<void> adicionarComandoPersonalizado(
      String nome,
      String gatilho,
      String resposta,
      String acao,
      ) async {
    if (!isEnabled) return;
    try {
      final comando = {
        'nome': nome,
        'gatilho': gatilho,
        'resposta': resposta,
        'acao': acao,
        'criadoEm': DateTime.now(),
        'usos': 0,
      };

      _comandosPersonalizados.add(comando);
      await _salvarComandosPersonalizados();

      notifyListeners();

      await falar('Comando personalizado "$nome" adicionado com sucesso');
    } catch (e) {
      LoggerService.info('Erro ao adicionar comando: $e', context: context ?? 'UNKNOWN');
      await falar('Erro ao adicionar comando personalizado');
    }
  }

  // Remover comando personalizado
  Future<void> removerComandoPersonalizado(int index) async {
    if (!isEnabled) return;
    if (index >= 0 && index < _comandosPersonalizados.length) {
      final comando = _comandosPersonalizados.removeAt(index);
      await _salvarComandosPersonalizados();

      notifyListeners();

      await falar('Comando "${comando['nome']}" removido');
    }
  }

  // Carregar comandos personalizados
  Future<void> _carregarComandosPersonalizados() async {
    if (!isEnabled) return;
    try {
      final passageiroId = FirebaseAuth.instance.currentUser?.uid;
      if (passageiroId == null) return;

      final doc = await _firestore
          .collection('usuarios')
          .doc(passageiroId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final comandosData = data['comandosVoz'] as List<dynamic>?;

        if (comandosData != null) {
          _comandosPersonalizados = comandosData
              .cast<Map<String, dynamic>>()
              .toList();
        }
      }
    } catch (e) {
      LoggerService.info('Erro ao carregar comandos personalizados: $e', context: context ?? 'UNKNOWN');
    }
  }

  // Salvar comandos personalizados
  Future<void> _salvarComandosPersonalizados() async {
    if (!isEnabled) return;
    try {
      final passageiroId = FirebaseAuth.instance.currentUser?.uid;
      if (passageiroId == null) return;

      await _firestore
          .collection('usuarios')
          .doc(passageiroId)
          .update({
        'comandosVoz': _comandosPersonalizados,
      });
    } catch (e) {
      LoggerService.info('Erro ao salvar comandos: $e', context: context ?? 'UNKNOWN');
    }
  }

  // Salvar log de uso de comando
  Future<void> _salvarLogComando(String nomeComando, String textoReconhecido) async {
    if (!isEnabled) return;
    try {
      final passageiroId = FirebaseAuth.instance.currentUser?.uid;
      if (passageiroId == null) return;

      await _firestore.collection('logs_comandos_voz').add({
        'passageiroId': passageiroId,
        'comando': nomeComando,
        'textoReconhecido': textoReconhecido,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      LoggerService.info('Erro ao salvar log: $e', context: context ?? 'UNKNOWN');
    }
  }

  // Modo mãos livres
  void ativarModoMaosLivres() {
    if (!isEnabled) return;
    // Implementar modo que responde automaticamente a determinados eventos
    LoggerService.info('Modo mãos livres ativado', context: context ?? 'UNKNOWN');
  }

  void desativarModoMaosLivres() {
    if (!isEnabled) return;
    LoggerService.info('Modo mãos livres desativado', context: context ?? 'UNKNOWN');
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }
}