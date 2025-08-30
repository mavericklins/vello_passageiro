import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

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
    final nome = nomeController.text.trim();
    if (!isNomeValido(nome)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe nome e sobrenome')));
      return;
    }
    final cpf = cpfController.text.trim();
    if (!isCpfValido(cpf)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CPF inválido')));
      return;
    }
    final celular = celularController.text.trim();
    final email = emailController.text.trim();
    if (!isEmailValido(email)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('E-mail inválido')));
      return;
    }
    final senha = senhaController.text.trim();
    if (!isSenhaForte(senha)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A senha deve conter entre 8 e 20 caracteres, com letra maiúscula, minúscula, número e caractere especial',
          ),
        ),
      );

      return;
    }

    if (nome.isEmpty ||
        cpf.isEmpty ||
        celular.isEmpty ||
        email.isEmpty ||
        senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos')),
      );
      return;
    }

    final firestore = FirebaseFirestore.instance;

    final cpfExistente = await firestore
        .collection('passageiros')
        .where('cpf', isEqualTo: cpf)
        .get();

    if (cpfExistente.docs.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CPF já cadastrado')));
      return;
    }

    final emailExistente = await firestore
        .collection('passageiros')
        .where('email', isEqualTo: email.toLowerCase())
        .get();

    if (emailExistente.docs.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('E-mail já cadastrado')));
      return;
    }

    try {
      String? urlImagem;

      if (_imagemSelecionada != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
          'fotos_perfil/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await storageRef.putFile(_imagemSelecionada!);
        urlImagem = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('passageiros').add({
        'nome': nome,
        'cpf': cpf,
        'celular': celular,
        'email': email.toLowerCase(),
        'senha': senha,
        'foto_url': urlImagem,
        'criado_em': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Erro ao salvar cadastro: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao salvar cadastro')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            if (_imagemSelecionada != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: FileImage(_imagemSelecionada!),
              )
            else
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 50),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Galeria"),
                  onPressed: _escolherImagem,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Câmera"),
                  onPressed: _tirarFoto,
                ),
              ],
            ),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome completo'),
            ),
            TextField(
              controller: cpfController,
              decoration: const InputDecoration(labelText: 'CPF'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CpfInputFormatter(), // será criado abaixo
              ],
            ),
            TextField(
              controller: celularController,
              decoration: const InputDecoration(labelText: 'Celular'),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TelefoneInputFormatter(), // será criado abaixo
              ],
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: senhaController,
              obscureText: !_senhaVisivel,
              decoration: InputDecoration(
                labelText: 'Senha',
                suffixIcon: IconButton(
                  icon: Icon(
                    _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _senhaVisivel = !_senhaVisivel;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: salvarCadastro,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text('Registrar', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length > 11) digitsOnly = digitsOnly.substring(0, 11);

    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 3 || i == 6) formatted += '.';
      if (i == 9) formatted += '-';
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length > 11) digitsOnly = digitsOnly.substring(0, 11);

    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 0) formatted += '(';
      if (i == 2) formatted += ') ';
      if (i == 7) formatted += '-';
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

bool isCpfValido(String cpf) {
  String numbers = cpf.replaceAll(RegExp(r'\D'), '');

  if (numbers.length != 11 || RegExp(r'^(\d)\1*$').hasMatch(numbers))
    return false;

  List<int> digits = numbers.split('').map(int.parse).toList();

  for (int j = 9; j < 11; j++) {
    int sum = 0;
    for (int i = 0; i < j; i++) {
      sum += digits[i] * ((j + 1) - i);
    }
    int checkDigit = (sum * 10) % 11;
    if (checkDigit == 10) checkDigit = 0;
    if (checkDigit != digits[j]) return false;
  }

  return true;
}

bool isEmailValido(String email) {
  final regex = RegExp(r"^[\w\.-]+@[\w\.-]+\.\w+$");
  return regex.hasMatch(email);
}

bool isNomeValido(String nome) {
  return nome.trim().split(' ').length >= 2;
}

bool isSenhaForte(String senha) {
  if (senha.length < 8 || senha.length > 20) return false;

  final hasUpper = RegExp(r'[A-Z]');
  final hasLower = RegExp(r'[a-z]');
  final hasDigit = RegExp(r'\d');
  final hasSpecial = RegExp(r'[!@#\$&*~_+=\-\[\](){}<>?,.:;]');

  return hasUpper.hasMatch(senha) &&
      hasLower.hasMatch(senha) &&
      hasDigit.hasMatch(senha) &&
      hasSpecial.hasMatch(senha);
}
