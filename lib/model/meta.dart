import 'package:intl/intl.dart';

class Meta {
  final int id;
  final String titulo;
  final String descricao;
  final double valor_total;
  final double valor_guardado;
  final String? data_limite;

  Meta({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.valor_total,
    required this.valor_guardado,
    this.data_limite,
  });

  factory Meta.fromSqfliteDatabase(Map<String, dynamic> map) => Meta(
    id: map['id']?.toInt() ?? 0,
    titulo: map['titulo'] ?? '',
    descricao: map['descricao'] ?? '',
    valor_total: map['valor_total'] ?? 0,
    valor_guardado: map['valor_guardado'] ?? 0,
    data_limite: map['data_limite'],
  );
}