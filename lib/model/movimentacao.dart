import 'package:intl/intl.dart';

class Movimentacao {
   final int id;
   final String data;
   final int tipo;
   final double valor;
   final String categoria;
   final String? descricao;
   final int recorrente;

  Movimentacao({
    required this.id,
    required this.data,
    required this.tipo,
    required this.valor,
    required this.categoria,
    this.descricao,
    required this.recorrente,
  });

   factory Movimentacao.fromSqfliteDatabase(Map<String, dynamic> map) => Movimentacao(
     id: map['id']?.toInt() ?? 0,
     data: map['data'] ?? '',
     tipo: map['tipo'] ?? '',
     valor: map['valor'] ?? 0,
     categoria: map['categoria'] ?? '',
     descricao: map['descricao'] ?? '',
     recorrente: map['recorrente'] ?? 0,
   );

}
