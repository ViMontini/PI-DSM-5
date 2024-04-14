import 'package:flutter/material.dart';

class MovimentacaoMonetaria {
  final DateTime data;
  final double valor;
  final String descricao;

  MovimentacaoMonetaria({
    required this.data,
    required this.valor,
    required this.descricao,
  });
}

class ListaMovimentacoes {
  List<MovimentacaoMonetaria> movimentacoes = [];

  void adicionarMovimentacao({
    required DateTime data,
    required double valor,
    required String descricao,
  }) {
    movimentacoes.add(MovimentacaoMonetaria(
      data: data,
      valor: valor,
      descricao: descricao,
    ));
  }
}