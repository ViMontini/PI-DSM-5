import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String getMonthName(int month) {
  switch (month) {
    case 1:
      return 'Janeiro';
    case 2:
      return 'Fevereiro';
    case 3:
      return 'Março';
    case 4:
      return 'Abril';
    case 5:
      return 'Maio';
    case 6:
      return 'Junho';
    case 7:
      return 'Julho';
    case 8:
      return 'Agosto';
    case 9:
      return 'Setembro';
    case 10:
      return 'Outubro';
    case 11:
      return 'Novembro';
    case 12:
      return 'Dezembro';
    default:
      return '';
  }
}

String getGreeting(int hour) {
  if (hour < 12) {
    return 'bom dia';
  } else if (hour < 18) {
    return 'boa tarde';
  } else {
    return 'boa noite';
  }
}

String formatarData(String dataString) {
  // Formato de entrada da string de data
  final DateFormat formatoEntrada = DateFormat('yyyy-MM-dd HH:mm:ss');
  // Formato de saída desejado
  final DateFormat formatoSaida = DateFormat('dd/MM/yyyy');

  // Converter a string de data para DateTime
  final DateTime data = formatoEntrada.parse(dataString);

  // Formatar a data para o formato desejado
  return formatoSaida.format(data);
}


