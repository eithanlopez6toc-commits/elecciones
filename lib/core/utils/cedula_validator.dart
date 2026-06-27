// lib/core/utils/cedula_validator.dart

/// Validador de cédula de identidad ecuatoriana.
/// Implementa el algoritmo de módulo 10 del Registro Civil.
class CedulaValidator {
  /// Retorna true si la cédula es válida.
  static bool isValid(String cedula) {
    final sanitized = cedula.trim();
    if (!RegExp(r'^\d{10}$').hasMatch(sanitized)) return false;

    final digits = sanitized.split('').map(int.parse).toList();
    final province = int.parse(sanitized.substring(0, 2));
    if (province < 1 || province > 24) return false;

    final lastDigit = digits[9];
    int sum = 0;
    for (var i = 0; i < 9; i++) {
      final value = digits[i] * (i % 2 == 0 ? 2 : 1);
      sum += value > 9 ? value - 9 : value;
    }

    final validator = (10 - (sum % 10)) % 10;
    return validator == lastDigit;
  }

  /// Para usar como validator en TextFormField.
  /// Retorna null si es válida, o el mensaje de error si no.
  static String? validate(String? cedula) {
    if (cedula == null || cedula.trim().isEmpty) {
      return 'La cédula es obligatoria';
    }
    final sanitized = cedula.trim();
    if (sanitized.length != 10) {
      return 'Debe tener 10 dígitos (ingresaste ${sanitized.length})';
    }
    if (!isValid(sanitized)) {
      return 'Cédula ecuatoriana no válida';
    }
    return null;
  }
}