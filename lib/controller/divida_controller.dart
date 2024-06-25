import 'package:flutter/material.dart';
import '../database/divida_db.dart';
import '../model/divida.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'package:intl/intl.dart';

class AdicionarDividaPage extends StatefulWidget {
  final VoidCallback onAdd;
  AdicionarDividaPage({required this.onAdd});

  @override
  _AdicionarDividaPageState createState() => _AdicionarDividaPageState();
}

class _AdicionarDividaPageState extends State<AdicionarDividaPage> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _valorTotController = TextEditingController();
  DateTime _dataInicio = DateTime.now();
  DateTime _dataVenc = DateTime.now();
  TextEditingController _numParController = TextEditingController();
  double _valorParcela = 0.0; // Variável para armazenar o valor calculado da parcela

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 10),
      lastDate: DateTime(DateTime.now().year + 10),
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataInicio = dataSelecionada;
        _calcularDataVencimento(); // Atualiza a data de vencimento sempre que a data de início for selecionada
      });
    }
  }

  // Método para calcular a data de término com base na data de início e no número de parcelas
  void _calcularDataVencimento() {
    if (_numParController.text.isNotEmpty) {
      int numParcelas = int.parse(_numParController.text);
      DateTime dataVencimento = DateTime(_dataInicio.year, _dataInicio.month + numParcelas - 1, 1);
      dataVencimento = DateTime(dataVencimento.year, dataVencimento.month + 1, 0); // Último dia do mês

      setState(() {
        _dataVenc = dataVencimento;
      });
    }
  }

  // Método para calcular o valor de cada parcela
  void _calcularValorParcela() {
    if (_valorTotController.text.isNotEmpty && _numParController.text.isNotEmpty) {
      double valorTotal = double.parse(_valorTotController.text);
      int numParcelas = int.parse(_numParController.text);
      _valorParcela = valorTotal / numParcelas;
      _calcularDataVencimento(); // Atualiza a data de vencimento sempre que o número de parcelas mudar
    } else {
      _valorParcela = 0.0;
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
              onChanged: (_) => _calcularValorParcela(),
            ),
            ListTile(
              title: Text('Data de Início'),
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
              onTap: () {}, // Desabilitar a seleção manual da data de fim
            ),
            TextField(
              controller: _numParController,
              keyboardType: TextInputType.numberWithOptions(decimal: false),
              decoration: InputDecoration(labelText: 'Número de Parcelas'),
              onChanged: (_) => _calcularValorParcela(),
            ),
            Text(_valorParcela > 0 ? 'Valor de cada parcela: R\$${_valorParcela.toStringAsFixed(2)}' : ''),
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

            DateTime hoje = DateTime.now();
            int status = (hoje.isAfter(_dataInicio) && hoje.isBefore(_dataVenc)) ? 1 : 0;

            await DividaDB().create(
              titulo: titulo,
              valor_total: valor_total,
              data_inicio: data_inicio,
              data_vencimento: data_venc,
              num_parcela: num_parcela,
              num_parcela_paga: 0,
              valor_parcela: _valorParcela, // Passa o valor calculado da parcela aqui
              status: status,
            );
            // Fechando o AlertDialog após adicionar a dívida
            widget.onAdd(); // Chama o callback para atualizar a lista
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
              Text('Valor Total: R\$${NumberFormat("#,##0.00", "pt_BR").format(divida.valor_total)}'),
              Text('Data de Início: $dataInicioFormatada'),
              Text('Data de Vencimento: $dataVencimentoFormatada'),
              Text('Valor de cada parcela: ${NumberFormat("#,##0.00", "pt_BR").format(divida.valor_parcela)}'),
              Text('Parcelas pagas: ${divida.num_parcela_paga}/${divida.num_parcela}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Excluir Dívida'),
                      content: Text('Você tem certeza que deseja excluir essa dívida? O saldo não retornará automaticamente, apenas excluindo as movimentações ligadas a essas dívida.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Fechar o alerta de confirmação
                          },
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Chamar a função de excluir movimentação e atualizar a lista de movimentações
                            await _dividaDB.delete(divida.id);
                            // Fechar o alerta de confirmação
                            Navigator.of(context).pop();
                            // Fechar o alerta de detalhes
                            Navigator.of(context).pop();
                            // Atualizar a lista de movimentações na página
                            onDelete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Dívida excluída com sucesso!')),
                            );
                          },
                          child: Text('Excluir'),
                        ),
                      ],
                    );
                  },
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

  Widget construirDividaListTile(BuildContext context, Divida divida, VoidCallback onDelete) {
    return GestureDetector(
      onTap: () {
        mostrarDetalhesDivida(context, divida, onDelete);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.purplelightMain, width: 2.0),
          borderRadius: BorderRadius.circular(25.0),
        ),
        color: AppColors.white,
        elevation: 4.0,
        child:  Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _dividaDB.getPaymentDetails(divida.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return AlertDialog(
                  title: Text(divida.titulo),
                  content: Center(child: CircularProgressIndicator()),
                );
              }
              bool paymentMade = snapshot.data?['paymentMade'] ?? false;
              DateTime? paymentDate = snapshot.data?['paymentDate'];
              String formattedDate = paymentDate != null ? DateFormat('dd/MM/yyyy').format(paymentDate) : '';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          divida.titulo.toUpperCase(),
                          style: AppTextStyles.cardheaderText,
                        ),
                      ),
                      Text(
                        'R\$${NumberFormat("#,##0.00", "pt_BR").format(divida.valor_total)}',
                        style: AppTextStyles.cardheaderText,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              paymentMade
                                  ? 'Já houve um pagamento para esta dívida no dia $formattedDate'
                                  : 'Não houve pagamento para esta dívida esse mês',
                            ),
                          ],
                        ),
                      ),
                      paymentMade
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : Icon(Icons.error, color: Colors.red),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                  '${divida.num_parcela_paga}/${divida.num_parcela}'
                              ),
                            ],
                          )
                      )
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
