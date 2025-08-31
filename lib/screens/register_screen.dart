import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/strings.dart';
import '../theme/vello_tokens.dart';
import '../utils/validators.dart';
import '../../core/error_handler.dart';
import '../../core/logger_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool _senhaVisivel = false;
  File? _imagemSelecionada;

  // Cores da identidade visual Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;
  static const Color velloCardBackground = VelloTokens.white;

  Future<void> _escolherImagem() async {
    final picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (imagem != null) {
      setState(() {
        _imagemSelecionada = File(imagem.path);
      });
    }
  }

  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    final XFile? foto = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (foto != null) {
      setState(() {
        _imagemSelecionada = File(foto.path);
      });
    }
  }

  Future<void> salvarCadastro() async {
    final nome = Validators.sanitizeName(nomeController.text);
    final cpf = Validators.sanitizeCPF(cpfController.text);
    final celular = Validators.sanitizePhone(celularController.text);
    final email = Validators.sanitizeEmail(emailController.text);
    final senha = senhaController.text.trim();

    if (!Validators.isValidFullName(nome)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.erroNomeCompleto,
            style: TextStyle(color: VelloTokens.white),
          ),
          backgroundColor: velloOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
      return;
    }

    if (!Validators.isValidCPF(cpf)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.erroCpfInvalido,
            style: TextStyle(color: VelloTokens.white),
          ),
          backgroundColor: velloOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
      return;
    }

    if (!Validators.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.erroEmailInvalido,
            style: TextStyle(color: VelloTokens.white),
          ),
          backgroundColor: velloOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
      return;
    }

    if (!Validators.isValidPassword(senha)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.erroSenhaForte,
            style: TextStyle(color: VelloTokens.white),
          ),
          backgroundColor: velloOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
      return;
    }

    if (nome.isEmpty || cpf.isEmpty || celular.isEmpty || email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.erroCamposObrigatorios,
            style: TextStyle(color: VelloTokens.white),
          ),
          backgroundColor: velloOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
      return;
    }

    final firestore = FirebaseFirestore.instance;

    final cpfExistente = await firestore
        .collection('passageiros')
        .where('cpf', isEqualTo: cpf)
        .get();

    if (cpfExistente.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.erroCpfJaCadastrado,
            style: TextStyle(color: VelloTokens.white),
          ),
          backgroundColor: velloOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
      return;
    }

    final emailExistente = await firestore
        .collection('passageiros')
        .where('email', isEqualTo: email)
        .get();

    if (emailExistente.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.erroEmailJaCadastrado,
            style: TextStyle(color: VelloTokens.white),
          ),
          backgroundColor: velloOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
      return;
    }

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      String? urlImagem;

      if (_imagemSelecionada != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
          'fotos_perfil/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await storageRef.putFile(_imagemSelecionada!);
        urlImagem = await storageRef.getDownloadURL();
      }

      await firestore.collection('passageiros').doc(cred.user!.uid).set({
        'nome': nome,
        'cpf': cpf,
        'celular': celular,
        'email': email,
        'foto_url': urlImagem,
        'criado_em': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.cadastroRealizadoSucesso,
            style: TextStyle(color: VelloTokens.white),
          ),
          backgroundColor: velloBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      LoggerService.info('Erro ao salvar cadastro: $e', context: 'Service');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.erroSalvarCadastro,
            style: TextStyle(color: VelloTokens.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
        ),
      );
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    cpfController.dispose();
    celularController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Scaffold(
      // Mesmo fundo gradiente da load_screen e login_screen
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              velloCardBackground, // Branco no topo
              velloLightGray, // Cinza claro no meio
              velloCardBackground, // Branco na base
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header personalizado
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: velloCardBackground,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: VelloTokens.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: velloOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: velloOrange,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.tituloCriarConta,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: velloBlue,
                            ),
                          ),
                          Text(
                            AppStrings.subtituloCriarConta,
                            style: TextStyle(
                              fontSize: 14,
                              color: velloBlue.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Conteúdo scrollável
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: keyboardOpen ? 10 : 20,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Column(
                          children: [
                            // Avatar de perfil - menor quando o teclado está aberto
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: keyboardOpen ? 40 : 60,
                                    backgroundColor: velloOrange.withOpacity(0.2),
                                    backgroundImage: _imagemSelecionada != null
                                        ? FileImage(_imagemSelecionada!) as ImageProvider
                                        : null,
                                    child: _imagemSelecionada == null
                                        ? Icon(
                                            Icons.person, 
                                            size: keyboardOpen ? 40 : 60, 
                                            color: velloOrange
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          backgroundColor: velloCardBackground,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          builder: (BuildContext context) {
                                            return SafeArea(
                                              child: Padding(
                                                padding: const EdgeInsets.all(20),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(
                                                      AppStrings.escolherFoto,
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: velloBlue,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: _buildPhotoOption(
                                                            icon: Icons.photo_library,
                                                            label: AppStrings.galeria,
                                                            onTap: () {
                                                              _escolherImagem();
                                                              Navigator.pop(context);
                                                            },
                                                          ),
                                                        ),
                                                        const SizedBox(width: 16),
                                                        Expanded(
                                                          child: _buildPhotoOption(
                                                            icon: Icons.camera_alt,
                                                            label: AppStrings.camera,
                                                            onTap: () {
                                                              _tirarFoto();
                                                              Navigator.pop(context);
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: velloOrange,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: VelloTokens.white, width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: velloOrange.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.camera_alt, 
                                          color: VelloTokens.white, 
                                          size: keyboardOpen ? 16 : 20
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: keyboardOpen ? 15 : 20),
                            
                            // Campos de texto com sombras suaves
                            _buildTextField(nomeController, 'Nome completo', Icons.person),
                            const SizedBox(height: 15),
                            _buildTextField(cpfController, 'CPF', Icons.credit_card, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, CpfInputFormatter()]),
                            const SizedBox(height: 15),
                            _buildTextField(celularController, 'Celular', Icons.phone, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly, TelefoneInputFormatter()]),
                            const SizedBox(height: 15),
                            _buildTextField(emailController, 'E-mail', Icons.email, keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 15),
                            _buildPasswordField(senhaController, 'Senha'),
                            
                            SizedBox(height: keyboardOpen ? 20 : 30),
                            
                            // Botão de Registrar com gradiente
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [velloOrange, velloOrange.withOpacity(0.8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: velloOrange.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: salvarCadastro,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  AppStrings.botaoRegistrar,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: VelloTokens.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: keyboardOpen ? 10 : 20),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                AppStrings.jaTemConta,
                                style: TextStyle(
                                  color: velloBlue,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                  decorationColor: velloBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: velloOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: velloOrange.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: velloOrange, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: velloBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon, {TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: VelloTokens.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: velloBlue),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: velloBlue.withOpacity(0.8)),
          filled: true,
          fillColor: velloCardBackground,
          prefixIcon: Icon(icon, color: velloOrange),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: velloOrange, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String labelText) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: VelloTokens.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: !_senhaVisivel,
        style: const TextStyle(color: velloBlue),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: velloBlue.withOpacity(0.8)),
          filled: true,
          fillColor: velloCardBackground,
          prefixIcon: const Icon(Icons.lock, color: velloOrange),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: velloOrange, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          suffixIcon: IconButton(
            icon: Icon(
              _senhaVisivel ? Icons.visibility_off : Icons.visibility,
              color: velloOrange,
            ),
            onPressed: () {
              setState(() {
                _senhaVisivel = !_senhaVisivel;
              });
            },
          ),
        ),
      ),
    );
  }
}

// Formatadores de input usando os validadores centralizados
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String sanitized = Validators.sanitizeCPF(newValue.text);
    if (sanitized.length > 11) sanitized = sanitized.substring(0, 11);
    
    String formatted = Validators.formatCPF(sanitized);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String sanitized = Validators.sanitizePhone(newValue.text);
    if (sanitized.length > 11) sanitized = sanitized.substring(0, 11);
    
    String formatted = Validators.formatPhone(sanitized);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

