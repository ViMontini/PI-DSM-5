class GastoFixo {

  final int id;
  final String titulo;
  final double valor;

  GastoFixo({

    required this.id,
    required this.titulo,
    required this.valor,

});

  factory GastoFixo.fromSqfliteDatabase(Map<String, dynamic> map) => GastoFixo(
    id: map['id']?.toInt() ?? 0,
    titulo: map['titulo'] ?? '',
    valor: map['valor'] ?? '',
  );

}