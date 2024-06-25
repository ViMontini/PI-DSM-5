import 'package:despesa_digital/controller/real.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../database/conta_db.dart';
import '../database/divida_db.dart';
import '../database/meta_db.dart';
import '../database/movi_db.dart';
import '../model/conta.dart';
import '../model/divida.dart';
import '../model/meta.dart';
import '../model/movimentacao.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

import 'categorizer.dart';

Real _real = Real();

class AdicionarMoviPage extends StatefulWidget {
  final DateTime? selectedDay;
  final VoidCallback onSave;

  const AdicionarMoviPage({Key? key, this.selectedDay, required this.onSave}) : super(key: key);

  @override
  _AdicionarMoviPageState createState() => _AdicionarMoviPageState();
}

class _AdicionarMoviPageState extends State<AdicionarMoviPage> {
  TextEditingController _valorController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  DateTime _dataLimite = DateTime.now();
  bool _isLoading = false;

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
                    for (int i = 0; i < _selectedTypes.length; i++) {
                      _selectedTypes[i] = i == index;
                    }
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
            ]),
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Valor'),
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
            try {
              double valor = _real.parseValor(_valorController.text);
              String descricao = _descricaoController.text;
              String data = DateFormat('yyyy-MM-dd').format(_dataLimite);
              String categoria = await Categorizer.categorize(descricao);

              await MovimentacaoDB().create(
                data: data,
                valor: valor,
                categoria: categoria,
                descricao: descricao,
                tipo: tipo,
              );
              Navigator.of(context).pop(true);
              widget.onSave(); // Chama o callback para atualizar a lista
            } catch (e) {
              print('Erro ao adicionar a movimentação: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro ao adicionar a movimentação')),
              );
              Navigator.of(context).pop(false);
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          },
          child: _isLoading ? CircularProgressIndicator() : Text('Adicionar'),
        ),
      ],
    );
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataLimite,
      firstDate: DateTime(DateTime.now().year - 10),
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
    _descricaoController.dispose();
    super.dispose();
  }
}

class MoviController {
  Function? refreshMovis;
  final MovimentacaoDB _moviDB = MovimentacaoDB();
  final Color despesaColor = Colors.red; // Cor para Despesa
  final Color receitaColor = Colors.green; // Cor para Receita
  final Color guardadoColor = Colors.blue; // Cor para Dinheiro Guardado
  final Color contaColor = Colors.teal; // Cor para Dinheiro Guardado
  final Color dividaColor = Colors.deepOrangeAccent; // Cor para Dinheiro Guardado

  Future<List<Movimentacao>> fetchAllMovisAsc() async {
    return await _moviDB.fetchAllAsc();
  }

  Future<List<Movimentacao>> fetchAllMovisDesc() async {
    return await _moviDB.fetchAllDesc();
  }

  Future<List<Movimentacao>> fetchMovisByDateRange(String startDate, String endDate) async {
    return await _moviDB.fetchByDateRange(startDate, endDate);
  }

  IconData getIconForCategory(String category) {
    switch (category) {
      case 'Alimentação':
        return Icons.restaurant;
      case 'Animais de Estimação':
        return Icons.pets;
      case 'Beleza e Cuidados':
        return Icons.brush;
      case 'Compras':
        return Icons.shopping_cart;
      case 'Contas':
        return Icons.receipt;
      case 'Educação':
        return Icons.school;
      case 'Entretenimento':
        return Icons.movie;
      case 'Finanças':
        return Icons.attach_money;
      case 'Lazer':
        return Icons.pool;
      case 'Moradia':
        return Icons.home;
      case 'Saúde':
        return Icons.local_hospital;
      case 'Serviços Terceiros':
        return Icons.build;
      case 'Transporte':
        return Icons.directions_car;
      case 'Utilidades':
        return Icons.lightbulb;
      case 'Metas':
        return Icons.flag;
      case 'Dividas':
        return Icons.credit_card;
      case 'Contas':
        return Icons.receipt;
      default:
        return Icons.category;
    }
  }

  void mostrarDetalhesMovi(BuildContext context, Movimentacao movi, VoidCallback atualizarMovis) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime data = DateTime.parse(movi.data);
        String dataFormatada = DateFormat('dd/MM/yyyy').format(data);

        Color tipoColor;
        String tipoText;

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
              Text('Valor: R\$${NumberFormat("#,##0.00", "pt_BR").format(movi.valor)}'),
              Text('Descrição: ${movi.descricao}'),
              Text('Categoria: ${movi.categoria}'),
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
                            Navigator.of(context).pop(); // Fechar o alerta de confirmação
                          },
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _moviDB.delete(movi.id);
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
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

    IconData categoryIcon = getIconForCategory(movi.categoria);

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
            child: Icon(categoryIcon, color: Colors.purple),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  (movi.descricao ?? 'Descrição não disponível').toUpperCase(),
                  style: AppTextStyles.cardheaderText,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Text(dataFormatada),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$valorSinal${NumberFormat("#,##0.00", "pt_BR").format(movi.valor)}',
                style: AppTextStyles.cardheaderText.copyWith(color: valorColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget construirMoviHomePage(BuildContext context, Movimentacao movi, VoidCallback atualizarMetas, bool isBalanceVisible) {
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

    IconData categoryIcon = getIconForCategory(movi.categoria);

    return GestureDetector(
      onTap: () {
        mostrarDetalhesMovi(context, movi, atualizarMetas);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.purplelightMain, width: 2.0),
          borderRadius: BorderRadius.circular(25.0),
        ),
        color: AppColors.white,
        elevation: 4.0,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          leading: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Icon(categoryIcon, color: Colors.purple),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  (movi.descricao ?? 'Descrição não disponível').toUpperCase(),
                  style: AppTextStyles.cardheaderText,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Text(dataFormatada),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isBalanceVisible
                    ? '$valorSinal${NumberFormat("#,##0.00", "pt_BR").format(movi.valor)}'
                    : '****',
                style: AppTextStyles.cardheaderText.copyWith(color: isBalanceVisible ? valorColor : Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openFilterModal(BuildContext context, Function(DateTime, DateTime, String) onFilterApplied) {
    DateTime startDate = DateTime.now().subtract(Duration(days: 30));
    DateTime endDate = DateTime.now();
    String orderBy = 'desc'; // Definir a ordem padrão como decrescente

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Filtrar Movimentações',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text('Intervalo de Datas'),
                    subtitle: Text(
                      '${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}',
                    ),
                    onTap: () async {
                      final picked = await showDialog<List<DateTime>>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Selecione o Intervalo de Datas'),
                            content: Container(
                              height: 300,
                              child: dp.RangePicker(
                                selectedPeriod: dp.DatePeriod(startDate, endDate),
                                onChanged: (dp.DatePeriod newPeriod) {
                                  setState(() {
                                    startDate = newPeriod.start;
                                    endDate = newPeriod.end;
                                  });
                                },
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                                datePickerStyles: dp.DatePickerRangeStyles(
                                  selectedPeriodLastDecoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(10.0),
                                      bottomRight: Radius.circular(10.0),
                                    ),
                                  ),
                                  selectedPeriodStartDecoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10.0),
                                      bottomLeft: Radius.circular(10.0),
                                    ),
                                  ),
                                  selectedPeriodMiddleDecoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.5),
                                    shape: BoxShape.rectangle,
                                  ),
                                  dayHeaderStyle: dp.DayHeaderStyle(
                                    textStyle: TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  currentDateStyle: TextStyle(color: Colors.red), // Current date style
                                  selectedDateStyle: TextStyle(color: Colors.white), // Selected date style
                                  defaultDateTextStyle: TextStyle(color: Colors.black), // Default date style
                                ),
                                datePickerLayoutSettings: dp.DatePickerLayoutSettings(
                                  maxDayPickerRowCount: 2,
                                ),
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancelar'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.pop(context, [startDate, endDate]);
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (picked != null && picked.length == 2) {
                        setState(() {
                          startDate = picked[0];
                          endDate = picked[1];
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: [
                        Text('Ordenar por'),
                        const SizedBox(width: 16),
                        DropdownButton<String>(
                          value: orderBy,
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                orderBy = value;
                              });
                            }
                          },
                          items: <String>['asc', 'desc'].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value == 'asc' ? 'Crescente' : 'Decrescente'),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          onFilterApplied(startDate, endDate, orderBy);
                          Navigator.of(context).pop();
                        },
                        child: Text('Filtrar'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Movimentacao>> fetchFilteredMovis(DateTime startDate, DateTime endDate, String orderBy) async {
    final String startDateString = DateFormat('yyyy-MM-dd').format(startDate);
    final String endDateString = DateFormat('yyyy-MM-dd').format(endDate);
    final movimentacoes = await MovimentacaoDB().fetchByDateRange(startDateString, endDateString);

    if (orderBy == 'desc') {
      movimentacoes.sort((a, b) => b.data.compareTo(a.data));
    } else {
      movimentacoes.sort((a, b) => a.data.compareTo(b.data));
    }

    return movimentacoes;
  }
}

class GuardarSaldo extends StatefulWidget {
  final DateTime? selectedDay;
  final VoidCallback onSave;

  const GuardarSaldo({Key? key, this.selectedDay, required this.onSave}) : super(key: key);

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
              inputFormatters: [],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            int? meta_id = _selectedMeta?.id;
            String categoria = "Metas";
            double valor = _real.parseValor(_valorController.text);

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
              widget.onSave(); // Chama o callback para atualizar a lista
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
  final VoidCallback onSave;

  const PagarConta({Key? key, this.selectedDay, required this.onSave}) : super(key: key);

  @override
  _PagarContaState createState() => _PagarContaState();
}

class _PagarContaState extends State<PagarConta> {
  TextEditingController _valorController = TextEditingController();
  Conta? _selectedConta; // Conta selecionada
  List<Conta> _contas = []; // Lista de contas
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
    ContaDB contaDB = ContaDB();
    List<Conta> contas = await contaDB.fetchAll();
    setState(() {
      _contas = contas;
      if (_contas.isNotEmpty) {
        _selectedConta = _contas[0]; // Seleciona a primeira conta por padrão
        _valorController.text = _real.formatValor(_selectedConta!.valor);
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
            DropdownButtonFormField<Conta>(
              value: _selectedConta,
              items: _contas.map((Conta conta) {
                return DropdownMenuItem<Conta>(
                  value: conta,
                  child: Text(conta.titulo),
                );
              }).toList(),
              onChanged: (Conta? newConta) {
                setState(() {
                  _selectedConta = newConta;
                  _valorController.text = _selectedConta != null ? _real.formatValor(_selectedConta!.valor) : '';
                });
              },
              decoration: InputDecoration(labelText: 'Selecione uma Conta'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Valor'),
              inputFormatters: [],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            if (_selectedConta != null) {
              bool isPaid = await ContaDB().isPaymentMadeThisMonth(_selectedConta!.id);

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
                double valor = _real.parseValor(_valorController.text);
                String categoria = "Contas";

                await MovimentacaoDB().create3(
                  data: DateFormat('yyyy-MM-dd').format(_dataLimite),
                  valor: valor,
                  categoria: categoria,
                  descricao: 'Pago conta ${_selectedConta!.titulo}',
                  tipo: 3,
                  conta_id: _selectedConta!.id,
                );
                widget.onSave();
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
  final VoidCallback onSave;

  const PagarDivida({Key? key, this.selectedDay, required this.onSave}) : super(key: key);

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
    _fetchDividas(); // Carrega as dividas ao iniciar
  }

  Future<void> _fetchDividas() async {
    DividaDB dividaDB = DividaDB();
    List<Divida> dividas = await dividaDB.fetchAll();
    setState(() {
      _dividas = dividas;
      if (_dividas.isNotEmpty) {
        _selectedDivida = _dividas[0]; // Seleciona a primeira divida por padrão
        _valorController.text = _real.formatValor(_selectedDivida!.valor_parcela);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pagar Dívida'),
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
                  _valorController.text = _selectedDivida != null ? _real.formatValor(_selectedDivida!.valor_parcela) : '';
                });
              },
              decoration: InputDecoration(labelText: 'Selecione uma Dívida'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Valor'),
              inputFormatters: [],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            if (_selectedDivida != null) {
              double valor = _real.parseValor(_valorController.text);
              String categoria = "Dividas";

              await MovimentacaoDB().create4(
                data: DateFormat('yyyy-MM-dd').format(_dataLimite),
                valor: valor,
                categoria: categoria,
                descricao: 'Pago dívida ${_selectedDivida!.titulo}',
                tipo: 4,
                divida_id: _selectedDivida!.id,
              );
              widget.onSave();
              Navigator.of(context).pop(true);
            } else {
              print('Nenhuma dívida selecionada!');
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
