import 'package:flutter/material.dart';
import '../database/meta_db.dart';
import 'package:intl/intl.dart';
import 'package:despesa_digital/controller/utils.dart';
import '../model/meta.dart';
import '../view/metas.dart';
import 'package:percent_indicator/percent_indicator.dart';


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
            String dataLimite = DateFormat('yyyy-MM-dd').format(_dataLimite); // Use o formato desejado aqui

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

  // Método para exibir os detalhes da meta em uma caixa de diálogo
  void mostrarDetalhesMeta(BuildContext context, Meta meta, VoidCallback atualizarMetas) {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        DateTime? data;
        String dataFormatada = 'Data não disponível';

        // Verificar se meta.data_limite não é nula
        if (meta.data_limite != null) {
          data = DateTime.parse(meta.data_limite!);
          dataFormatada = DateFormat('dd/MM/yyyy').format(data);
        }

        return AlertDialog(
          title: Text(meta.titulo),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Descrição: ${meta.descricao}'),
              Text('Valor Total: R\$${meta.valor_total.toStringAsFixed(2)}'),
              Text('Valor Guardado: R\$${meta.valor_guardado.toStringAsFixed(2)}'),
              Text('Data Limite: $dataFormatada'),
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
                atualizarMetas();
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
  Widget construirMetaListTile(BuildContext context, Meta meta, VoidCallback atualizarMetas) {
    double progresso = meta.valor_guardado / meta.valor_total;  // Calcule o progresso da meta

    return GestureDetector(
      onTap: () {
        mostrarDetalhesMeta(context, meta, atualizarMetas);
      },
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  meta.titulo.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              Text(meta.descricao),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('R\$${meta.valor_guardado.toStringAsFixed(2)}'),
                  Text('R\$${meta.valor_total.toStringAsFixed(2)}'),
                ],
              ),
              SizedBox(height: 8.0),
              LinearPercentIndicator(
                lineHeight: 18.0,
                percent: progresso,
                backgroundColor: Colors.grey,
                progressColor: Colors.green,
                barRadius: Radius.circular(10),
                center: Text(('${(progresso * 100).toStringAsFixed(1)}%'),
                  style: TextStyle(
                  fontSize: 13.0,
                  color: Colors.black87,),),
              ),
            ],
          ),
        ),
      ),
    );
  }

}




