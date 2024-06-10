import 'package:flutter/material.dart';
import '../database/divida_db.dart';
import '../model/divida.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../view/dividas.dart';
import 'package:intl/intl.dart';

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

  Future<void> _selecionarData2(BuildContext context) async {
    final DateTime? dataSelecionada2 = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
    );

    if (dataSelecionada2 != null) {
      setState(() {
        _dataVenc = dataSelecionada2;
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
                  : 'Selecione a data de Fim'),
              onTap: () => _selecionarData2(context),
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
            String data_inicio = DateFormat('yyyy-MM-dd').format(_dataInicio);
            String data_venc = DateFormat('yyyy-MM-dd').format(_dataVenc);
            int num_parcela = int.parse(_numParController.text);
            double valor_parcela = double.parse(_valorParController.text);

            print("data de inicio: $data_inicio");
            print("data de vencimento: $data_venc");

            DateTime hoje = DateTime.now();

            int status = (hoje.isAfter(_dataInicio) && hoje.isBefore(_dataVenc)) ? 1 : 0;

            await DividaDB().create(
              titulo: titulo,
              valor_total: valor_total,
              data_inicio: data_inicio,
              data_vencimento: data_venc,
              num_parcela: num_parcela,
              num_parcela_paga: 0,
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

  void mostrarDetalhesDivida(BuildContext context, Divida divida, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        DateTime dataInicio = DateTime.parse(divida.data_inicio);
        DateTime dataVencimento = DateTime.parse(divida.data_vencimento);
        String dataInicioFormatada = DateFormat('dd/MM/yyyy').format(dataInicio);
        String dataVencimentoFormatada = DateFormat('dd/MM/yyyy').format(dataVencimento);

        return AlertDialog(
          title: Text(divida.titulo.toUpperCase()),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Valor Total: R\$${divida.valor_total.toStringAsFixed(2)}'),
              Text('Data de Início: $dataInicioFormatada'),
              Text('Data de Vencimento: $dataVencimentoFormatada'),
              Text('Parcelas pagas: ${divida.num_parcela_paga}/${divida.num_parcela}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await _dividaDB.delete(divida.id);
                Navigator.of(context).pop();
                onDelete();
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

  Widget construirDividaListTile(BuildContext context, Divida divida, VoidCallback onDelete) {
    return GestureDetector(
      onTap: () {
        mostrarDetalhesDivida(context, divida, onDelete);
      },
      child: Card.outlined(
        shape: new RoundedRectangleBorder(
            side: new BorderSide(color: AppColors.purplelightMain, width: 2.0),
            borderRadius: BorderRadius.circular(25.0)),
        color: AppColors.white,
        elevation: 4.0,
        child: ListTile(
          title: Text(
            divida.titulo.toUpperCase(),
            style: AppTextStyles.cardheaderText,
          ),
          subtitle: Text('Valor Total: R\$${divida.valor_total.toStringAsFixed(2)}'),
        ),
      ),
    );
  }
}
