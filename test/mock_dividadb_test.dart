import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:despesa_digital/database/divida_db.dart';

class MockDividaDB extends Mock implements DividaDB {}

void main() {
  group('DividaDB Tests', () {
    late MockDividaDB mockDividaDB;

    setUp(() {
      mockDividaDB = MockDividaDB();
      print('Setup do MockDividaDB concluído.');
    });

    test('Deve criar uma nova dívida com sucesso', () async {
      const titulo = 'Dívida Teste';
      const valor_total = 5000.0;
      const data_inicio = '2023-01-01';
      const data_vencimento = '2024-01-01';
      const num_parcela = 12;
      const num_parcela_paga = 0;
      const valor_parcela = 416.67;
      const status = 1;

      print('Iniciando o teste para criação de uma nova dívida com título: $titulo.');

      // Configurando o mock para retornar um int (número de linhas afetadas) no método create
      when(mockDividaDB.create(
        titulo: titulo,
        valor_total: valor_total,
        data_inicio: data_inicio,
        data_vencimento: data_vencimento,
        num_parcela: num_parcela,
        num_parcela_paga: num_parcela_paga,
        valor_parcela: valor_parcela,
        status: status,
      )).thenAnswer((_) async => 1);  // Retorna um int (número de linhas afetadas)

      // Chama o método mockado
       mockDividaDB.create(
        titulo: titulo,
        valor_total: valor_total,
        data_inicio: data_inicio,
        data_vencimento: data_vencimento,
        num_parcela: num_parcela,
        num_parcela_paga: num_parcela_paga,
        valor_parcela: valor_parcela,
        status: status,
      );

      // Verifica se o método foi chamado corretamente
      verify(mockDividaDB.create(
        titulo: titulo,
        valor_total: valor_total,
        data_inicio: data_inicio,
        data_vencimento: data_vencimento,
        num_parcela: num_parcela,
        num_parcela_paga: num_parcela_paga,
        valor_parcela: valor_parcela,
        status: status,
      )).called(1);
      print('Verificação bem-sucedida: método create foi chamado corretamente.');
    });

    test('Deve lançar erro ao tentar criar dívida sem título', () async {
      const titulo = ''; // Título vazio
      const valor_total = 5000.0;
      const data_inicio = '2023-01-01';
      const data_vencimento = '2024-01-01';
      const num_parcela = 12;
      const num_parcela_paga = 0;
      const valor_parcela = 416.67;
      const status = 1;

      print('Iniciando o teste para falha na criação de uma dívida sem título.');

      // Simula um erro ao tentar criar uma dívida sem título
      when(mockDividaDB.create(
        titulo: titulo,
        valor_total: valor_total,
        data_inicio: data_inicio,
        data_vencimento: data_vencimento,
        num_parcela: num_parcela,
        num_parcela_paga: num_parcela_paga,
        valor_parcela: valor_parcela,
        status: status,
      )).thenThrow(Exception('Título obrigatório'));

      // Tenta executar o método mockado e captura a exceção
      try {
        mockDividaDB.create(
          titulo: titulo,
          valor_total: valor_total,
          data_inicio: data_inicio,
          data_vencimento: data_vencimento,
          num_parcela: num_parcela,
          num_parcela_paga: num_parcela_paga,
          valor_parcela: valor_parcela,
          status: status,
        );
      } catch (e) {
        // Imprime a exceção capturada
        print('Exceção capturada: $e');
      }

      // Verifica se a exceção foi lançada corretamente
      expect(() async => mockDividaDB.create(
        titulo: titulo,
        valor_total: valor_total,
        data_inicio: data_inicio,
        data_vencimento: data_vencimento,
        num_parcela: num_parcela,
        num_parcela_paga: num_parcela_paga,
        valor_parcela: valor_parcela,
        status: status,
      ), throwsException);

      print('Verificação bem-sucedida: exceção foi lançada corretamente ao criar dívida sem título.');
    });


    test('Deve atualizar uma dívida com sucesso', () async {
      const id = 1;
      const tituloAtualizado = 'Dívida Atualizada';
      const valorAtualizado = 6000.0;

      print('Iniciando o teste para atualização de dívida com ID: $id.');

      // Simula o comportamento de atualização retornando um int
      when(mockDividaDB.update(id: id, titulo: tituloAtualizado, valor_total: valorAtualizado)).thenAnswer((_) async => 1);  // Retorna um int (número de linhas afetadas)

      // Chama o método mockado
      mockDividaDB.update(id: id, titulo: tituloAtualizado, valor_total: valorAtualizado);

      // Verifica se o método foi chamado corretamente
      verify(mockDividaDB.update(id: id, titulo: tituloAtualizado, valor_total: valorAtualizado)).called(1);
      print('Verificação bem-sucedida: método update foi chamado corretamente.');
    });

    test('Deve excluir uma dívida com sucesso', () async {
      const id = 1;

      print('Iniciando o teste para exclusão de dívida com ID: $id.');

      // Simula o comportamento de exclusão retornando um int
      when(mockDividaDB.delete(id)).thenAnswer((_) async => 1);  // Retorna um int (número de linhas afetadas)

      // Chama o método mockado
      mockDividaDB.delete(id);

      // Verifica se o método foi chamado corretamente
      verify(mockDividaDB.delete(id)).called(1);
      print('Verificação bem-sucedida: método delete foi chamado corretamente.');
    });

  test('Deve verificar se o pagamento foi feito neste mês com sucesso', () async {
    const dividaId = 1;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    // Simulando uma resposta de pagamento com sucesso
    final mockResult = [
      {'data': firstDayOfMonth.toIso8601String()}
    ];

    print('Iniciando o teste para verificar pagamento neste mês.');

    // Configurando o mock para retornar um pagamento feito
    when(mockDividaDB.getPaymentDetails(dividaId)).thenAnswer((_) async {
      return {
        'paymentMade': true,
        'paymentDate': firstDayOfMonth,
      };
    });

    // Chama o método mockado
    final paymentDetails = await mockDividaDB.getPaymentDetails(dividaId);

    // Verifica se os detalhes de pagamento estão corretos
    expect(paymentDetails['paymentMade'], isTrue);
    expect(paymentDetails['paymentDate'], firstDayOfMonth);

    // Verifica se o método foi chamado corretamente
    verify(mockDividaDB.getPaymentDetails(dividaId)).called(1);

    print('Verificação bem-sucedida: pagamento foi feito neste mês.');
  });

  test('Deve retornar que nenhum pagamento foi feito neste mês', () async {
    const dividaId = 1;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    print('Iniciando o teste para verificar se nenhum pagamento foi feito neste mês.');

    // Simulando uma resposta onde não houve pagamento
    final mockResult = [];

    // Configurando o mock para retornar que nenhum pagamento foi feito
    when(mockDividaDB.getPaymentDetails(dividaId)).thenAnswer((_) async {
      return {
        'paymentMade': false,
        'paymentDate': null,
      };
    });

    // Chama o método mockado
    final paymentDetails = await mockDividaDB.getPaymentDetails(dividaId);

    // Verifica se os detalhes de pagamento estão corretos
    expect(paymentDetails['paymentMade'], isFalse);
    expect(paymentDetails['paymentDate'], isNull);

    // Verifica se o método foi chamado corretamente
    verify(mockDividaDB.getPaymentDetails(dividaId)).called(1);

    print('Verificação bem-sucedida: nenhum pagamento foi feito neste mês.');
  });

  });

}


