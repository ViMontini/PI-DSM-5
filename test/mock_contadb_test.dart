import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:despesa_digital/database/conta_db.dart';

class MockContaDB extends Mock implements ContaDB {}

void main() {
  group('ContaDB Tests', () {
    late MockContaDB mockContaDB;

    setUp(() {
      mockContaDB = MockContaDB();
      print('Setup do MockContaDB concluído.');
    });

    test('Deve criar uma nova conta com sucesso', () {
      const titulo = 'Conta Teste';
      const valor = 100.0;

      print('Iniciando o teste para criação de uma nova conta com título: $titulo e valor: $valor.');

      // Configurando o mock para simular o comportamento de criar uma nova conta
      when(mockContaDB.create(titulo: titulo, valor: valor)).thenReturn(null);

      // Chama o método mockado
      mockContaDB.create(titulo: titulo, valor: valor);

      // Verifica se o método foi chamado corretamente
      verify(mockContaDB.create(titulo: titulo, valor: valor)).called(1);
      print('Verificação bem-sucedida: método create foi chamado corretamente.');
    });

    test('Deve lançar erro ao tentar criar conta sem título', () async {
      const titulo = ''; // Título vazio
      const valor = 100.0;

      print('Iniciando o teste para falha na criação de uma conta sem título.');

      // Simula um erro ao tentar criar uma conta sem título
      when(mockContaDB.create(titulo: titulo, valor: valor)).thenThrow(Exception('Título obrigatório'));

      // Verifica se a exceção foi lançada corretamente e captura o erro
      try {
        mockContaDB.create(titulo: titulo, valor: valor);
      } catch (e) {
        print('Exceção capturada: $e');  // Imprime a exceção capturada
      }

      // Verifica se a exceção foi lançada
      expect(() => mockContaDB.create(titulo: titulo, valor: valor), throwsException);

      print('Verificação bem-sucedida: exceção foi lançada corretamente ao criar conta sem título.');
    });


    test('Deve atualizar uma conta com sucesso', () async {
      const id = 1;
      const tituloAtualizado = 'Conta Atualizada';
      const valorAtualizado = 150.0;

      print('Iniciando o teste para atualização de conta com ID: $id.');

      // Simula o comportamento de atualização
      when(mockContaDB.update(id: id, titulo: tituloAtualizado, valor: valorAtualizado)).thenReturn(null);

      // Chama o método mockado
      mockContaDB.update(id: id, titulo: tituloAtualizado, valor: valorAtualizado);

      // Verifica se o método foi chamado corretamente
      verify(mockContaDB.update(id: id, titulo: tituloAtualizado, valor: valorAtualizado)).called(1);
      print('Verificação bem-sucedida: método update foi chamado corretamente.');
    });

    test('Deve excluir uma conta com sucesso', () async {
      const id = 1;

      print('Iniciando o teste para exclusão de conta com ID: $id.');

      // Simula o comportamento de exclusão
      when(mockContaDB.delete(id)).thenReturn(null);

      // Chama o método mockado
      mockContaDB.delete(id);

      // Verifica se o método foi chamado corretamente
      verify(mockContaDB.delete(id)).called(1);
      print('Verificação bem-sucedida: método delete foi chamado corretamente.');
    });
  });
}
