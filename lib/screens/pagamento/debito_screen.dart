import 'package:flutter/material.dart';
import '../../theme/vello_tokens.dart';
import '../../utils/validators.dart';
import '../../constants/strings.dart';

class DebitoScreen extends StatefulWidget {
  final String valorCorrida;

  const DebitoScreen({Key? key, required this.valorCorrida}) : super(key: key);

  @override
  _DebitoScreenState createState() => _DebitoScreenState();
}

class _DebitoScreenState extends State<DebitoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroCartaoController = TextEditingController();
  final _nomeController = TextEditingController();
  final _validadeController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _processandoPagamento = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tituloPagamentoDebito),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Valor da corrida
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      'Valor da Corrida',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'R\$ ${widget.valorCorrida}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              Text(
                'Dados do Cartão de Débito',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 16),
              
              // Número do cartão
              TextFormField(
                controller: _numeroCartaoController,
                decoration: InputDecoration(
                  labelText: 'Número do cartão',
                  hintText: '0000 0000 0000 0000',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.erroNumeroCartaoObrigatorio;
                  }
                  if (!Validators.isValidCreditCard(value)) {
                    return AppStrings.erroNumeroCartaoInvalido;
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 16),
              
              // Nome no cartão
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome no cartão',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o nome no cartão';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 16),
              
              Row(
                children: [
                  // Validade
                  Expanded(
                    child: TextFormField(
                      controller: _validadeController,
                      decoration: InputDecoration(
                        labelText: 'Validade',
                        hintText: 'MM/AA',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite a validade';
                        }
                        return null;
                      },
                    ),
                  ),
                  
                  SizedBox(width: 16),
                  
                  // CVV
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.security),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite o CVV';
                        }
                        if (value.length < 3) {
                          return 'CVV inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              Spacer(),
              
              // Botão de pagamento
              Container(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _processandoPagamento ? null : _processarPagamento,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _processandoPagamento
                      ? CircularProgressIndicator(color: VelloTokens.white)
                      : Text(
                          'Pagar R\$ ${widget.valorCorrida}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: VelloTokens.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processarPagamento() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _processandoPagamento = true;
    });

    // Simular processamento do pagamento
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _processandoPagamento = false;
    });

    // Mostrar sucesso
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Pagamento Aprovado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Seu pagamento foi processado com sucesso.'),
            SizedBox(height: 16),
            Text(
              'Valor: R\$ ${widget.valorCorrida}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fechar dialog
              Navigator.of(context).pop(true); // Voltar com sucesso
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('OK', style: TextStyle(color: VelloTokens.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _numeroCartaoController.dispose();
    _nomeController.dispose();
    _validadeController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}

