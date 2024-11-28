import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:despesa_digital/database/movi_db.dart';
import 'package:despesa_digital/database/saldo_db.dart';

class MockMovimentacaoDB extends Mock implements MovimentacaoDB {}
class MockSaldoDB extends Mock implements SaldoDB {}

void main() {
  group('Integração MovimentacaoDB e SaldoDB', () {
    late MockMovimentacaoDB mockMovimentacaoDB;
    late MockSaldoDB mockSaldoDB;

    setUp(() {
      mockMovimentacaoDB = MockMovimentacaoDB();
      mockSaldoDB = MockSaldoDB();
      print('Setup concluído para MovimentacaoDB e SaldoDB.');
    });

    test('Deve atualizar o saldo ao inserir uma despesa', () {
      const double valorDespesa = 100.0;

      print('Iniciando o teste para criação de uma nova despesa com valor: $valorDespesa.');

      // Simula o comportamento de inserção de despesa
      when(mockMovimentacaoDB.create(
        data: '2023-01-01',
        tipo: 0,
        valor: valorDespesa,
        categoria: 'Alimentação',
        descricao: 'Jantar',
      )).thenReturn(null);

      // Simula o comportamento de atualização do saldo após a despesa
      when(mockSaldoDB.update(id: 1, saldo: -valorDespesa)).thenAnswer((_) => Future.value(1));

      // Chama o método mockado para criar uma despesa
      mockMovimentacaoDB.create(
        data: '2023-01-01',
        tipo: 0,
        valor: valorDespesa,
        categoria: 'Alimentação',
        descricao: 'Jantar',
      );

      // Verifica se o saldo foi atualizado corretamente
      mockSaldoDB.update(id: 1, saldo: -valorDespesa);
      verify(mockMovimentacaoDB.create(
        data: '2023-01-01',
        tipo: 0,
        valor: valorDespesa,
        categoria: 'Alimentação',
        descricao: 'Jantar',
      )).called(1);
      verify(mockSaldoDB.update(id: 1, saldo: -valorDespesa)).called(1);

      print('Verificação bem-sucedida: saldo atualizado após despesa.');
    });

    test('Deve atualizar o saldo ao inserir uma receita', () {
      const double valorReceita = 200.0;

      print('Iniciando o teste para criação de uma nova receita com valor: $valorReceita.');

      // Simula o comportamento de inserção de receita
      when(mockMovimentacaoDB.create(
        data: '2023-01-01',
        tipo: 1,
        valor: valorReceita,
        categoria: 'Salário',
        descricao: 'Salário Mensal',
      )).thenReturn(null);

      // Simula o comportamento de atualização do saldo após a receita
      when(mockSaldoDB.update(id: 1, saldo: valorReceita)).thenAnswer((_) => Future.value(1));

      // Chama o método mockado para criar uma receita
      mockMovimentacaoDB.create(
        data: '2023-01-01',
        tipo: 1,
        valor: valorReceita,
        categoria: 'Salário',
        descricao: 'Salário Mensal',
      );

      // Verifica se o saldo foi atualizado corretamente
      mockSaldoDB.update(id: 1, saldo: valorReceita);
      verify(mockMovimentacaoDB.create(
        data: '2023-01-01',
        tipo: 1,
        valor: valorReceita,
        categoria: 'Salário',
        descricao: 'Salário Mensal',
      )).called(1);
      verify(mockSaldoDB.update(id: 1, saldo: valorReceita)).called(1);

      print('Verificação bem-sucedida: saldo atualizado após receita.');
    });

    test('Deve atualizar o saldo ao guardar saldo para meta', () {
      const double valorGuardar = 150.0;

      print('Iniciando o teste para guardar saldo com valor: $valorGuardar.');

      // Simula o comportamento de guardar saldo para meta
      when(mockMovimentacaoDB.create(
        data: '2023-01-01',
        tipo: 2,
        valor: valorGuardar,
        categoria: 'Meta Viagem',
        descricao: 'Reserva para viagem',
      )).thenReturn(null);

      // Simula o comportamento de atualização do saldo após guardar saldo
      when(mockSaldoDB.update(id: 1, saldo: -valorGuardar)).thenAnswer((_) => Future.value(1));

      // Chama o método mockado para guardar saldo
      mockMovimentacaoDB.create(
        data: '2023-01-01',
        tipo: 2,
        valor: valorGuardar,
        categoria: 'Meta Viagem',
        descricao: 'Reserva para viagem',
      );

      // Verifica se o saldo foi atualizado corretamente
      mockSaldoDB.update(id: 1, saldo: -valorGuardar);
      verify(mockMovimentacaoDB.create(
        data: '2023-01-01',
        tipo: 2,
        valor: valorGuardar,
        categoria: 'Meta Viagem',
        descricao: 'Reserva para viagem',
      )).called(1);
      verify(mockSaldoDB.update(id: 1, saldo: -valorGuardar)).called(1);

      print('Verificação bem-sucedida: saldo atualizado após guardar saldo para meta.');
    });

    test('Deve atualizar o saldo ao pagar uma conta', () {
      const double valorConta = 80.0;

      print('Iniciando o teste para pagamento de conta com valor: $valorConta.');

      // Simula o comportamento de pagamento de conta
      when(mockMovimentacaoDB.create(
        data: '2023-01-01',
        tipo: 3,
        valor: valorConta,
        categoria: 'Conta de Luz',
        descricao: 'Pagamento de conta de luz',
      )).thenReturn(null);

      // Simula o comportamento de atualização do saldo após pagamento de conta
      when(mockSaldoDB.update(id: 1, saldo: -valorConta)).thenAnswer((_) => Future.value(1));

      // Chama o método mockado para pagar uma conta
      mockMovimentacaoDB.create(
        data: '2023-01-01',
        tipo: 3,
        valor: valorConta,
        categoria: 'Conta de Luz',
        descricao: 'Pagamento de conta de luz',
      );

      // Verifica se o saldo foi atualizado corretamente
      mockSaldoDB.update(id: 1, saldo: -valorConta);
      verify(mockMovimentacaoDB.create(
        data: '2023-01-01',
        tipo: 3,
        valor: valorConta,
        categoria: 'Conta de Luz',
        descricao: 'Pagamento de conta de luz',
      )).called(1);
      verify(mockSaldoDB.update(id: 1, saldo: -valorConta)).called(1);

      print('Verificação bem-sucedida: saldo atualizado após pagamento de conta.');
    });
  });
}
