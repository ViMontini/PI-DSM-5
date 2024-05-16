import 'package:flutter/material.dart';
import '../database/meta_db.dart';
import 'package:intl/intl.dart';
import 'package:despesa_digital/controller/utils.dart';
import '../model/meta.dart';
import '../view/metas.dart';


class AdicionarMetaPage extends StatefulWidget {
  @override
  _AdicionarMetaPageState createState() => _AdicionarMetaPageState();
}

class _AdicionarMetaPageState extends State<AdicionarMetaPage> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  TextEditingController _valorController = TextEditingController();
  DateTime _dataLimite = DateTime.now();

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adicionar Meta'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Valor Total'),
            ),
            ListTile(
              title: Text('Data Limite'),
              subtitle: Text(_dataLimite != null
                  ? '${_dataLimite.day}/${_dataLimite.month}/${_dataLimite.year}'
                  : 'Selecione a data'),
              onTap: () => _selecionarData(context),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            // Obtendo os valores dos campos de texto e data selecionada
            String titulo = _tituloController.text;
            String descricao = _descricaoController.text;
            double valorTotal = double.parse(_valorController.text);
            String dataLimite = DateFormat('yyyy-MM-dd HH:mm:ss').format(_dataLimite); // Use o formato desejado aqui

            // Criando a nova meta no banco de dados
            await MetaDB().create(
              titulo: titulo,
              descricao: descricao,
              valor_total: valorTotal,
              data_limite: dataLimite,
            );
            // Fechando o AlertDialog após adicionar a meta
            Navigator.of(context).pop(true);
          },
          child: Text('Adicionar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }
}


class MetaController {
  final MetaDB _metaDB = MetaDB();
  final Metas metas = Metas();


  // Método para exibir os detalhes da meta em uma caixa de diálogo
  void mostrarDetalhesMeta(BuildContext context, Meta meta,) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(meta.titulo),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Descrição: ${meta.descricao}'),
              Text('Valor Total:  R${meta.valor_total}'),
              Text('Data Limite: ${meta.data_limite}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // Chamar a função de excluir meta e atualizar a lista de metas
                await _metaDB.delete(meta.id);
                // Fechar a caixa de diálogo
                Navigator.of(context).pop();
                // Atualizar a lista de metas na página
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Meta excluída com sucesso!')),
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

  // Método para construir um ListTile para exibir uma meta
  Widget construirMetaListTile(BuildContext context, Meta meta) {
    return GestureDetector(
      onTap: () {
        mostrarDetalhesMeta(context, meta);
      },
      child: Card(
        elevation: 4.0,
        child: ListTile(
          title: Text(meta.titulo),
          subtitle: Text(meta.descricao),
          trailing: Text('Progresso'), // Atualize isso com base nos dados da sua meta
        ),
      ),
    );
  }

}




