import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MoedaTextInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: 'R\$ 0,00');
    }

    // Remove todos os caracteres que não são números
    String cleanedValue = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Adiciona os dois últimos dígitos como centavos
    double value = double.parse(cleanedValue) / 100;

    // Formata o valor como moeda
    String formattedValue = _formatter.format(value);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
