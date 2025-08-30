import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vello/screens/map/map_screen.dart';
import 'package:vello/screens/pagamento/pix_screen.dart';
import 'package:vello/screens/pagamento/credito_screen.dart';
import 'package:vello/screens/pagamento/debito_screen.dart';
import 'package:vello/screens/pagamento/dinheiro_screen.dart';
import 'package:vello/screens/pagamento/carteira_digital_screen.dart';
import 'package:vello/screens/pagamento/vello_points_screen.dart';
import '../../services/ride_request_service.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/vello_tokens.dart';

class PagamentoScreen extends StatefulWidget {
  final String valorCorrida;
  final String enderecoOrigem;
  final String enderecoDestino;
  final LatLng? origemCoords;
  final LatLng? destinoCoords;
  final List<String>? paradasExtras;
  final List<LatLng>? paradasExtrasCoords;
  final bool isCorridaCompartilhada;
  final int maxPassageiros;

  const PagamentoScreen({
    Key? key,
    required this.valorCorrida,
    required this.enderecoOrigem,
    required this.enderecoDestino,
    this.origemCoords,
    this.destinoCoords,
    this.paradasExtras,
    this.paradasExtrasCoords,
    this.isCorridaCompartilhada = false,
    this.maxPassageiros = 1,
  }) : super(key: key);

  @override
  _PagamentoScreenState createState() => _PagamentoScreenState();
}

class _PagamentoScreenState extends State<PagamentoScreen> with TickerProviderStateMixin {
  String formaPagamentoSelecionada = '';
  final TextEditingController numeroCartaoController = TextEditingController();
  final TextEditingController validadeController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController nomeCartaoController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool mostrarCamposCartao = false;
  bool processandoPagamento = false;
  
  // Variáveis para integração com sistema de matching
  final RideRequestService _rideService = RideRequestService();
  String? _currentRideId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    numeroCartaoController.dispose();
    validadeController.dispose();
    cvvController.dispose();
    nomeCartaoController.dispose();
    super.dispose();
  }

  void _selecionarFormaPagamento(String forma) {
    setState(() {
      formaPagamentoSelecionada = forma;
      mostrarCamposCartao = (forma == 'credito' || forma == 'debito');
    });
    
    // Vibração leve para feedback tátil
    HapticFeedback.lightImpact();
  }

  void _processarPagamento() async {
    if (formaPagamentoSelecionada.isEmpty) {
      _mostrarSnackBar('Selecione uma forma de pagamento', Colors.orange);
      return;
    }

    if (mostrarCamposCartao && !_validarCamposCartao()) {
      _mostrarSnackBar('Preencha todos os campos do cartão', Colors.red);
      return;
    }

    setState(() {
      processandoPagamento = true;
    });

    try {
      // Simular processamento do pagamento
      await Future.delayed(Duration(seconds: 2));
      
      // Gerar ID da transação (em produção, viria do gateway de pagamento)
      final transactionId = 'txn_${DateTime.now().millisecondsSinceEpoch}';
      
      // Solicitar corrida APÓS confirmação do pagamento
      final rideId = await _rideService.requestRide(
        origem: widget.enderecoOrigem,
        destino: widget.enderecoDestino,
        origemCoords: widget.origemCoords ?? LatLng(-23.5505, -46.6333), // Default SP
        destinoCoords: widget.destinoCoords ?? LatLng(-23.5505, -46.6333), // Default SP
        estimatedFare: double.tryParse(widget.valorCorrida.replaceAll('R\$ ', '').replaceAll(',', '.')) ?? 0.0,
        paymentMethod: formaPagamentoSelecionada,
        paymentTransactionId: transactionId,
        additionalStops: widget.paradasExtras,
        additionalStopsCoords: widget.paradasExtrasCoords,
        isSharedRide: widget.isCorridaCompartilhada,
        maxPassengers: widget.maxPassageiros,
      );

      setState(() {
        processandoPagamento = false;
        _currentRideId = rideId;
      });

      if (rideId != null) {
        _mostrarDialogoSucesso();
      } else {
        _mostrarSnackBar('Erro ao solicitar corrida. Tente novamente.', Colors.red);
      }
    } catch (e) {
      setState(() {
        processandoPagamento = false;
      });
      _mostrarSnackBar('Erro no pagamento: $e', Colors.red);
    }
  }

  bool _validarCamposCartao() {
    return numeroCartaoController.text.length >= 16 &&
           validadeController.text.length >= 5 &&
           cvvController.text.length >= 3 &&
           nomeCartaoController.text.isNotEmpty;
  }

  void _mostrarSnackBar(String mensagem, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _mostrarDialogoSucesso() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 80),
              SizedBox(height: 20),
              Text(
                'Pagamento Confirmado!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Sua corrida foi solicitada com sucesso.\nBuscando motoristas disponíveis...',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              if (_currentRideId != null) ...[
                SizedBox(height: 10),
                Text(
                  'ID da Corrida: ${_currentRideId!.substring(0, 8)}...',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Fecha o diálogo
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(
                        valorCorrida: widget.valorCorrida,
                        rideId: _currentRideId,
                      ),
                    ),
                  );
                },
                child: Text("Acompanhar Corrida"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: VelloTokens.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormaPagamento({
    required String id,
    required String titulo,
    required String subtitulo,
    required Widget leadingWidget,
    required Color cor,
  }) {
    bool selecionado = formaPagamentoSelecionada == id;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: selecionado ? cor : Colors.grey.shade300,
          width: selecionado ? 2 : 1,
        ),
        color: selecionado ? cor.withOpacity(0.1) : VelloTokens.white,
        boxShadow: selecionado ? [
          BoxShadow(
            color: cor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ] : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: leadingWidget,
        ),
        title: Text(
          titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: selecionado ? cor : VelloTokens.black87,
          ),
        ),
        subtitle: Text(
          subtitulo,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: selecionado 
          ? Icon(Icons.check_circle, color: cor, size: 24)
          : Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                switch (id) {
                  case 'pix':
                    return PixScreen(valorCorrida: widget.valorCorrida);
                  case 'credito':
                    return CreditoScreen(valorCorrida: widget.valorCorrida);
                  case 'debito':
                    return DebitoScreen(valorCorrida: widget.valorCorrida);
                  case 'dinheiro':
                    return DinheiroScreen(valorCorrida: widget.valorCorrida);
                  case 'carteira':
                    return CarteiraDigitalScreen(valorCorrida: widget.valorCorrida);
                  case 'valuepoints':
                    return VelloPointsScreen(valorCorrida: widget.valorCorrida);
                  default:
                    return const Text('Página não encontrada'); // Retorno padrão para evitar erro de null safety
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCamposCartao() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      height: mostrarCamposCartao ? null : 0,
      child: mostrarCamposCartao ? Column(
        children: [
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dados do Cartão',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: numeroCartaoController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Número do Cartão',
                    hintText: '0000 0000 0000 0000',
                    prefixIcon: Icon(Icons.credit_card),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: VelloTokens.white,
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: validadeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          _ValidadeFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Validade',
                          hintText: 'MM/AA',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: VelloTokens.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: TextField(
                        controller: cvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          hintText: '000',
                          prefixIcon: Icon(Icons.security),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: VelloTokens.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                TextField(
                  controller: nomeCartaoController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nome no Cartão',
                    hintText: 'Como está impresso no cartão',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: VelloTokens.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ) : SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.gray100,
      appBar: AppBar(
        title: const Text(
          'Formas de Pagamento',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: VelloTokens.brandBlueAlt,
          ),
        ),
        backgroundColor: VelloTokens.white,
        foregroundColor: VelloTokens.brandBlueAlt,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: VelloTokens.gray200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: VelloTokens.brandBlueAlt,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resumo da corrida
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: VelloTokens.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: VelloTokens.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumo da Corrida',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: VelloTokens.brandBlueAlt,
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(Icons.my_location, color: VelloTokens.brandBlueAlt, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.enderecoOrigem,
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: VelloTokens.brand, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.enderecoDestino,
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                      Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Valor Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: VelloTokens.brandBlueAlt,
                            ),
                          ),
                          Text(
                            widget.valorCorrida,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: VelloTokens.brand,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 30),
                
                Text(
                  'Escolha a forma de pagamento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Formas de pagamento
                _buildFormaPagamento(
                  id: 'pix',
                  titulo: 'PIX',
                  subtitulo: 'Pagamento instantâneo',
                  leadingWidget: Icon(Icons.qr_code, color: VelloTokens.brand, size: 28),
                  cor: VelloTokens.brand,
                ),
                
                _buildFormaPagamento(
                  id: 'credito',
                  titulo: 'Cartão de Crédito',
                  subtitulo: 'Visa, Mastercard, Elo',
                  leadingWidget: Icon(Icons.credit_card, color: VelloTokens.brand, size: 28),
                  cor: VelloTokens.brand,
                ),
                
                _buildFormaPagamento(
                  id: 'debito',
                  titulo: 'Cartão de Débito',
                  subtitulo: 'Débito em conta',
                  leadingWidget: Icon(Icons.payment, color: VelloTokens.brand, size: 28),
                  cor: VelloTokens.brand,
                ),
                
                _buildFormaPagamento(
                  id: 'dinheiro',
                  titulo: 'Dinheiro',
                  subtitulo: 'Pagamento em espécie',
                  leadingWidget: Icon(Icons.attach_money, color: VelloTokens.brand, size: 28),
                  cor: VelloTokens.brand,
                ),
                
                _buildFormaPagamento(
                  id: 'carteira',
                  titulo: 'Carteira Digital',
                  subtitulo: 'PayPal, PicPay, Mercado Pago',
                  leadingWidget: Icon(Icons.account_balance_wallet, color: VelloTokens.brand, size: 28),
                  cor: VelloTokens.brand,
                ),
                
                _buildFormaPagamento(
                  id: 'valuepoints',
                  titulo: 'VelloPoints',
                  subtitulo: 'Use seus pontos acumulados',
                  leadingWidget: Icon(Icons.stars, color: VelloTokens.brand, size: 28),
                  cor: VelloTokens.brand,
                ),
                
                // Campos do cartão (se necessário)
                _buildCamposCartao(),
                
                SizedBox(height: 30),
                
                // Botão de confirmar pagamento
                Container(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: processandoPagamento ? null : _processarPagamento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: VelloTokens.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: Colors.green.withOpacity(0.3),
                    ),
                    child: processandoPagamento
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(VelloTokens.white),
                                ),
                              ),
                              SizedBox(width: 15),
                              Text(
                                'Processando...',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : Text(
                            'Confirmar Pagamento',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Formatador para número do cartão
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(' ', '');
    String formatted = '';
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += text[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Formatador para validade
class _ValidadeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll('/', '');
    String formatted = '';
    
    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        formatted += '/';
      }
      formatted += text[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

