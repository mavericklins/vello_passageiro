import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/strings.dart';
import '../services/secure_storage_service.dart';
import '../theme/vello_tokens.dart';
import '../utils/validators.dart';
import '../../core/error_handler.dart';
import '../../core/logger_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Cores Vello
  static const Color velloBlue = VelloTokens.brandBlue;
  static const Color velloOrange = VelloTokens.brandOrange;
  static const Color velloLightGray = VelloTokens.grayLight;

  @override
  void initState() {
    super.initState();
    _carregarCredenciaisSalvas();
  }

  Future<void> _carregarCredenciaisSalvas() async {
    try {
      // Carregar dados seguros do "lembrar-me"
      final rememberMeData = await SecureStorageService.getRememberMeData();
      final emailSalvo = rememberMeData['email'];
      final rememberMe = rememberMeData['rememberMe'] == 'true';
      
      if (rememberMe && emailSalvo != null) {
        setState(() {
          _emailController.text = emailSalvo;
          _rememberMe = true;
        });
        LoggerService.info('📧 Email carregado do armazenamento seguro: $emailSalvo', context: context ?? 'UNKNOWN');
      }
    } catch (e) {
      LoggerService.warning(' Erro ao carregar credenciais: $e', context: context ?? 'UNKNOWN');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      LoggerService.info('🔐 Iniciando login para: ${_emailController.text}', context: context ?? 'UNKNOWN');
      
      // Fazer login no Firebase com email sanitizado
      final sanitizedEmail = Validators.sanitizeEmail(_emailController.text);
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: sanitizedEmail,
        password: _passwordController.text,
      );

      if (credential.user != null) {
        LoggerService.success(' Login bem-sucedido: ${credential.user!.email}', context: context ?? 'UNKNOWN');
        
        // Salvar token seguro e dados "lembrar-me"
        await _salvarDadosSegurosPosLogin(credential.user!);
        
        // Mostrar sucesso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.loginRealizadoSucesso),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Navegar para home
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }

    } on FirebaseAuthException catch (e) {
      String mensagemErro;
      
      switch (e.code) {
        case 'user-not-found':
          mensagemErro = AppStrings.erroUsuarioNaoEncontrado;
          break;
        case 'wrong-password':
          mensagemErro = AppStrings.erroSenhaIncorreta;
          break;
        case 'invalid-email':
          mensagemErro = AppStrings.erroEmailInvalido;
          break;
        case 'user-disabled':
          mensagemErro = AppStrings.erroContaDesabilitada;
          break;
        case 'too-many-requests':
          mensagemErro = AppStrings.erroMuitasTentativas;
          break;
        default:
          mensagemErro = 'Erro no login: ${e.message}';
      }
      
      LoggerService.error(' Erro de autenticação: ${e.code} - $mensagemErro', context: context ?? 'UNKNOWN');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagemErro),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
      
    } catch (e) {
      LoggerService.error(' Erro inesperado no login: $e', context: context ?? 'UNKNOWN');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.erroInesperado),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Salva dados seguros pós-login (SEM SENHA EM TEXTO PLANO)
  Future<void> _salvarDadosSegurosPosLogin(User user) async {
    try {
      // 1. Salvar token seguro baseado no UID do usuário
      await SecureStorageService.saveAuthToken(user.uid);
      
      // 2. Salvar dados "lembrar-me" se solicitado (apenas email)
      await SecureStorageService.saveRememberMeData(
        _emailController.text.trim(), 
        _rememberMe
      );
      
      // 3. Salvar dados básicos no SharedPreferences (dados não-sensíveis)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', _emailController.text.trim());
      await prefs.setBool('user_logged_in', true);
      await prefs.setString('ultimo_login', DateTime.now().toIso8601String());
      
      LoggerService.info('🔐 Dados seguros salvos - Token: ✓, Email: ✓, Sem senha em texto plano', context: context ?? 'UNKNOWN');
      
    } catch (e) {
      LoggerService.warning(' Erro ao salvar dados seguros: $e', context: context ?? 'UNKNOWN');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60),
              
              // Logo Vello
              Container(
                height: 120,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: velloOrange,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: velloOrange.withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_taxi,
                        color: VelloTokens.white,
                        size: 40,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: velloBlue,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 40),
              
              // Título
              Text(
                AppStrings.tituloLogin,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: velloBlue,
                ),
                textAlign: TextAlign.center,
              ),
              
              Text(
                AppStrings.subtituloLogin,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 40),
              
              // Formulário
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Campo Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: AppStrings.labelEmail,
                        prefixIcon: Icon(Icons.email, color: velloOrange),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: velloOrange, width: 2),
                        ),
                        filled: true,
                        fillColor: VelloTokens.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.erroEmailObrigatorio;
                        }
                        if (!Validators.isValidEmail(value)) {
                          return AppStrings.erroEmailInvalido;
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Campo Senha
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: AppStrings.labelSenha,
                        prefixIcon: Icon(Icons.lock, color: velloOrange),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: velloOrange, width: 2),
                        ),
                        filled: true,
                        fillColor: VelloTokens.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.erroSenhaObrigatoria;
                        }
                        if (value.length < 6) {
                          return AppStrings.erroSenhaMinima;
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Checkbox "Lembrar-me"
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: velloOrange,
                        ),
                        Text(
                          AppStrings.lembrarMe,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            // Implementar "Esqueceu a senha?"
                          },
                          child: Text(
                            AppStrings.esqueceuSenha,
                            style: TextStyle(
                              color: velloOrange,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Botão Login
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: velloOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: VelloTokens.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                AppStrings.botaoEntrar,
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
              
              SizedBox(height: 30),
              
              // Link para registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.naoTemConta,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                    child: Text(
                      AppStrings.linkCadastrese,
                      style: TextStyle(
                        color: velloOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Informação sobre login seguro
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.green, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.infoSeguranca,
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}