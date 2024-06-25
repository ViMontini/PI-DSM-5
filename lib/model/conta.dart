class Conta {

  final int id;
  final String titulo;
  final double valor;

  Conta({

    required this.id,
    required this.titulo,
    required this.valor,

  });

  factory Conta.fromSqfliteDatabase(Map<String, dynamic> map) => Conta(
    id: map['id']?.toInt() ?? 0,
    titulo: map['titulo'] ?? '',
    valor: map['valor'] ?? '',
  );

}