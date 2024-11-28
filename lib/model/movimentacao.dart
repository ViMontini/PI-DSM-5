import 'package:intl/intl.dart';

class Movimentacao {
  final int id;
  final String data;
  final int tipo;
  final double valor;
  final String categoria;
  final String? descricao;
  final int? meta_id;
  final int estornado; // Adicionado o campo estornado

  Movimentacao({
    required this.id,
    required this.data,
    required this.tipo,
    required this.valor,
    required this.categoria,
    this.descricao,
    this.meta_id,
    required this.estornado, // Incluído no construtor
  });

  // Atualizado para incluir o campo estornado
  factory Movimentacao.fromSqfliteDatabase(Map<String, dynamic> map) => Movimentacao(
    id: map['id']?.toInt() ?? 0,
    data: map['data'] ?? '',
    tipo: map['tipo'] ?? 0,
    valor: map['valor'] ?? 0.0,
    categoria: map['categoria'] ?? '',
    descricao: map['descricao'],
    meta_id: map['meta_id'],
    estornado: map['estornado'] ?? 0, // Valor padrão 0 se não definido
  );

  // Método opcional para conversão para map, caso necessário
  Map<String, dynamic> toMap() => {
    'id': id,
    'data': data,
    'tipo': tipo,
    'valor': valor,
    'categoria': categoria,
    'descricao': descricao,
    'meta_id': meta_id,
    'estornado': estornado, // Incluído no mapeamento
  };
}
