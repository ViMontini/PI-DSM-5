import 'package:despesa_digital/database/divida_db.dart';
import 'package:despesa_digital/database/gasto_db.dart';
import 'package:despesa_digital/model/divida.dart';
import 'package:despesa_digital/model/gasto_fixo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:despesa_digital/database/movimentacao_db.dart';
import 'package:despesa_digital/model/movimentacao.dart';
import 'package:despesa_digital/view/movimentacoes.dart';

import '../database/meta_db.dart';
import '../model/meta.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class AdicionarMoviPage extends StatefulWidget {
  final DateTime? selectedDay;

  const AdicionarMoviPage({Key? key, this.selectedDay}) : super(key: key);

  @override
  _AdicionarMoviPageState createState() => _AdicionarMoviPageState();
}

class _AdicionarMoviPageState extends State<AdicionarMoviPage> {
  TextEditingController _valorController = TextEditingController();
  TextEditingController _categoriaController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  DateTime _dataLimite = DateTime.now();

  List<Widget> tipos = <Widget>[
    Text(('DESPESA'), style: TextStyle(fontSize: 15)),
    Text(('RECEITA'), style: TextStyle(fontSize: 15))
  ];

  final List<bool> _selectedTypes = <bool>[true, false];
  final Color despesaColor = Colors.red; // Cor para Despesa
  final Color receitaColor = Colors.green; // Cor para Receita
  int tipo = 0;

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
            Column(children: <Widget>[
              const SizedBox(height: 5),
              ToggleButtons(
                onPressed: (int index) {
                  setState(() {
                    // The button that is tapped is set to true, and the others to false.
                    for (int i = 0; i < _selectedTypes.length; i++) {
                      _selectedTypes[i] = i == index;
                    }
                    // Atualizar o valor do tipo com base na seleção
                    if (_selectedTypes[0]) {
                      tipo = 0; // Despesa
                    } else {
                      tipo = 1; // Receita
                    }
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderColor: Colors.grey,
                selectedBorderColor: _selectedTypes[0] ? despesaColor : receitaColor,
                selectedColor: Colors.white,
                fillColor: _selectedTypes[0] ? despesaColor : receitaColor,
                color: Colors.black54,
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 100.0,
                ),
                isSelected: _selectedTypes,
                children: tipos,
              ),
        ],
            ),
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
            double valor = double.parse(_valorController.text);
            String categoria = _categoriaController.text;
            String descricao = _descricaoController.text;
            String data = DateFormat('yyyy-MM-dd').format(_dataLimite);

            await MovimentacaoDB().create(
              data: data,
              valor: valor,
              categoria: categoria,
              descricao: descricao,
              tipo: tipo,
            );
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

  final Color despesaColor = Colors.red; // Cor para Despesa
  final Color receitaColor = Colors.green; // Cor para Receita
  final Color guardadoColor = Colors.blue; // Cor para Dinheiro Guardado
  final Color contaColor = Colors.teal; // Cor para Dinheiro Guardado
  final Color dividaColor = Colors.deepOrangeAccent; // Cor para Dinheiro Guardado


  // Método para exibir os detalhes da movimentação em uma caixa de diálogo
  void mostrarDetalhesMovi(BuildContext context, Movimentacao movi, VoidCallback atualizarMovis) {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        DateTime data = DateTime.parse(movi.data);
        String dataFormatada = DateFormat('dd/MM/yyyy').format(data);

        Color tipoColor;
        String tipoText;
        Widget additionalInfo;

        switch (movi.tipo) {
          case 0:
            tipoText = 'DESPESA';
            tipoColor = despesaColor;
            break;
          case 1:
            tipoText = 'RECEITA';
            tipoColor = receitaColor;
            break;
          case 2:
            tipoText = 'SALDO GUARDADO';
            tipoColor = guardadoColor;
            break;
          case 3:
            tipoText = 'PAGAMENTO DE CONTA';
            tipoColor = contaColor;
            break;
          case 4:
            tipoText = 'PAGAMENTO DE DÍVIDA';
            tipoColor = dividaColor;
            additionalInfo = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              ],
            );
            break;
          default:
            tipoText = 'DESCONHECIDO';
            tipoColor = Colors.grey;
        }

        return AlertDialog(
          title: Text(
            tipoText,
            style: TextStyle(
              color: tipoColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Data de pagamento:  $dataFormatada'),
              Text('Valor: R\$${movi.valor.toStringAsFixed(2)}'),
              Text('Descrição: ${movi.descricao}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Excluir Movimentação'),
                      content: Text('Você tem certeza que deseja excluir essa movimentação?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Fechar o alerta
                          },
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Chamar a função de excluir movimentação e atualizar a lista de movimentações
                            await _moviDB.delete(movi.id);
                            // Fechar o alerta
                            Navigator.of(context).pop();
                            // Atualizar a lista de movimentações na página
                            atualizarMovis();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Movimentação excluída com sucesso!')),
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

  // Método para construir um ListTile para exibir uma movimentação
  Widget construirMoviListTile(BuildContext context, Movimentacao movi, VoidCallback atualizarMetas) {

    DateTime data = DateTime.parse(movi.data);
    String dataFormatada = DateFormat('dd/MM/yyyy').format(data);

    Color tipoColor;
    String tipoText;
    Color valorColor;
    String valorSinal;

    switch (movi.tipo) {
      case 0:
        tipoText = 'DESPESA';
        tipoColor = despesaColor;
        valorColor = Colors.red;
        valorSinal = '-';
        break;
      case 1:
        tipoText = 'RECEITA';
        tipoColor = receitaColor;
        valorColor = Colors.green;
        valorSinal = '+';
        break;
      case 2:
        tipoText = 'SALDO GUARDADO';
        tipoColor = guardadoColor;
        valorColor = Colors.red;
        valorSinal = '-';
        break;
      case 3:
        tipoText = 'PAGAMENTO DE CONTA';
        tipoColor = contaColor;
        valorColor = Colors.red;
        valorSinal = '-';
        break;
      case 4:
        tipoText = 'PAGAMENTO DE DÍVIDA';
        tipoColor = dividaColor;
        valorColor = Colors.red;
        valorSinal = '-';
        break;
      default:
        tipoText = 'DESCONHECIDO';
        tipoColor = Colors.grey;
        valorColor = Colors.grey;
        valorSinal = '';
    }

    return GestureDetector(
      onTap: () {
        mostrarDetalhesMovi(context, movi, atualizarMetas);
      },
      child: Card.outlined(
        shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.purplelightMain, width: 2.0),
            borderRadius: BorderRadius.circular(25.0)),
        color: AppColors.white,
        elevation: 4.0,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          leading: Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            padding: const EdgeInsets.all(8.0),
            child: const Icon(
              Icons.monetization_on_outlined,
            ),
          ),
          title: Row(
            children: [
              Text(
                (movi.descricao ?? 'Descrição não disponível').toUpperCase(),
                style: AppTextStyles.cardheaderText,
              ),
            ],
          ),
          subtitle: Text(dataFormatada),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$valorSinal${movi.valor.toStringAsFixed(2)}',
                style: AppTextStyles.cardheaderText.copyWith(color: valorColor),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget construirMoviHomePage(BuildContext context, Movimentacao movi) {

    DateTime data = DateTime.parse(movi.data);
    String dataFormatada = DateFormat('dd/MM/yyyy').format(data);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 2.0),
      leading: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        padding: const EdgeInsets.all(8.0),
        child: const Icon(
          Icons.monetization_on_outlined,
        ),
      ),
      title: Text(movi.descricao ?? 'Descrição não disponível'),
      subtitle: Text(dataFormatada),
      trailing: Text(
        movi.valor.toString(),
        style: TextStyle(
          color: movi.valor.toString().startsWith('-') ? Colors.red : Colors.green,
        ),
      ),
    );
  }

  // Função para exibir o filtro modal
  void openFilterModal(BuildContext context, Function(DateTime, DateTime) onDateSelected) {
    DateTime? _startDate;
    DateTime? _endDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filtrar por Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Data Inicial'),
                subtitle: Text(_startDate == null
                    ? 'Selecionar Data'
                    : DateFormat('dd/MM/yyyy').format(_startDate!)),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _startDate)
                    _startDate = picked;
                },
              ),
              ListTile(
                title: Text('Data Final'),
                subtitle: Text(_endDate == null
                    ? 'Selecionar Data'
                    : DateFormat('dd/MM/yyyy').format(_endDate!)),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _endDate)
                    _endDate = picked;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (_startDate != null && _endDate != null) {
                  onDateSelected(_startDate!, _endDate!);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Filtrar'),
            ),
          ],
        );
      },
    );
  }

}



class GuardarSaldo extends StatefulWidget {
  final DateTime? selectedDay;

  const GuardarSaldo({Key? key, this.selectedDay}) : super(key: key);

  @override
  _GuardarSaldoState createState() => _GuardarSaldoState();
}

class _GuardarSaldoState extends State<GuardarSaldo> {
  TextEditingController _valorController = TextEditingController();
  Meta? _selectedMeta; // Meta selecionada
  List<Meta> _metas = []; // Lista de metas
  DateTime _dataLimite = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.selectedDay != null) {
      _dataLimite = widget.selectedDay!;
    }
    _fetchMetas(); // Carrega as metas ao iniciar
  }

  Future<void> _fetchMetas() async {
    MetaDB metaDB = MetaDB();
    List<Meta> metas = await metaDB.fetchAll();
    setState(() {
      _metas = metas;
      if (_metas.isNotEmpty) {
        _selectedMeta = _metas[0]; // Seleciona a primeira meta por padrão
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Guardar Saldo'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            DropdownButtonFormField<Meta>(
              value: _selectedMeta,
              items: _metas.map((Meta meta) {
                return DropdownMenuItem<Meta>(
                  value: meta,
                  child: Text(meta.titulo),
                );
              }).toList(),
              onChanged: (Meta? newMeta) {
                setState(() {
                  _selectedMeta = newMeta;
                });
              },
              decoration: InputDecoration(labelText: 'Selecione uma Meta'),
            ),
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Valor'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {

            int? meta_id = _selectedMeta?.id;
            String categoria = "Metas";

            double valor = double.parse(_valorController.text);

            if (meta_id != null) {

              print('Valor: $valor');
              print('Categoria: $categoria');
              print('Meta ID: $meta_id');

              await MovimentacaoDB().create2(
                data: DateFormat('yyyy-MM-dd').format(_dataLimite),
                valor: valor,
                categoria: categoria,
                descricao: 'Guardado para meta ${_selectedMeta!.titulo}',
                tipo: 2,
                meta_id: meta_id,
              );
              Navigator.of(context).pop(true);
            } else {
              // Lidar com a situação em que nenhuma meta está selecionada
              print('Nenhuma meta selecionada!');
            }
            },
          child: Text('Guardar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

}

class PagarConta extends StatefulWidget {
  final DateTime? selectedDay;

  const PagarConta({Key? key, this.selectedDay}) : super(key: key);

  @override
  _PagarContaState createState() => _PagarContaState();
}

class _PagarContaState extends State<PagarConta> {
  TextEditingController _valorController = TextEditingController();
  GastoFixo? _selectedConta; // Conta selecionada
  List<GastoFixo> _gastos = []; // Lista de contas
  DateTime _dataLimite = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.selectedDay != null) {
      _dataLimite = widget.selectedDay!;
    }
    _fetchContas(); // Carrega as contas ao iniciar
  }

  Future<void> _fetchContas() async {
    GastoDB gastoDB = GastoDB();
    List<GastoFixo> gastos = await gastoDB.fetchAll();
    setState(() {
      _gastos = gastos;
      if (_gastos.isNotEmpty) {
        _selectedConta = _gastos[0]; // Seleciona a primeira conta por padrão
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pagar Conta'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            DropdownButtonFormField<GastoFixo>(
              value: _selectedConta,
              items: _gastos.map((GastoFixo conta) {
                return DropdownMenuItem<GastoFixo>(
                  value: conta,
                  child: Text(conta.titulo),
                );
              }).toList(),
              onChanged: (GastoFixo? newGasto) {
                setState(() {
                  _selectedConta = newGasto;
                });
              },
              decoration: InputDecoration(labelText: 'Selecione uma Conta'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            if (_selectedConta != null) {
              bool isPaid = await GastoDB().isPaymentMadeThisMonth(_selectedConta!.id);

              if (isPaid) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Aviso'),
                      content: Text('Você já realizou o pagamento dessa conta neste mês'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                // Continue with payment
                double valor = _selectedConta!.valor;
                String categoria = "Contas";

                await MovimentacaoDB().create3(
                  data: DateFormat('yyyy-MM-dd').format(_dataLimite),
                  valor: valor,
                  categoria: categoria,
                  descricao: 'Pago conta ${_selectedConta!.titulo}',
                  tipo: 3,
                  conta_id: _selectedConta!.id,
                );
                Navigator.of(context).pop(true);
              }
            } else {
              print('Nenhuma conta selecionada!');
            }
          },
          child: Text('Pagar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }
}


class PagarDivida extends StatefulWidget {
  final DateTime? selectedDay;

  const PagarDivida({Key? key, this.selectedDay}) : super(key: key);

  @override
  _PagarDividaState createState() => _PagarDividaState();
}

class _PagarDividaState extends State<PagarDivida> {
  TextEditingController _valorController = TextEditingController();
  Divida? _selectedDivida; // Divida selecionada
  List<Divida> _dividas = []; // Lista de dividas
  DateTime _dataLimite = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.selectedDay != null) {
      _dataLimite = widget.selectedDay!;
    }
    _fetchDividas(); // Carrega as metas ao iniciar
  }

  Future<void> _fetchDividas() async {
    DividaDB dividaDB = DividaDB();
    List<Divida> dividas = await dividaDB.fetchAll();
    setState(() {
      _dividas = dividas;
      if (_dividas.isNotEmpty) {
        _selectedDivida = _dividas[0]; // Seleciona a primeira meta por padrão
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pagar Divida'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            DropdownButtonFormField<Divida>(
              value: _selectedDivida,
              items: _dividas.map((Divida divida) {
                return DropdownMenuItem<Divida>(
                  value: divida,
                  child: Text(divida.titulo),
                );
              }).toList(),
              onChanged: (Divida? newDivida) {
                setState(() {
                  _selectedDivida = newDivida;
                });
              },
              decoration: InputDecoration(labelText: 'Selecione uma Divida'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {

            int? divida_id = _selectedDivida?.id;
            double? valor = _selectedDivida?.valor_parcela;
            String categoria = "Dividas";

            if (divida_id != null && valor != null) {

              await MovimentacaoDB().create4(
                data: DateFormat('yyyy-MM-dd').format(_dataLimite),
                valor: valor,
                categoria: categoria,
                descricao: 'Pago dívida ${_selectedDivida!.titulo}',
                tipo: 4,
                divida_id: divida_id,
              );
              Navigator.of(context).pop(true);
            } else {
              // Lidar com a situação em que nenhuma meta está selecionada
              print('Nenhuma divida selecionada!');
            }
          },
          child: Text('Pagar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

}

