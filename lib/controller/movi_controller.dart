import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:despesa_digital/database/movimentacao_db.dart';
import 'package:despesa_digital/model/movimentacao.dart';
import 'package:despesa_digital/view/movimentacoes.dart';

class AdicionarMoviPage extends StatefulWidget {
  final DateTime? selectedDay; // Adiciona a variável selectedDay

  const AdicionarMoviPage({Key? key, this.selectedDay}) : super(key: key);

  @override
  _AdicionarMoviPageState createState() => _AdicionarMoviPageState();
}

class _AdicionarMoviPageState extends State<AdicionarMoviPage> {
  TextEditingController _valorController = TextEditingController();
  TextEditingController _categoriaController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  DateTime _dataLimite = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.selectedDay != null) {
      _dataLimite = widget.selectedDay!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adicionar Movimentação Diária'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Valor'),
            ),
            TextField(
              controller: _categoriaController,
              decoration: InputDecoration(labelText: 'Categoria'),
            ),
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            ListTile(
              title: Text('Data'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_dataLimite)),
              onTap: () => _selecionarData(context),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            // Obtendo os valores dos campos de texto e data selecionada
            double valor = double.parse(_valorController.text);
            String categoria = _categoriaController.text;
            String descricao = _descricaoController.text;
            int recorrente = 0;
            int tipo = 0;
            String data = DateFormat('dd/MM/yyyy').format(_dataLimite);

            // Criando a nova movimentação no banco de dados
            await MovimentacaoDB().create(
              data: data,
              valor: valor,
              categoria: categoria,
              descricao: descricao,
              recorrente: recorrente,
              tipo: tipo,
            );
            // Fechando o AlertDialog após adicionar a movimentação
            Navigator.of(context).pop(true);
          },
          child: Text('Adicionar'),
        ),
      ],
    );
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataLimite,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataLimite = dataSelecionada;
      });
    }
  }

  @override
  void dispose() {
    _valorController.dispose();
    _categoriaController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }
}

class MoviController {
  final MovimentacaoDB _moviDB = MovimentacaoDB();
  final Movimentacoes movis = Movimentacoes();

  // Método para exibir os detalhes da movimentação em uma caixa de diálogo
  void mostrarDetalhesMovi(BuildContext context, Movimentacao movi) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(movi.categoria),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Descrição: ${movi.descricao}'),
              Text('Data:  ${movi.data}'),
              Text('Valor: ${movi.valor}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // Chamar a função de excluir movimentação e atualizar a lista de movimentações
                await _moviDB.delete(movi.id);
                // Fechar a caixa de diálogo
                Navigator.of(context).pop();
                // Atualizar a lista de movimentações na página
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Movimentação excluída com sucesso!')),
                );
              },
              child: Text('Excluir'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar a caixa de diálogo
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // Método para construir um ListTile para exibir uma movimentação
  Widget construirMoviListTile(BuildContext context, Movimentacao movi) {
    return GestureDetector(
      onTap: () {
        mostrarDetalhesMovi(context, movi);
      },
      child: Card(
        elevation: 4.0,
        child: ListTile(
          title: Text(movi.categoria),
          subtitle: Text(movi.valor.toString()),
          trailing: Text('Progresso'), // Atualize isso com base nos dados da sua movimentação
        ),
      ),
    );
  }
}
