import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:despesa_digital/database/meta_db.dart';

class MockMetaDB extends Mock implements MetaDB {}

void main() {
  group('MetaDB Tests', () {
    late MockMetaDB mockMetaDB;

    setUp(() {
      mockMetaDB = MockMetaDB();
      print('Setup do MockMetaDB concluído.');
    });

    test('Deve criar uma nova meta com sucesso', () async {
      const titulo = 'Meta Teste';
      const descricao = 'Descrição da Meta';
      const valor_total = 10000.0;
      const data_limite = '2024-01-01';

      print('Iniciando o teste para criação de uma nova meta com título: $titulo.');

      // Configurando o mock para retornar void no método create
      when(mockMetaDB.create(
        titulo: titulo,
        descricao: descricao,
        valor_total: valor_total,
        data_limite: data_limite,
      )).thenAnswer((_) async => null);  // O método agora é void

      // Chama o método mockado
      mockMetaDB.create(
        titulo: titulo,
        descricao: descricao,
        valor_total: valor_total,
        data_limite: data_limite,
      );

      // Verifica se o método foi chamado corretamente
      verify(mockMetaDB.create(
        titulo: titulo,
        descricao: descricao,
        valor_total: valor_total,
        data_limite: data_limite,
      )).called(1);
      print('Verificação bem-sucedida: método create foi chamado corretamente.');
    });

    test('Deve lançar erro ao tentar criar meta sem título', () async {
      const titulo = ''; // Título vazio
      const descricao = 'Descrição da Meta';
      const valor_total = 10000.0;
      const data_limite = '2024-01-01';

      print('Iniciando o teste para falha na criação de uma meta sem título.');

      // Simula um erro ao tentar criar uma meta sem título
      when(mockMetaDB.create(
        titulo: titulo,
        descricao: descricao,
        valor_total: valor_total,
        data_limite: data_limite,
      )).thenThrow(Exception('Título obrigatório'));

      // Tenta executar o método mockado e captura a exceção
      try {
        mockMetaDB.create(
          titulo: titulo,
          descricao: descricao,
          valor_total: valor_total,
          data_limite: data_limite,
        );
      } catch (e) {
        // Imprime a exceção capturada
        print('Exceção capturada: $e');
      }

      // Verifica se a exceção foi lançada corretamente
      expect(() async => mockMetaDB.create(
        titulo: titulo,
        descricao: descricao,
        valor_total: valor_total,
        data_limite: data_limite,
      ), throwsException);

      print('Verificação bem-sucedida: exceção foi lançada corretamente ao criar meta sem título.');
    });


    test('Deve lançar erro ao tentar criar meta com valor total inválido', () async {
      const titulo = 'Teste';
      const descricao = 'Descrição da Meta';
      const valor_total = -1.0; // Valor total inválido
      const data_limite = '2024-01-01';

      print('Iniciando o teste para falha na criação de uma meta com valor total inválido.');

      // Simula um erro ao tentar criar uma meta com valor total inválido
      when(mockMetaDB.create(
        titulo: titulo,
        descricao: descricao,
        valor_total: valor_total,  // valor_total inválido
        data_limite: data_limite,
      )).thenThrow(Exception('Valor total é inválido'));

      // Tenta executar o método mockado e captura a exceção
      try {
        mockMetaDB.create(
          titulo: titulo,
          descricao: descricao,
          valor_total: valor_total,  // valor_total inválido
          data_limite: data_limite,
        );
      } catch (e) {
        // Imprime a exceção capturada
        print('Exceção capturada: $e');
      }

      // Verifica se a exceção foi lançada corretamente
      expect(() async => mockMetaDB.create(
        titulo: titulo,
        descricao: descricao,
        valor_total: valor_total,  // valor_total inválido
        data_limite: data_limite,
      ), throwsException);

      print('Verificação bem-sucedida: exceção foi lançada corretamente ao criar meta com valor total inválido.');
    });


    test('Deve atualizar uma meta com sucesso', () async {
      const id = 1;
      const tituloAtualizado = 'Meta Atualizada';
      const valorAtualizado = 15000.0;

      print('Iniciando o teste para atualização de meta com ID: $id.');

      // Simula o comportamento de atualização retornando void
      when(mockMetaDB.update(
        id: id,
        titulo: tituloAtualizado,
        valor_total: valorAtualizado,
      )).thenAnswer((_) async => null);  // O método agora é void

      // Chama o método mockado
      mockMetaDB.update(id: id, titulo: tituloAtualizado, valor_total: valorAtualizado);

      // Verifica se o método foi chamado corretamente
      verify(mockMetaDB.update(id: id, titulo: tituloAtualizado, valor_total: valorAtualizado)).called(1);
      print('Verificação bem-sucedida: método update foi chamado corretamente.');
    });

    test('Deve excluir uma meta com sucesso', () async {
      const id = 1;

      print('Iniciando o teste para exclusão de meta com ID: $id.');

      // Simula o comportamento de exclusão retornando void
      when(mockMetaDB.delete(id)).thenAnswer((_) async => null);  // O método agora é void

      // Chama o método mockado
      mockMetaDB.delete(id);

      // Verifica se o método foi chamado corretamente
      verify(mockMetaDB.delete(id)).called(1);
      print('Verificação bem-sucedida: método delete foi chamado corretamente.');
    });
  });
}
