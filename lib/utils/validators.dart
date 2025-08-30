import 'dart:core';

/// Classe utilitária para validações de formulários
/// Centraliza todas as validações com regex robusto e sanitização
class Validators {
  
  // ===== VALIDAÇÃO DE EMAIL =====
  
  /// Regex robusto para validação de email seguindo RFC 5322
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
  );
  
  /// Valida formato de email
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    // Sanitizar: remover espaços e converter para lowercase
    final sanitized = email.trim().toLowerCase();
    
    // Validações adicionais
    if (sanitized.length > 254) return false; // RFC limite
    if (sanitized.contains('..')) return false; // Pontos consecutivos
    if (sanitized.startsWith('.') || sanitized.endsWith('.')) return false;
    
    return _emailRegex.hasMatch(sanitized);
  }
  
  /// Sanitiza email removendo espaços e convertendo para lowercase
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }
  
  // ===== VALIDAÇÃO DE TELEFONE =====
  
  /// Regex para telefone brasileiro (celular e fixo)
  static final RegExp _phoneRegex = RegExp(r'^(\+55|55)?[\s-]?(\(?\d{2}\)?[\s-]?)[\s-]?(\d{4,5})[\s-]?(\d{4})$');
  
  /// Valida telefone brasileiro (com ou sem código do país)
  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    
    // Remover formatação para validação
    final sanitized = sanitizePhone(phone);
    
    // Deve ter pelo menos 10 dígitos (DDD + número)
    if (sanitized.length < 10 || sanitized.length > 13) return false;
    
    // Validar DDD (11-99)
    final ddd = sanitized.length >= 11 ? 
      int.tryParse(sanitized.substring(0, 2)) : 
      int.tryParse(sanitized.substring(0, 2));
    
    if (ddd == null || ddd < 11 || ddd > 99) return false;
    
    return _phoneRegex.hasMatch(phone);
  }
  
  /// Sanitiza telefone removendo caracteres não numéricos
  static String sanitizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }
  
  /// Formata telefone brasileiro
  static String formatPhone(String phone) {
    final sanitized = sanitizePhone(phone);
    
    if (sanitized.length == 10) {
      // Telefone fixo: (XX) XXXX-XXXX
      return '(${sanitized.substring(0, 2)}) ${sanitized.substring(2, 6)}-${sanitized.substring(6)}';
    } else if (sanitized.length == 11) {
      // Celular: (XX) XXXXX-XXXX
      return '(${sanitized.substring(0, 2)}) ${sanitized.substring(2, 7)}-${sanitized.substring(7)}';
    }
    
    return phone; // Retorna original se não conseguir formatar
  }
  
  // ===== VALIDAÇÃO DE CPF =====
  
  /// Valida CPF usando algoritmo oficial
  static bool isValidCPF(String cpf) {
    if (cpf.isEmpty) return false;
    
    // Sanitizar removendo formatação
    final sanitized = sanitizeCPF(cpf);
    
    // Deve ter exatamente 11 dígitos
    if (sanitized.length != 11) return false;
    
    // Rejeitar CPFs com todos os dígitos iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(sanitized)) return false;
    
    // Validar dígitos verificadores
    final digits = sanitized.split('').map(int.parse).toList();
    
    // Validar primeiro dígito
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += digits[i] * (10 - i);
    }
    int remainder = sum % 11;
    int firstDigit = remainder < 2 ? 0 : 11 - remainder;
    
    if (digits[9] != firstDigit) return false;
    
    // Validar segundo dígito
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += digits[i] * (11 - i);
    }
    remainder = sum % 11;
    int secondDigit = remainder < 2 ? 0 : 11 - remainder;
    
    return digits[10] == secondDigit;
  }
  
  /// Sanitiza CPF removendo formatação
  static String sanitizeCPF(String cpf) {
    return cpf.replaceAll(RegExp(r'[^\d]'), '');
  }
  
  /// Formata CPF: XXX.XXX.XXX-XX
  static String formatCPF(String cpf) {
    final sanitized = sanitizeCPF(cpf);
    
    if (sanitized.length == 11) {
      return '${sanitized.substring(0, 3)}.${sanitized.substring(3, 6)}.${sanitized.substring(6, 9)}-${sanitized.substring(9)}';
    }
    
    return cpf;
  }
  
  // ===== VALIDAÇÃO DE SENHA =====
  
  /// Valida senha forte com critérios rigorosos
  static bool isValidPassword(String password) {
    if (password.isEmpty) return false;
    
    // Deve ter entre 8 e 20 caracteres
    if (password.length < 8 || password.length > 20) return false;
    
    // Deve conter pelo menos:
    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>_+=\-\[\]\\;/~`]').hasMatch(password);
    
    return hasUpperCase && hasLowerCase && hasDigit && hasSpecialChar;
  }
  
  /// Verifica força da senha (0-4)
  static int getPasswordStrength(String password) {
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'\d').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>_+=\-\[\]\\;/~`]').hasMatch(password)) strength++;
    
    return strength;
  }
  
  // ===== VALIDAÇÃO DE NOME =====
  
  /// Valida nome completo (pelo menos nome e sobrenome)
  static bool isValidFullName(String name) {
    if (name.isEmpty) return false;
    
    final sanitized = name.trim();
    
    // Deve ter pelo menos 2 palavras
    final words = sanitized.split(RegExp(r'\s+'));
    if (words.length < 2) return false;
    
    // Cada palavra deve ter pelo menos 2 caracteres
    for (final word in words) {
      if (word.length < 2) return false;
      // Deve conter apenas letras e alguns caracteres especiais
      if (!RegExp(r'^[a-zA-ZÀ-ÿ\s\'-]+$').hasMatch(word)) return false;
    }
    
    return true;
  }
  
  /// Sanitiza nome removendo espaços extras e padronizando
  static String sanitizeName(String name) {
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
  
  // ===== VALIDAÇÃO DE CARTÃO DE CRÉDITO =====
  
  /// Valida número de cartão usando algoritmo de Luhn
  static bool isValidCreditCard(String cardNumber) {
    if (cardNumber.isEmpty) return false;
    
    final sanitized = sanitizeCreditCard(cardNumber);
    
    // Deve ter entre 13 e 19 dígitos
    if (sanitized.length < 13 || sanitized.length > 19) return false;
    
    // Algoritmo de Luhn
    int sum = 0;
    bool alternate = false;
    
    for (int i = sanitized.length - 1; i >= 0; i--) {
      int digit = int.parse(sanitized[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }
  
  /// Sanitiza número do cartão removendo espaços e formatação
  static String sanitizeCreditCard(String cardNumber) {
    return cardNumber.replaceAll(RegExp(r'[^\d]'), '');
  }
  
  /// Formata número do cartão: XXXX XXXX XXXX XXXX
  static String formatCreditCard(String cardNumber) {
    final sanitized = sanitizeCreditCard(cardNumber);
    
    if (sanitized.length >= 16) {
      return '${sanitized.substring(0, 4)} ${sanitized.substring(4, 8)} ${sanitized.substring(8, 12)} ${sanitized.substring(12, 16)}';
    }
    
    return cardNumber;
  }
  
  /// Valida data de validade do cartão (MM/AA)
  static bool isValidExpiryDate(String expiryDate) {
    if (expiryDate.isEmpty) return false;
    
    final sanitized = expiryDate.replaceAll(RegExp(r'[^\d]'), '');
    
    if (sanitized.length != 4) return false;
    
    final month = int.tryParse(sanitized.substring(0, 2));
    final year = int.tryParse(sanitized.substring(2, 4));
    
    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;
    
    // Validar se não expirou
    final now = DateTime.now();
    final currentYear = now.year % 100; // Últimos 2 dígitos
    final currentMonth = now.month;
    
    if (year < currentYear) return false;
    if (year == currentYear && month < currentMonth) return false;
    
    return true;
  }
  
  /// Valida CVV do cartão
  static bool isValidCVV(String cvv) {
    if (cvv.isEmpty) return false;
    
    final sanitized = cvv.replaceAll(RegExp(r'[^\d]'), '');
    
    // CVV deve ter 3 ou 4 dígitos
    return sanitized.length == 3 || sanitized.length == 4;
  }
  
  // ===== VALIDAÇÕES GERAIS =====
  
  /// Valida se campo obrigatório não está vazio
  static bool isRequired(String value) {
    return value.trim().isNotEmpty;
  }
  
  /// Valida comprimento mínimo
  static bool hasMinLength(String value, int minLength) {
    return value.trim().length >= minLength;
  }
  
  /// Valida comprimento máximo
  static bool hasMaxLength(String value, int maxLength) {
    return value.trim().length <= maxLength;
  }
}