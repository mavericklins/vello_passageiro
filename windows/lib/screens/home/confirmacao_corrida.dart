import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// IMPORT CORRETO baseado na estrutura: lib\screens\home\ -> lib\screens\pagamento\
import '../pagamento/pagamento_screen.dart';

class ConfirmacaoCorridaScreen extends StatefulWidget {
  final String enderecoInicial;

  const ConfirmacaoCorridaScreen({Key? key, required this.enderecoInicial}) : super(key: key);

  @override
  _ConfirmacaoCorridaScreenState createState() => _ConfirmacaoCorridaScreenState();
}

class _ConfirmacaoCorridaScreenState extends State<ConfirmacaoCorridaScreen> {
  final TextEditingController origemController = TextEditingController();
  final TextEditingController destinoController = TextEditingController();
  final FocusNode destinoFocus = FocusNode();

  List<String> sugestoesDestino = [];
  String valorEstimado = "R\$ --,--";
  bool carregandoLocalizacao = true;
  Position? posicaoAtual;
  bool enderecoSelecionado = false;

  @override
  void initState() {
    super.initState();
    _verificarPermissoesEObterLocalizacao();
    destinoController.addListener(_onEnderecoMudou);
    destinoFocus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    destinoController.removeListener(_onEnderecoMudou);
    destinoFocus.removeListener(_onFocusChanged);
    destinoController.dispose();
    destinoFocus.dispose();
    super.dispose();
  }

  // Verificar se todos os dados estão preenchidos
  bool get _dadosCompletos {
    return !carregandoLocalizacao &&
           origemController.text.isNotEmpty &&
           destinoController.text.isNotEmpty &&
           enderecoSelecionado &&
           valorEstimado != "R\$ --,--" &&
           posicaoAtual != null;
  }

  // Verificar permissões de localização antes de tentar obter a posição
  Future<void> _verificarPermissoesEObterLocalizacao() async {
    setState(() {
      carregandoLocalizacao = true;
      origemController.text = "Verificando permissões...";
    });

    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Verificar se o serviço de localização está habilitado
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          origemController.text = "Serviço de localização desabilitado";
          carregandoLocalizacao = false;
        });
        return;
      }

      // Verificar permissões
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            origemController.text = "Permissão de localização negada";
            carregandoLocalizacao = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          origemController.text = "Permissão de localização negada permanentemente";
          carregandoLocalizacao = false;
        });
        return;
      }

      // Se chegou até aqui, pode obter a localização
      await _definirLocalizacaoAtual();
    } catch (e) {
      print("Erro ao verificar permissões: $e");
      setState(() {
        origemController.text = "Erro ao verificar permissões";
        carregandoLocalizacao = false;
      });
    }
  }

  Future<void> _definirLocalizacaoAtual() async {
    setState(() {
      carregandoLocalizacao = true;
      origemController.text = "Obtendo localização...";
    });
    
    try {
      posicaoAtual = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      
      final endereco = await _converterCoordenadasParaEndereco(
        posicaoAtual!.latitude, 
        posicaoAtual!.longitude
      );
      
      setState(() {
        origemController.text = endereco.isNotEmpty ? endereco : "Localização não encontrada";
        carregandoLocalizacao = false;
      });

    } catch (e) {
      print("Erro ao obter localização atual: $e");
      setState(() {
        origemController.text = "Erro ao obter localização";
        carregandoLocalizacao = false;
      });
    }
  }

  Future<String> _converterCoordenadasParaEndereco(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/reverse?lat=$lat&lon=$lon&apiKey=203ba4a0a4304d349299a8aa22e1dcae'
      );
      
      final response = await http.get(url).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          return data['features'][0]['properties']['formatted'] ?? '';
        }
      } else {
        print("Erro na API Geoapify: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Erro ao converter coordenadas: $e");
    }
    return '';
  }

  void _onFocusChanged() {
    if (!destinoFocus.hasFocus) {
      setState(() {
        sugestoesDestino.clear();
      });
    } else {
      // Quando o campo ganha foco, mostra sugestões se estiver vazio
      if (destinoController.text.isEmpty) {
        _buscarSugestoesPopulares();
      }
    }
  }

  // Função para buscar sugestões populares quando o campo está vazio
  void _buscarSugestoesPopulares() async {
    if (posicaoAtual == null) return;

    try {
      final latAtual = posicaoAtual!.latitude;
      final lonAtual = posicaoAtual!.longitude;

      // Buscar endereços próximos usando autocomplete com termo genérico
      final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/autocomplete?text=shopping&filter=circle:$lonAtual,$latAtual,5000&limit=3&apiKey=203ba4a0a4304d349299a8aa22e1dcae'
      );
      
      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<String> sugestoesPopulares = [];

        if (data['features'] != null) {
          for (var item in data['features']) {
            final endereco = item['properties']['formatted'];
            if (endereco != null && endereco.isNotEmpty) {
              sugestoesPopulares.add(endereco);
            }
          }
        }

        // Se não encontrou com "shopping", tenta com "centro"
        if (sugestoesPopulares.isEmpty) {
          final urlCentro = Uri.parse(
            'https://api.geoapify.com/v1/geocode/autocomplete?text=centro&filter=circle:$lonAtual,$latAtual,10000&limit=3&apiKey=203ba4a0a4304d349299a8aa22e1dcae'
          );
          
          final responseCentro = await http.get(urlCentro).timeout(Duration(seconds: 10));
          
          if (responseCentro.statusCode == 200) {
            final dataCentro = jsonDecode(responseCentro.body);
            if (dataCentro['features'] != null) {
              for (var item in dataCentro['features']) {
                final endereco = item['properties']['formatted'];
                if (endereco != null && endereco.isNotEmpty) {
                  sugestoesPopulares.add(endereco);
                }
              }
            }
          }
        }

        if (destinoFocus.hasFocus && destinoController.text.isEmpty) {
          setState(() {
            sugestoesDestino = sugestoesPopulares.take(3).toList();
          });
        }
      }
    } catch (e) {
      print("Erro ao buscar sugestões populares: $e");
    }
  }

  void _buscarSugestoesDestino(String texto) async {
    if (texto.length < 2) {
      setState(() {
        sugestoesDestino.clear();
      });
      return;
    }
    
    try {
      String filtro = '';
      if (posicaoAtual != null) {
        final latAtual = posicaoAtual!.latitude;
        final lonAtual = posicaoAtual!.longitude;
        filtro = '&filter=circle:$lonAtual,$latAtual,50000'; // 50km de raio
      }

      final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/autocomplete?text=${Uri.encodeComponent(texto)}$filtro&limit=5&apiKey=203ba4a0a4304d349299a8aa22e1dcae'
      );
      
      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, dynamic>> sugestoesComDistancia = [];

        if (data['features'] != null) {
          for (var item in data['features']) {
            final endereco = item['properties']['formatted'];
            if (endereco != null && endereco.isNotEmpty) {
              double distancia = 0;
              
              if (posicaoAtual != null) {
                final coords = item['geometry']['coordinates'];
                final double lonSugestao = coords[0];
                final double latSugestao = coords[1];
                distancia = _calcularDistancia(
                  posicaoAtual!.latitude, 
                  posicaoAtual!.longitude, 
                  latSugestao, 
                  lonSugestao
                );
              }
              
              sugestoesComDistancia.add({
                'endereco': endereco,
                'distancia': distancia,
              });
            }
          }
        }

        // Ordenar por distância se temos posição atual
        if (posicaoAtual != null) {
          sugestoesComDistancia.sort((a, b) => a['distancia'].compareTo(b['distancia']));
        }

        // Só atualiza se o campo ainda tem foco e o texto não mudou
        if (destinoFocus.hasFocus && destinoController.text == texto) {
          setState(() {
            sugestoesDestino = sugestoesComDistancia
                .take(3)
                .map((e) => e['endereco'] as String)
                .toList();
          });
        }
      } else {
        print("Erro na API Geoapify autocomplete: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Erro ao buscar sugestões: $e");
      setState(() {
        sugestoesDestino.clear();
      });
    }
  }

  void _onEnderecoMudou() {
    // Quando o usuário digita, marca que o endereço não foi selecionado da auto-completação
    if (enderecoSelecionado) {
      setState(() {
        enderecoSelecionado = false;
        valorEstimado = "R\$ --,--"; // Reset do valor quando muda o endereço
      });
    }

    if (destinoFocus.hasFocus) {
      if (destinoController.text.isEmpty) {
        _buscarSugestoesPopulares();
        // Reset do valor quando campo fica vazio
        setState(() {
          valorEstimado = "R\$ --,--";
        });
      } else if (destinoController.text.length >= 2) {
        _buscarSugestoesDestino(destinoController.text);
      } else {
        setState(() {
          sugestoesDestino.clear();
          valorEstimado = "R\$ --,--";
        });
      }
    }
  }

  // Função chamada quando o usuário seleciona um endereço da auto-completação
  void _onEnderecoSelecionado(String endereco) {
    setState(() {
      destinoController.text = endereco;
      sugestoesDestino.clear();
      enderecoSelecionado = true;
    });
    FocusScope.of(context).unfocus();
    
    // Calcula o valor após a seleção
    if (posicaoAtual != null && !carregandoLocalizacao) {
      _calcularValorComCoordenadas();
    }
  }

  // Função auxiliar para converter valores para double de forma segura
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Nova função que usa diretamente as coordenadas da posição atual
  Future<void> _calcularValorComCoordenadas() async {
    if (posicaoAtual == null || destinoController.text.isEmpty || !enderecoSelecionado) {
      setState(() {
        valorEstimado = "R\$ --,--";
      });
      return;
    }

    try {
      // Usar coordenadas da posição atual diretamente (não precisa geocodificar origem)
      final coordsOrigem = {
        'lat': posicaoAtual!.latitude,
        'lon': posicaoAtual!.longitude,
      };

      // Obter coordenadas do destino
      final coordsDestino = await _obterCoordenadas(destinoController.text);
      
      if (coordsDestino == null) {
        setState(() {
          valorEstimado = "R\$ --,--";
        });
        return;
      }

      // Calcular distância entre os pontos
      final distancia = _calcularDistancia(
        coordsOrigem['lat']!, 
        coordsOrigem['lon']!, 
        coordsDestino['lat'], 
        coordsDestino['lon']
      );
      
      // Definir bandeira tarifária baseada no horário atual
      final bandeira = _definirBandeiraAtual();
      
      // Buscar tarifas no Firestore
      final tarifas = await _buscarTarifas(bandeira);

      // Extrair valores das tarifas com conversão segura para double
      final double valorBase = _toDouble(tarifas['valor_base']) != 0.0 ? _toDouble(tarifas['valor_base']) : 5.0;
      final double precoKm = _toDouble(tarifas['preco_km']) != 0.0 ? _toDouble(tarifas['preco_km']) : 2.5;
      final double limiteKm = _toDouble(tarifas['limite_km']) != 0.0 ? _toDouble(tarifas['limite_km']) : 1.8;
      final double minMult = _toDouble(tarifas['min_mult']) != 0.0 ? _toDouble(tarifas['min_mult']) : 1.0;
      final double maxMult = _toDouble(tarifas['max_mult']) != 0.0 ? _toDouble(tarifas['max_mult']) : 2.0;

      // Aplicar multiplicador baseado na distância
      final multiplicador = distancia <= limiteKm ? minMult : maxMult;
      
      // Calcular valor final
      final valorFinal = (valorBase + (distancia * precoKm)) * multiplicador;

      // Atualizar interface com o valor calculado
      setState(() {
        valorEstimado = "R\$ ${valorFinal.toStringAsFixed(2)}";
      });

      print("Cálculo realizado: Distância: ${distancia.toStringAsFixed(2)}km, Valor: R\$ ${valorFinal.toStringAsFixed(2)}");
    } catch (e) {
      print("Erro no cálculo: $e");
      setState(() {
        valorEstimado = "R\$ --,--";
      });
    }
  }

  Future<Map<String, dynamic>?> _obterCoordenadas(String endereco) async {
    try {
      final url = Uri.parse(
        'https://api.geoapify.com/v1/geocode/search?text=${Uri.encodeComponent(endereco)}&apiKey=203ba4a0a4304d349299a8aa22e1dcae'
      );
      
      final response = await http.get(url).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final coords = data['features'][0]['geometry']['coordinates'];
          return {'lon': coords[0], 'lat': coords[1]};
        }
      }
    } catch (e) {
      print("Erro ao obter coordenadas: $e");
    }
    return null;
  }

  double _calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Raio da Terra em km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) + 
              cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * 
              sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  String _definirBandeiraAtual() {
    final now = DateTime.now();
    final hora = now.hour;
    final diaSemana = now.weekday;
    
    // Domingo (7)
    if (diaSemana == 7) return 'bandeira3';
    
    // Sábado (6)
    if (diaSemana == 6) return (hora >= 4 && hora < 18) ? 'bandeira2' : 'bandeira3';
    
    // Segunda a sexta (1-5)
    if (hora >= 4 && hora < 18) return 'bandeira1';  // Manhã/tarde
    if (hora >= 18 && hora < 24) return 'bandeira2'; // Noite
    return 'bandeira3'; // Madrugada
  }

  Future<Map<String, dynamic>> _buscarTarifas(String bandeira) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('tarifas')
          .doc(bandeira)
          .get();
      
      if (doc.exists) {
        return doc.data() ?? {};
      }
      
      // Fallback para configuração dinâmica
      final fallback = await FirebaseFirestore.instance
          .collection('tarifas')
          .doc('config_dinamica')
          .get();
      
      return fallback.data() ?? {};
    } catch (e) {
      print("Erro ao buscar tarifas: $e");
      return {
        'valor_base': 5.0,
        'preco_km': 2.5,
        'limite_km': 1.8,
        'min_mult': 1.0,
        'max_mult': 2.0,
      };
    }
  }

  // Navegar para a tela de pagamento
  void _navegarParaPagamento() {
    print("Botão clicado! Verificando dados...");
    print("Dados completos: $_dadosCompletos");
    print("Valor estimado: $valorEstimado");
    print("Endereço selecionado: $enderecoSelecionado");
    
    // Verificar se há um valor calculado e endereços válidos
    if (!_dadosCompletos) {
      String mensagem = "Por favor, ";
      if (carregandoLocalizacao) {
        mensagem += "aguarde a localização ser obtida";
      } else if (origemController.text.isEmpty) {
        mensagem += "aguarde a localização de origem";
      } else if (destinoController.text.isEmpty) {
        mensagem += "selecione um destino";
      } else if (!enderecoSelecionado) {
        mensagem += "selecione um destino da lista de sugestões";
      } else if (valorEstimado == "R\$ --,--") {
        mensagem += "aguarde o cálculo do valor";
      } else {
        mensagem += "verifique os dados inseridos";
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    print("Navegando para a tela de pagamento...");
    
    // Navegar para a tela de pagamento
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PagamentoScreen(
          valorCorrida: valorEstimado,
          enderecoOrigem: origemController.text,
          enderecoDestino: destinoController.text,
        ),
      ),
    ).then((result) {
      print("Retornou da tela de pagamento: $result");
    }).catchError((error) {
      print("Erro ao navegar: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao abrir tela de pagamento'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Confirmação de Corrida")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: origemController,
              decoration: InputDecoration(
                labelText: "Onde você está?",
                prefixIcon: carregandoLocalizacao 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Icon(Icons.my_location, color: Colors.green),                suffixIcon: !carregandoLocalizacao 
                    ? IconButton(
                        icon: Icon(Icons.refresh, color: Colors.purple),
                        onPressed: _verificarPermissoesEObterLocalizacao,
                      )
                    : null,
              ),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: destinoController,
              focusNode: destinoFocus,
              decoration: InputDecoration(
                labelText: "Para onde você vai?",
                prefixIcon: Icon(Icons.search, color: Colors.blue),
                hintText: "Digite ou clique para ver sugestões",
              ),
            ),
            if (sugestoesDestino.isNotEmpty && destinoFocus.hasFocus)
              Container(
                margin: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                constraints: BoxConstraints(maxHeight: 180),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: sugestoesDestino.length,
                  separatorBuilder: (context, index) => 
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      leading: Icon(Icons.location_on, color: Colors.blue, size: 20),
                      title: Text(
                        sugestoesDestino[index],
                        style: TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: posicaoAtual != null 
                          ? Icon(Icons.near_me, color: Colors.green, size: 16)
                          : null,
                      onTap: () {
                        _onEnderecoSelecionado(sugestoesDestino[index]);
                      },
                    );
                  },
                ),
              ),
            SizedBox(height: 20),
            Text(
              "Valor estimado da corrida: $valorEstimado",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            Spacer(),
            // BOTÃO COM COR LARANJA DA IDENTIDADE VISUAL
            Padding(
              padding: EdgeInsets.only(bottom: 5.0), // Subir meio centímetro
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25), // Bordas mais arredondadas como na imagem
                  color: _dadosCompletos 
                      ? Color(0xFFFF5722) // Laranja quando dados completos (cor da identidade visual)
                      : Colors.grey[400], // Cinza quando incompleto
                  boxShadow: _dadosCompletos ? [
                    BoxShadow(
                      color: Color(0xFFFF5722).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ] : [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _dadosCompletos ? _navegarParaPagamento : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    disabledBackgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    "Solicitar Corrida",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

