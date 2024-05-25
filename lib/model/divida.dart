import 'package:intl/intl.dart';

class Divida {

  final int id;
  final String titulo;
  final double valor_total;
  final double? valor_pago;
  final String data_inicio;
  final String data_vencimento;
  final int num_parcela;
  final int num_parcela_paga;
  final double valor_parcela;
  final int status;

  Divida({
    required this.id,
    required this.titulo,
    required this.valor_total,
    this.valor_pago,
    required this.data_inicio,
    required this.data_vencimento,
    required this.num_parcela,
    required this.num_parcela_paga,
    required this.valor_parcela,
    required this.status
  });

  factory Divida.fromSqfliteDatabase(Map<String, dynamic> map) => Divida(
    id: map['id']?.toInt() ?? 0,
    titulo: map['titulo'] ?? '',
    valor_total: map['valor_total'] ?? '',
    valor_pago: map['valor_pago'] ?? '',
    data_inicio: map['data_inicio'] ?? '',
    data_vencimento: map['data_vencimento'],
    num_parcela: map['num_parcela'],
    num_parcela_paga: map['num_parcela_paga'],
    valor_parcela: map['valor_parcela'],
    status: map['status'],
  );


}