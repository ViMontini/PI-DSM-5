import 'package:flutter/material.dart';
import '../database/divida_db.dart';
import '../model/divida.dart';
import '../view/dividas.dart';

class AdicionarDividaPage extends StatefulWidget {
  @override
  _AdicionarDividaPageState createState() => _AdicionarDividaPageState();
}

class _AdicionarDividaPageState extends State<AdicionarDividaPage> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _valorTotController = TextEditingController();
  DateTime _dataInicio = DateTime.now();
  DateTime _dataVenc = DateTime.now();
  TextEditingController _numParController = TextEditingController();
  TextEditingController _valorParController = TextEditingController();

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataInicio = dataSelecionada;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adicionar Dívida'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _valorTotController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Valor Total'),
            ),
            ListTile(
              title: Text('Data de Inicio'),
              subtitle: Text(_dataInicio != null
                  ? '${_dataInicio.day}/${_dataInicio.month}/${_dataInicio.year}'
                  : 'Selecione a data de inicio'),
              onTap: () => _selecionarData(context),
            ),
            ListTile(
              title: Text('Data de Fim'),
              subtitle: Text(_dataVenc != null
                  ? '${_dataVenc.day}/${_dataVenc.month}/${_dataVenc.year}'
                  : 'Selecione a data de inicio'),
              onTap: () => _selecionarData(context),
            ),
            TextField(
              controller: _numParController,
              keyboardType: TextInputType.numberWithOptions(decimal: false),
              decoration: InputDecoration(labelText: 'Número de Parcelas'),
            ),
            TextField(
              controller: _valorParController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Valor das Parcelas'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            String titulo = _tituloController.text;
            double valor_total = double.parse(_valorTotController.text);
            String data_inicio = _dataInicio.toIso8601String(); // Use o formato desejado aqui
            String data_venc = _dataVenc.toIso8601String();
            int num_parcela = int.parse(_numParController.text);
            double valor_parcela = double.parse(_valorParController.text);

            DateTime hoje = DateTime.now();

            int status = (hoje.isAfter(_dataInicio) && hoje.isBefore(_dataVenc)) ? 1 : 0;

            await DividaDB().create(
              titulo: titulo,
              valor_total: valor_total,
              data_inicio: data_inicio,
              data_vencimento: data_venc,
              num_parcela: num_parcela,
              valor_parcela: valor_parcela,
              status: status,
            );
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
    _valorTotController.dispose();
    _numParController.dispose();
    _valorParController.dispose();
    super.dispose();
  }
}

class DividaController {
  final DividaDB _dividaDB = DividaDB();

  void mostrarDetalhesDivida(BuildContext context, Divida divida) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(divida.titulo),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Valor Total: R\$${divida.valor_total}'),
              Text('Data de Vencimento: ${divida.data_vencimento}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await _dividaDB.delete(divida.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Dívida excluída com sucesso!')),
                );
              },
              child: Text('Excluir'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  Widget construirDividaListTile(BuildContext context, Divida divida) {
    return GestureDetector(
      onTap: () {
        mostrarDetalhesDivida(context, divida);
      },
      child: Card(
        elevation: 4.0,
        child: ListTile(
          title: Text(divida.titulo),
          subtitle: Text('Valor Total: ${divida.valor_total.toString()}'),
        ),
      ),
    );
  }
}
