class CedulaValidator {
  /// Valida un número de cédula ecuatoriano.
  ///
  /// Requiere 10 dígitos y aplica la regla de verificación.
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
}