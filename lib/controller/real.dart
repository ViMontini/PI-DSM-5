import 'package:intl/intl.dart';


class Real {

  double parseValor(String valor) {
    String novoValor = valor.replaceAll(',', '.');
    return double.tryParse(novoValor) ?? 0.0;
  }

  String formatValor(double valor) {
    final formatter = NumberFormat('#,##0.00', 'pt_BR');
    return formatter.format(valor);
  }

}

