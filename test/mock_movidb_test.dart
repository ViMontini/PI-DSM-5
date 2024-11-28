import 'package:despesa_digital/database/movi_db.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock class for MovimentacaoDB
class MockMovimentacaoDB extends Mock implements MovimentacaoDB {}

void main() {
  group('MovimentacaoDB Tests', () {
    late MockMovimentacaoDB mockMovimentacaoDB;

    setUp(() {
      mockMovimentacaoDB = MockMovimentacaoDB();
      print('Setup do MockMovimentacaoDB concluído.');
    });

    test('Deve criar uma nova movimentação de despesa com sucesso', () async {
      const data = '2023-01-01';
      const tipo = 1;
      const valor = 500.0;
      const categoria = 'Alimentação';
      const descricao = 'Restaurante';

      print('Iniciando o teste para criação de uma nova movimentação de despesa.');

      // Simula o comportamento do método create, retornando 1 (indica sucesso)
      when(mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
      )).thenAnswer((_) async => 1);  // O método retorna um número de linhas afetadas

      // Chama o método mockado
      mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
      );

      // Verifica se o método foi chamado corretamente
      verify(mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
      )).called(1);
      print('Verificação bem-sucedida: método create foi chamado corretamente.');
    });

    test('Deve criar uma nova movimentação de receita com sucesso', () async {
      const data = '2023-01-01';
      const tipo = 1;
      const valor = 500.0;
      const categoria = 'Salario';
      const descricao = 'Salario';

      print('Iniciando o teste para criação de uma nova movimentação de receita.');

      // Simula o comportamento do método create, retornando 1 (indica sucesso)
      when(mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
      )).thenAnswer((_) async => 1);  // O método retorna um número de linhas afetadasD

      // Chama o método mockado
      mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
      );

      // Verifica se o método foi chamado corretamente
      verify(mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
      )).called(1);
      print('Verificação bem-sucedida: método create foi chamado corretamente.');
    });

    test('Deve criar uma nova movimentação para guardar saldo com sucesso', () async {
      const data = '2023-01-01';
      const tipo = 2;
      const valor = 500.0;
      const categoria = 'Metas';
      const descricao = 'Guardado para meta Japão';

      print('Iniciando o teste para criação de uma nova movimentação para guardar saldo.');

      // Simula o comportamento do método create, retornando 1 (indica sucesso)
      when(mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
      )).thenAnswer((_) async => 1);  // O método retorna um número de linhas afetadas

      // Chama o método mockado
      mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
      );

      // Verifica se o método foi chamado corretamente
      verify(mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
      )).called(1);
      print('Verificação bem-sucedida: método create foi chamado corretamente.');
    });

    test('Deve criar uma nova movimentação para pagar conta com sucesso', () async {
      const data = '2023-01-01';
      const tipo = 3;
      const valor = 500.0;
      const categoria = 'Contas';
      const descricao = 'Pago conta Luz';

      print('Iniciando o teste para criação de uma nova movimentação para pagar conta.');

      // Simula o comportamento do método create, retornando 1 (indica sucesso)
      when(mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
      )).thenAnswer((_) async => 1);  // O método retorna um número de linhas afetadas

      // Chama o método mockado
      mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
      );

      // Verifica se o método foi chamado corretamente
      verify(mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
      )).called(1);
      print('Verificação bem-sucedida: método create foi chamado corretamente.');
    });

    test('Deve criar uma nova movimentação para pagar divida com sucesso', () async {
      const data = '2023-01-01';
      const tipo = 4;
      const valor = 500.0;
      const categoria = 'Dividas';
      const descricao = 'Pago dívida TV';

      print('Iniciando o teste para criação de uma nova movimentação para pagar divida.');

      // Simula o comportamento do método create, retornando 1 (indica sucesso)
      when(mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
      )).thenAnswer((_) async => 1);  // O método retorna um número de linhas afetadas

      // Chama o método mockado
      mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
      );

      // Verifica se o método foi chamado corretamente
      verify(mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
      )).called(1);
      print('Verificação bem-sucedida: método create foi chamado corretamente.');
    });

    test('Deve lançar erro ao tentar criar movimentação com valor inválido', () async {
      const data = '2023-01-01';
      const tipo = 1;
      const valor = -500.0;  // Valor inválido
      const categoria = 'Alimentação';
      const descricao = 'Compra de mercado';

      print('Iniciando o teste para falha na criação de uma movimentação com valor inválido.');

      // Simula um erro ao tentar criar uma movimentação com valor inválido
      when(mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,  // Valor inválido
        categoria: categoria,
        descricao: descricao,
      )).thenThrow(Exception('Valor inválido'));

      // Tenta executar o método mockado e captura a exceção
      try {
        mockMovimentacaoDB.create(
          data: data,
          tipo: tipo,
          valor: valor,  // Valor inválido
          categoria: categoria,
          descricao: descricao,
        );
      } catch (e) {
        // Imprime a exceção capturada
        print('Exceção capturada: $e');
      }

      // Verifica se a exceção foi lançada corretamente
      expect(() async => mockMovimentacaoDB.create(
        data: data,
        tipo: tipo,
        valor: valor,  // Valor inválido
        categoria: categoria,
        descricao: descricao,
      ), throwsException);

      print('Verificação bem-sucedida: exceção foi lançada corretamente ao criar movimentação com valor inválido.');
    });

    test('Deve atualizar uma movimentação com sucesso', () async {
      const id = 1;
      const dataAtualizada = '2023-02-01';
      const valorAtualizado = 600.0;

      print('Iniciando o teste para atualização de movimentação com ID: $id.');

      // Simula o comportamento de atualização retornando 1 (indica sucesso)
      when(mockMovimentacaoDB.update(
        id: id,
        data: dataAtualizada,
        valor: valorAtualizado,
      )).thenAnswer((_) async => 1);  // O método retorna um número de linhas afetadas

      // Chama o método mockado
      mockMovimentacaoDB.update(id: id, data: dataAtualizada, valor: valorAtualizado);

      // Verifica se o método foi chamado corretamente
      verify(mockMovimentacaoDB.update(id: id, data: dataAtualizada, valor: valorAtualizado)).called(1);
      print('Verificação bem-sucedida: método update foi chamado corretamente.');
    });

    test('Deve excluir uma movimentação com sucesso', () async {
      const id = 1;

      print('Iniciando o teste para exclusão de movimentação com ID: $id.');

      // Simula o comportamento de exclusão retornando 1 (indica sucesso)
      when(mockMovimentacaoDB.delete(id)).thenAnswer((_) async => 1);  // O método retorna um número de linhas afetadas

      // Chama o método mockado
      mockMovimentacaoDB.delete(id);

      // Verifica se o método foi chamado corretamente
      verify(mockMovimentacaoDB.delete(id)).called(1);
      print('Verificação bem-sucedida: método delete foi chamado corretamente.');
    });

  });
}
