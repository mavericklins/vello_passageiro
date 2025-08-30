import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/vello_tokens.dart';

class PagamentoScreen extends StatefulWidget {
  final String valorCorrida;
  final String enderecoOrigem;
  final String enderecoDestino;

  const PagamentoScreen({
    Key? key,
    required this.valorCorrida,
    required this.enderecoOrigem,
    required this.enderecoDestino,
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

    // Simular processamento
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      processandoPagamento = false;
    });

    _mostrarDialogoSucesso();
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
                'Sua corrida foi solicitada com sucesso.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Acompanhar Corrida'),
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
    required IconData icone,
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
          child: Icon(icone, color: cor, size: 28),
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
        onTap: () => _selecionarFormaPagamento(id),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Formas de Pagamento'),
        backgroundColor: VelloTokens.white,
        foregroundColor: VelloTokens.black87,
        elevation: 0,
        centerTitle: true,
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
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
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
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(Icons.my_location, color: Colors.green, size: 20),
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
                          Icon(Icons.location_on, color: Colors.red, size: 20),
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
                            ),
                          ),
                          Text(
                            widget.valorCorrida,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
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
                  icone: Icons.qr_code,
                  cor: Colors.purple,
                ),
                
                _buildFormaPagamento(
                  id: 'credito',
                  titulo: 'Cartão de Crédito',
                  subtitulo: 'Visa, Mastercard, Elo',
                  icone: Icons.credit_card,
                  cor: Colors.blue,
                ),
                
                _buildFormaPagamento(
                  id: 'debito',
                  titulo: 'Cartão de Débito',
                  subtitulo: 'Débito em conta',
                  icone: Icons.payment,
                  cor: Colors.orange,
                ),
                
                _buildFormaPagamento(
                  id: 'dinheiro',
                  titulo: 'Dinheiro',
                  subtitulo: 'Pagamento em espécie',
                  icone: Icons.attach_money,
                  cor: Colors.green,
                ),
                
                _buildFormaPagamento(
                  id: 'carteira',
                  titulo: 'Carteira Digital',
                  subtitulo: 'PayPal, PicPay, Mercado Pago',
                  icone: Icons.account_balance_wallet,
                  cor: Colors.teal,
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

