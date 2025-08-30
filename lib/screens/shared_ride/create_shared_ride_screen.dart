import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/vello_tokens.dart';
import '../../core/logger_service.dart';
import '../../core/error_handler.dart';

class CreateSharedRideScreen extends StatefulWidget {
  @override
  _CreateSharedRideScreenState createState() => _CreateSharedRideScreenState();
}

class _CreateSharedRideScreenState extends State<CreateSharedRideScreen> {
  final TextEditingController _destinoController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  
  DateTime _selectedDateTime = DateTime.now().add(Duration(hours: 1));
  int _maxPassengers = 2;
  String _valorEstimado = "R\$ --,--";
  List<String> _sugestoesDestino = [];
  bool _carregandoSugestoes = false;
  Position? _posicaoAtual;

  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlueAlt;
  static const Color velloOrange = VelloTokens.brand;
  static const Color velloLightGray = VelloTokens.gray100;
  static const Color velloCardBackground = VelloTokens.white;

  @override
  void initState() {
    super.initState();
    _obterLocalizacaoAtual();
    _destinoController.addListener(_onDestinoChanged);
  }

  @override
  void dispose() {
    _destinoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _obterLocalizacaoAtual() async {
    try {
      _posicaoAtual = await Geolocator.getCurrentPosition();
    } catch (e) {
      LoggerService.info('Erro ao obter localização: $e', context: context ?? 'UNKNOWN');
    }
  }

  void _onDestinoChanged() {
    if (_destinoController.text.length >= 3) {
      _buscarSugestoesDestino(_destinoController.text);
    } else {
      setState(() {
        _sugestoesDestino.clear();
      });
    }
  }

  Future<void> _buscarSugestoesDestino(String texto) async {
    if (texto.length < 3) return;
    
    setState(() {
      _carregandoSugestoes = true;
    });

    try {
      String filtro = '';
      if (_posicaoAtual != null) {
        final lat = _posicaoAtual!.latitude;
        final lon = _posicaoAtual!.longitude;
        filtro = '&filter=circle:$lon,$lat,50000';
      }

      final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/autocomplete?text=${Uri.encodeComponent(texto)}$filtro&limit=5&apiKey=203ba4a0a4304d349299a8aa22e1dcae'
      );
      
      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> sugestoes = [];

        if (data['features'] != null) {
          for (var item in data['features']) {
            final endereco = item['properties']['formatted'];
            if (endereco != null && endereco.isNotEmpty) {
              sugestoes.add(endereco);
            }
          }
        }

        setState(() {
          _sugestoesDestino = sugestoes;
          _carregandoSugestoes = false;
        });
      }
    } catch (e) {
      LoggerService.info('Erro ao buscar sugestões: $e', context: context ?? 'UNKNOWN');
      setState(() {
        _carregandoSugestoes = false;
      });
    }
  }

  void _selecionarDestino(String destino) {
    setState(() {
      _destinoController.text = destino;
      _sugestoesDestino.clear();
    });
    _calcularValorEstimado();
  }

  Future<void> _calcularValorEstimado() async {
    if (_posicaoAtual == null || _destinoController.text.isEmpty) return;

    // Simulação de cálculo - você pode integrar com sua API de cálculo
    setState(() {
      _valorEstimado = "R\$ ${(15.0 + (DateTime.now().millisecond % 20)).toStringAsFixed(2).replaceAll('.', ',')}";
    });
  }

  Future<void> _selecionarDataHora() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: velloOrange,
              onPrimary: VelloTokens.white,
              surface: VelloTokens.white,
              onSurface: velloBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: velloOrange,
                onPrimary: VelloTokens.white,
                surface: VelloTokens.white,
                onSurface: velloBlue,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _criarCorridaCompartilhada() {
    if (_destinoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecione um destino'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Implementar criação no Firebase
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Corrida compartilhada criada com sucesso!'),
        backgroundColor: velloOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        backgroundColor: velloBlue,
        title: Text(
          'Criar Corrida Compartilhada',
          style: TextStyle(
            color: VelloTokens.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: VelloTokens.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de destino
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: velloCardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: VelloTokens.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: velloOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: velloOrange,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Para onde você vai?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: velloBlue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _destinoController,
                    decoration: InputDecoration(
                      hintText: "Digite o destino",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: velloOrange, width: 2),
                      ),
                      filled: true,
                      fillColor: velloLightGray,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      suffixIcon: _carregandoSugestoes
                          ? Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: velloOrange,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  if (_sugestoesDestino.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: VelloTokens.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _sugestoesDestino.length,
                        separatorBuilder: (context, index) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.location_on, color: velloOrange, size: 20),
                            title: Text(
                              _sugestoesDestino[index],
                              style: TextStyle(fontSize: 14),
                            ),
                            onTap: () => _selecionarDestino(_sugestoesDestino[index]),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 16),

            // Card de data e hora
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: velloCardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: VelloTokens.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: velloOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.schedule,
                          color: velloOrange,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Quando você quer viajar?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: velloBlue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: _selecionarDataHora,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: velloLightGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: velloBlue, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${_selectedDateTime.day.toString().padLeft(2, '0')}/${_selectedDateTime.month.toString().padLeft(2, '0')}/${_selectedDateTime.year} às ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 14,
                                color: velloBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: velloOrange, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Card de passageiros
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: velloCardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: VelloTokens.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: velloOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.group,
                          color: velloOrange,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Quantos passageiros?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: velloBlue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [1, 2, 3].map((number) {
                      final isSelected = _maxPassengers == number;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _maxPassengers = number;
                          });
                        },
                        child: Container(
                          width: 80,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isSelected ? velloOrange : velloLightGray,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? velloOrange : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$number',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? VelloTokens.white : velloBlue,
                                ),
                              ),
                              Text(
                                number == 1 ? 'pessoa' : 'pessoas',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected ? VelloTokens.white : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Card de descrição opcional
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: velloCardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: VelloTokens.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: velloOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.description,
                          color: velloOrange,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Descrição (opcional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: velloBlue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _descricaoController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Ex: Viagem para o aeroporto, tenho bagagem...",
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: velloOrange, width: 2),
                      ),
                      filled: true,
                      fillColor: velloLightGray,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Valor estimado
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: velloOrange,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: velloOrange.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Valor estimado total',
                    style: TextStyle(
                      fontSize: 14,
                      color: VelloTokens.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _valorEstimado,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: VelloTokens.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Dividido entre $_maxPassengers ${_maxPassengers == 1 ? 'pessoa' : 'pessoas'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: VelloTokens.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Botão criar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _criarCorridaCompartilhada,
                style: ElevatedButton.styleFrom(
                  backgroundColor: velloBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle, color: VelloTokens.white, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Criar Corrida Compartilhada',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: VelloTokens.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

