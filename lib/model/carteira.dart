class Carteira {
  final int id;
  final double saldo;
  final String ultimaAtualizacao;

  Carteira({
    required this.id,
    required this.saldo,
    required this.ultimaAtualizacao,
  });

  // Factory para criar uma instância de Carteira a partir de um mapa do banco de dados
  factory Carteira.fromSqfliteDatabase(Map<String, dynamic> map) => Carteira(
    id: map['id']?.toInt() ?? 0,
    saldo: map['saldo']?.toDouble() ?? 0.0,
    ultimaAtualizacao: map['ultima_atualizacao'] ?? '',
  );

  // Método para converter a instância de Carteira em um Map, útil para operações com o banco
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saldo': saldo,
      'ultima_atualizacao': ultimaAtualizacao,
    };
  }
}
