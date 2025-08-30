import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_permanente_service.dart';
import '../core/logger_service.dart';
import '../core/error_handler.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  
  String get userName {
    final user = currentUser;
    return user?.displayName ?? user?.email?.split('@')[0] ?? 'Usuário';
  }

  String get userEmail => currentUser?.email ?? '';

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      LoggerService.success('Login realizado com sucesso', context: 'AUTH');
      notifyListeners();
      return true;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'auth_signin');
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (displayName != null && credential.user != null) {
        await credential.user?.updateDisplayName(displayName);
      }
      
      LoggerService.success('Cadastro realizado com sucesso', context: 'AUTH');
      notifyListeners();
      return true;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'auth_signup');
      return false;
    }
  }

  Future<void> signOut() async {
    // Usar o logout seguro que limpa tudo
    await AuthPermanenteService.logout();
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      LoggerService.success('Email de redefinição enviado', context: 'AUTH');
      return true;
    } catch (e) {
      ErrorHandler.handleError(e, context: 'auth_reset_password');
      return false;
    }
  }
}