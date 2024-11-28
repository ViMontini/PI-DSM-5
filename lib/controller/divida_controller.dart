import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:despesa_digital/controller/real.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_service.dart';
import '../database/divida_db.dart';
import '../model/divida.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'package:intl/intl.dart';

import '../utils/moeda_formatter.dart';

Real _real = Real();
var connectivityResult = Connectivity().checkConnectivity();

DatabaseService databaseService = DatabaseService();


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
      // Remove o prefixo "R$" e outros caracteres não numéricos
      String valorLimpo = _valorTotController.text.replaceAll(RegExp(r'[^\d,]'), '');

      // Substitui a vírgula por ponto para facilitar a conversão para double
      valorLimpo = valorLimpo.replaceAll(',', '.');

      // Converte para double
      double valorTotal = double.parse(valorLimpo);

      // Converte o número de parcelas
      int numParcelas = int.parse(_numParController.text);

      // Calcula o valor de cada parcela
      _valorParcela = valorTotal / numParcelas;

      // Atualiza a data de vencimento sempre que o número de parcelas mudar
      _calcularDataVencimento();
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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Valor Total'),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // Permite apenas números e ponto decimal
                MoedaTextInputFormatter(), // Permite apenas números e ponto decimal
              ],
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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Número de Parcelas'),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*?[0-9]*$')), // Permite apenas números e ponto decimal
              ],
              onChanged: (_) => _calcularValorParcela(),
            ),
            Text(_valorParcela > 0 ? 'Valor de cada parcela: R\$${_valorParcela.toStringAsFixed(2)}' : ''),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            // Obtendo os valores dos campos de texto e data selecionada
            String titulo = _tituloController.text;
            String valorTotalTexto = _valorTotController.text;
            String numParcelasTexto = _numParController.text;
            String data_inicio = DateFormat('yyyy-MM-dd').format(_dataInicio);
            String data_venc = DateFormat('yyyy-MM-dd').format(_dataVenc);

            // Verificar se o título, valor total e número de parcelas foram inseridos
            if (titulo.isEmpty && valorTotalTexto.isEmpty && numParcelasTexto.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, insira o título, o valor total e o número de parcelas.')),
              );
              return;
            }

            // Verificar se o título, valor total foram inseridos
            if (titulo.isEmpty && valorTotalTexto.isEmpty ) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, insira o título, o valor total.')),
              );
              return;
            }

            // Verificar se o valor total e número de parcelas foram inseridos
            if (valorTotalTexto.isEmpty && numParcelasTexto.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, insira o valor total e o número de parcelas.')),
              );
              return;
            }

            // Verificar se o título e número de parcelas foram inseridos
            if (titulo.isEmpty  && numParcelasTexto.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, insira o título e o número de parcelas.')),
              );
              return;
            }

            // Verificar se o título foi inserido
            if (titulo.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, insira o título.')),
              );
              return;
            }

            // Verificar se o valor total foi inserido
            if (valorTotalTexto.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, insira o valor total.')),
              );
              return;
            }

            // Verificar se o número de parcelas foi inserido
            if (numParcelasTexto.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, insira o número de parcelas.')),
              );
              return;
            }

            try {
              // Remove o prefixo "R$" e outros caracteres não numéricos
              String valorLimpo = valorTotalTexto.replaceAll(RegExp(r'[^\d,]'), '');
              // Parse de valores numéricos
              double valor_total = _real.parseValor(valorLimpo);
              int num_parcela = int.parse(numParcelasTexto);


              // Criando a nova dívida no banco de dados
              DividaDB().create(
                titulo: titulo,
                valor_total: valor_total,
                data_inicio: data_inicio,
                data_vencimento: data_venc,
                num_parcela: num_parcela,
                num_parcela_paga: 0,
                valor_parcela: _valorParcela, // Passa o valor calculado da parcela aqui
                status: 0,
              );
              if (connectivityResult != ConnectivityResult.none) {
                // Faz a sincronização se estiver online
                await databaseService.syncDividaToFB();
              } else {
              }
              // Fechando o AlertDialog após adicionar a dívida
              widget.onAdd(); // Chama o callback para atualizar a lista
              Navigator.of(context).pop(true);
            } catch (e) {
              print('Erro ao adicionar a dívida: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao adicionar a dívida. Verifique os valores inseridos.')),
              );
            }
          },
          child: Text('Adicionar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text('Cancelar'),
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
                Navigator.of(context).pop(); // Fechar o alerta de confirmação
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                excluirDivida(context, divida, onDelete);
              },
              child: Text('Excluir'),
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

  void excluirDivida(BuildContext context, Divida divida, VoidCallback atualizarDividas) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Dívida'),
          content: Text(
            'Você tem certeza que deseja excluir a dívida "${divida.titulo}"? Todo o saldo pago será retornado ao saldo total.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o modal de confirmação
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o modal antes de iniciar a exclusão
                try {
                  // Chama o método de exclusão da dívida
                  DividaDB().delete(divida.id);

                  // Atualiza a lista de dívidas
                  atualizarDividas();

                  // Exibe mensagem de sucesso
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Dívida "${divida.titulo}" excluída com sucesso!')),
                  );
                } catch (e) {
                  // Exibe mensagem de erro em caso de falha
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao excluir a dívida: $e')),
                  );
                }
              },
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }


}
