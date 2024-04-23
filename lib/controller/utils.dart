import 'package:flutter/material.dart';

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

Future<String?> adicionarEvento(BuildContext context, DateTime selectedDay) async {
  String? evento;
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Adicionar Evento'),
        content: TextField(
          onChanged: (value) {
            evento = value;
          },
          decoration: InputDecoration(hintText: 'Digite o evento'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, evento); // Retorna o evento adicionado ao fechar o dialog
            },
            child: Text('Salvar'),
          ),
        ],
      );
    },
  );
  return evento; // Retorna o evento adicionado
}


