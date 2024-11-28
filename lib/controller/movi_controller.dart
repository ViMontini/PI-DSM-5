import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:despesa_digital/controller/real.dart';
import 'package:despesa_digital/controller/sync_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../database/carteira_db.dart';
import '../database/conta_db.dart';
import '../database/database_service.dart';
import '../database/divida_db.dart';
import '../database/meta_db.dart';
import '../database/movi_db.dart';
import '../database/saldo_db.dart';
import '../model/conta.dart';
import '../model/divida.dart';
import '../model/meta.dart';
import '../model/movimentacao.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/moeda_formatter.dart';

import 'categorizer.dart';

Real _real = Real();

var connectivityResult = Connectivity().checkConnectivity();

DatabaseService databaseService = DatabaseService();

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
  bool _saldoJaFoiNegativo = false; // Verifica se o saldo já entrou no negativo antes

  List<Widget> tipos = <Widget>[
    Text(('DESPESA'), style: TextStyle(fontSize: 15)),
    Text(('RECEITA'), style: TextStyle(fontSize: 15))
  ];

  final List<bool> _selectedTypes = <bool>[true, false];
  final Color despesaColor = Colors.red; // Cor para Despesa
  final Color receitaColor = Colors.green; // Cor para Receita
  int tipo = 0;
  double saldoTotal = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.selectedDay != null) {
      _dataLimite = widget.selectedDay!;
    }
    _fetchSaldoAtual(); // Carrega o saldo atual ao iniciar
  }

  Future<void> _fetchSaldoAtual() async {
    final saldo = await SaldoDB().getSaldoAtual();
    setState(() {
      saldoTotal = saldo;
    });
  }

  Future<void> _adicionarMovimentacao(String descricao, double valor, int tipo) async {
    try {
      String data = DateFormat('yyyy-MM-dd').format(_dataLimite);
      String categoria = await Categorizer.categorize(descricao);

      // Adiciona a movimentação ao banco local
      MovimentacaoDB().create(
        data: data,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
        tipo: tipo,
      );

      // Verifica conexão com a internet e aciona sincronização
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await DatabaseService().syncMoviToFB();
      } else {
        print('Sem conexão com a internet. A sincronização será feita depois.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Movimentação realizada com sucesso!')),
      );

      Navigator.of(context).pop(true);
      widget.onSave(); // Atualiza a lista de movimentações
    } catch (e) {
      print('Erro ao adicionar a movimentação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar a movimentação.')),
      );
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Movimentação', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Saldo Total do Usuário
            Center(
              child: Text(
                'Saldo Total: ${saldoTotal < 0 ? '- R\$${NumberFormat("#,##0.00", "pt_BR").format(-saldoTotal)}' : 'R\$${NumberFormat("#,##0.00", "pt_BR").format(saldoTotal)}'}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.purplelightMain),
              ),
            ),
            const SizedBox(height: 16),

            // Botões de Tipo (Despesa ou Receita)
            Center(
              child: ToggleButtons(
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _selectedTypes.length; i++) {
                      _selectedTypes[i] = i == index;
                    }
                    tipo = _selectedTypes[0] ? 0 : 1; // 0 para Despesa, 1 para Receita
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
            ),
            // Campo de Valor
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Valor'),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // Permite apenas números
                MoedaTextInputFormatter(), // Formata como moeda
              ],
            ),

            // Campo de Descrição
            TextField(
              controller: _descricaoController,
              decoration: InputDecoration(labelText: 'Descrição'),
            ),
            // Campo de Data
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
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
            setState(() {
              _isLoading = true;
            });

            String valorTexto = _valorController.text;
            String descricao = _descricaoController.text;

            if (valorTexto.isEmpty || descricao.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, insira um valor e uma descrição.')),
              );
              setState(() {
                _isLoading = false;
              });
              return;
            }

            try {
              String valorLimpo = valorTexto.replaceAll(RegExp(r'[^\d,]'), '');
              double valor = double.parse(valorLimpo.replaceAll(',', '.'));

              if (valor <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('O valor deve ser maior que zero.')),
                );
                setState(() {
                  _isLoading = false;
                });
                return;
              }

              double novoSaldo = saldoTotal + (tipo == 1 ? valor : -valor);

              // Verifica a transição do saldo de positivo para negativo
              if (saldoTotal >= 0 && novoSaldo < 0 && !_saldoJaFoiNegativo) {
                bool? confirmar = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Atenção'),
                      content: Text(
                        'Você está prestes a ficar com o saldo negativo. Deseja continuar?',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Continuar'),
                        ),
                      ],
                    );
                  },
                );

                if (confirmar != true) {
                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }

                _saldoJaFoiNegativo = true; // Marca que a transição foi confirmada
              }

              // Reseta o estado se o saldo voltar para positivo
              if (novoSaldo >= 0) {
                _saldoJaFoiNegativo = false;
              }

              await _adicionarMovimentacao(descricao, valor, tipo);
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          },
          child: _isLoading ? CircularProgressIndicator() : Text('Confirmar'),
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
  final Color dividaColor = Colors.deepOrangeAccent;
  final Color carteiraColor = Colors.pinkAccent;// Cor para Dinheiro Guardado

  Future<List<Movimentacao>> fetchAllMovisAsc() async {
    return await _moviDB.fetchAllAsc();
  }

  Future<List<Movimentacao>> fetchAllMovisDesc() async {
    return await _moviDB.fetchAllDesc();
  }

  Future<List<Movimentacao>> fetchMovisByDateRange(String startDate, String endDate) async {
    return await _moviDB.fetchByDateRange(startDate, endDate);
  }

  Future<void> realizarEstorno(int moviId) async {
    try {
      await _moviDB.marcarComoEstornado(moviId);
    } catch (e) {
      throw Exception('Erro ao realizar estorno: $e');
    }
  }

  IconData getIconForCategory(String category) {
    switch (category) {
      case 'Metas':
        return Icons.savings;
      case 'Dívidas':
        return Icons.shopping_cart;
      case 'Contas':
        return Icons.payment;
      case 'Carteira':
        return Icons.wallet;
      default:
        return Icons.currency_exchange;
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
            tipoText = 'METAS';
            tipoColor = guardadoColor;
            break;
          case 3:
            tipoText = 'CONTA';
            tipoColor = contaColor;
            break;
          case 4:
            tipoText = 'DÍVIDA';
            tipoColor = dividaColor;
            break;
          case 5:
            tipoText = 'CARTEIRA';
            tipoColor = carteiraColor;
            break;
          case 6:
            tipoText = 'CARTEIRA';
            tipoColor = carteiraColor;
            break;
          case 7:
            tipoText = 'METAS';
            tipoColor = guardadoColor;
            break;
          default:
            tipoText = 'DESCONHECIDO';
            tipoColor = Colors.grey;
        }

        // Adiciona " - ESTORNADO" se a movimentação estiver marcada como estornada
        if (movi.estornado == 1) {
          tipoText += ' - ESTORNADO';
        }

        // Verifica se o tipo da movimentação pode ser estornado
        bool podeEstornar = ![2, 5, 6, 7].contains(movi.tipo);

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
              Text('Data: $dataFormatada'),
              Text('Valor: R\$${NumberFormat("#,##0.00", "pt_BR").format(movi.valor)}'),
              Text('Descrição: ${movi.descricao}'),
              Text('Categoria: ${movi.categoria}'),
            ],
          ),
          actions: <Widget>[
            if (podeEstornar) // Exibe o botão de estorno apenas se for permitido
              TextButton(
                onPressed: () async {
                  if (movi.estornado == 1) {
                    // Alerta para movimentação já estornada
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Essa movimentação já foi estornada!')),
                    );
                  } else {
                    bool? confirmar = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Confirmar Estorno'),
                          content: Text('Tem certeza de que deseja estornar esta movimentação?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Confirmar'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmar == true) {
                      try {
                        final MoviController moviController = MoviController();
                        await moviController.realizarEstorno(movi.id);
                        Navigator.of(context).pop();
                        atualizarMovis();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Movimentação estornada com sucesso!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$e')), // Exibe mensagem de erro específica
                        );
                      }
                    }
                  }
                },
                child: Text('Estornar'),
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
        tipoText = 'METAS';
        tipoColor = guardadoColor;
        valorColor = Colors.red;
        valorSinal = '-';
        break;
      case 3:
        tipoText = 'CONTA';
        tipoColor = contaColor;
        valorColor = Colors.red;
        valorSinal = '-';
        break;
      case 4:
        tipoText = 'DÍVIDA';
        tipoColor = dividaColor;
        valorColor = Colors.red;
        valorSinal = '-';
        break;
      case 5:
        tipoText = 'CARTEIRA';
        tipoColor = dividaColor;
        valorColor = Colors.red;
        valorSinal = '-';
        break;
      case 6:
        tipoText = 'CARTEIRA';
        tipoColor = dividaColor;
        valorColor = Colors.green;
        valorSinal = '+';
        break;
      case 7:
        tipoText = 'METAS';
        tipoColor = dividaColor;
        valorColor = Colors.green;
        valorSinal = '+';
        break;
      default:
        tipoText = 'DESCONHECIDO';
        tipoColor = Colors.grey;
        valorColor = Colors.grey;
        valorSinal = '';
    }

    // Verifica se a movimentação está estornada
    if (movi.estornado == 1) {
      valorColor = Colors.grey; // Define a cor azul para valores de movimentações estornadas
    }

    // Atualiza o ícone caso a movimentação esteja estornada
    IconData categoryIcon = movi.estornado == 1 ? Icons.keyboard_return : getIconForCategory(movi.categoria);

    return GestureDetector(
      onTap: () {
        mostrarDetalhesMovi(context, movi, atualizarMetas);
      },
      child: Card.outlined(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: AppColors.purplelightMain, width: 2.0),
          borderRadius: BorderRadius.circular(25.0),
        ),
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
                '$valorSinal\R\$${NumberFormat("#,##0.00", "pt_BR").format(movi.valor)}',
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
      case 5:
        tipoText = 'CARTEIRA';
        tipoColor = dividaColor;
        valorColor = Colors.red;
        valorSinal = '-';
        break;
      case 6:
        tipoText = 'CARTEIRA';
        tipoColor = dividaColor;
        valorColor = Colors.green;
        valorSinal = '+';
        break;
      case 7:
        tipoText = 'METAS';
        tipoColor = dividaColor;
        valorColor = Colors.green;
        valorSinal = '+';
        break;
      default:
        tipoText = 'DESCONHECIDO';
        tipoColor = Colors.grey;
        valorColor = Colors.grey;
        valorSinal = '';
    }

    // Verifica se a movimentação está estornada
    if (movi.estornado == 1) {
      valorColor = Colors.grey; // Define a cor azul para valores de movimentações estornadas
      tipoText = '$tipoText - ESTORNADO'; // Adiciona "- ESTORNADO" no tipo
    }

    // Atualiza o ícone caso a movimentação esteja estornada
    IconData categoryIcon = movi.estornado == 1 ? Icons.keyboard_return : getIconForCategory(movi.categoria);

    return GestureDetector(
      onTap: () {},
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
                    ? '$valorSinal\R\$${NumberFormat("#,##0.00", "pt_BR").format(movi.valor)}'
                    : '****',
                style: AppTextStyles.cardheaderText.copyWith(color: isBalanceVisible ? valorColor : Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void openFilterModal(
      BuildContext context, Function(DateTime, DateTime, List<int>) onFilterApplied) {
    DateTime startDate = DateTime.now().subtract(Duration(days: 30));
    DateTime endDate = DateTime.now();
    List<int> selectedTypes = [];

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
                    title: Text('Tipos de Movimentação'),
                    subtitle: Text(
                      selectedTypes.isEmpty
                          ? 'Nenhum tipo selecionado'
                          : 'Tipos selecionados: ${selectedTypes.join(', ')}',
                    ),
                    onTap: () async {
                      final selected = await showDialog<List<int>>(
                        context: context,
                        builder: (BuildContext context) {
                          List<int> tempSelectedTypes = [...selectedTypes];
                          return AlertDialog(
                            title: Text('Selecione os Tipos'),
                            content: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setStateDialog) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CheckboxListTile(
                                      title: Text('Despesas'),
                                      value: tempSelectedTypes.contains(0),
                                      onChanged: (bool? value) {
                                        setStateDialog(() {
                                          if (value == true) {
                                            tempSelectedTypes.add(0);
                                          } else {
                                            tempSelectedTypes.remove(0);
                                          }
                                        });
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: Text('Receitas'),
                                      value: tempSelectedTypes.contains(1),
                                      onChanged: (bool? value) {
                                        setStateDialog(() {
                                          if (value == true) {
                                            tempSelectedTypes.add(1);
                                          } else {
                                            tempSelectedTypes.remove(1);
                                          }
                                        });
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: Text('Pagamento de Contas'),
                                      value: tempSelectedTypes.contains(3),
                                      onChanged: (bool? value) {
                                        setStateDialog(() {
                                          if (value == true) {
                                            tempSelectedTypes.add(3);
                                          } else {
                                            tempSelectedTypes.remove(3);
                                          }
                                        });
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: Text('Pagamento de Dívidas'),
                                      value: tempSelectedTypes.contains(4),
                                      onChanged: (bool? value) {
                                        setStateDialog(() {
                                          if (value == true) {
                                            tempSelectedTypes.add(4);
                                          } else {
                                            tempSelectedTypes.remove(4);
                                          }
                                        });
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: Text('Metas'),
                                      value: tempSelectedTypes.contains(2),
                                      onChanged: (bool? value) {
                                        setStateDialog(() {
                                          if (value == true) {
                                            if (!tempSelectedTypes.contains(2)) {
                                              tempSelectedTypes.add(2);
                                            }
                                            if (!tempSelectedTypes.contains(7)) {
                                              tempSelectedTypes.add(7);
                                            }
                                          } else {
                                            tempSelectedTypes.remove(2);
                                            tempSelectedTypes.remove(7);
                                          }
                                        });
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: Text('Carteira'),
                                      value: tempSelectedTypes.contains(5) && tempSelectedTypes.contains(6),
                                      onChanged: (bool? value) {
                                        setStateDialog(() {
                                          if (value == true) {
                                            if (!tempSelectedTypes.contains(5)) {
                                              tempSelectedTypes.add(5);
                                            }
                                            if (!tempSelectedTypes.contains(6)) {
                                              tempSelectedTypes.add(6);
                                            }
                                          } else {
                                            tempSelectedTypes.remove(5);
                                            tempSelectedTypes.remove(6);
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancelar'),
                                onPressed: () {
                                  Navigator.pop(context, selectedTypes);
                                },
                              ),
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.pop(context, tempSelectedTypes);
                                },
                              ),
                            ],
                          );
                        },
                      );

                      if (selected != null) {
                        setState(() {
                          selectedTypes = selected;
                        });
                      }
                    },
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
                          onFilterApplied(startDate, endDate, selectedTypes);
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

  Future<List<Movimentacao>> fetchFilteredMovis(DateTime startDate, DateTime endDate, List<int> selectedTypes) async {
    final String startDateString = DateFormat('yyyy-MM-dd').format(startDate);
    final String endDateString = DateFormat('yyyy-MM-dd').format(endDate);

    final movimentacoes = await MovimentacaoDB().fetchByFilters(startDateString, endDateString, selectedTypes);

    return movimentacoes;
  }

}

class MetaMoviPage extends StatefulWidget {
  final DateTime? selectedDay;
  final VoidCallback onSave;

  const MetaMoviPage({Key? key, this.selectedDay, required this.onSave}) : super(key: key);

  @override
  _MetaMoviPageState createState() => _MetaMoviPageState();
}

class _MetaMoviPageState extends State<MetaMoviPage> {
  TextEditingController _valorController = TextEditingController();
  Meta? _selectedMeta; // Meta selecionada
  List<Meta> _metas = []; // Lista de metas
  DateTime _dataLimite = DateTime.now();
  bool _isLoading = false;
  bool _saldoJaFoiNegativo = false; // Estado para verificar se já houve transição para negativo

  List<Widget> tipos = <Widget>[
    Text('Guardar', style: TextStyle(fontSize: 15)),
    Text('Retirar', style: TextStyle(fontSize: 15))
  ];

  final List<bool> _selectedTypes = <bool>[true, false];
  final Color retirarColor = Colors.red; // Cor para Retirar
  final Color guardarColor = Colors.green; // Cor para Guardar
  int tipo = 2; // 2 para guardar, 7 para retirar
  double saldoTotal = 0.0; // Saldo total do usuário

  @override
  void initState() {
    super.initState();
    if (widget.selectedDay != null) {
      _dataLimite = widget.selectedDay!;
    }
    _fetchMetas(); // Carrega as metas ao iniciar
    _fetchSaldoAtual(); // Carrega o saldo total do usuário
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

  Future<void> _fetchSaldoAtual() async {
    final saldo = await SaldoDB().getSaldoAtual();
    setState(() {
      saldoTotal = saldo;
    });
  }

  Future<void> _confirmarMovimentacao() async {
    setState(() {
      _isLoading = true;
    });

    int? metaId = _selectedMeta?.id;
    String valorTexto = _valorController.text;

    // Verificação de meta e valor
    if (metaId == null || valorTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecione uma meta e insira um valor.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Remove o prefixo "R$" e outros caracteres não numéricos
      String valorLimpo = valorTexto.replaceAll(RegExp(r'[^\d,]'), '');
      double valor = double.parse(valorLimpo.replaceAll(',', '.'));

      // Verifica se o valor é maior que zero
      if (valor <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('O valor deve ser maior que zero.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (tipo == 2) {
        // Guardar saldo: verificar transição do saldo total para negativo
        double novoSaldoTotal = saldoTotal - valor;

        if (saldoTotal >= 0 && novoSaldoTotal < 0 && !_saldoJaFoiNegativo) {
          bool? confirmar = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Atenção'),
                content: Text(
                  'Você está prestes a ficar com o saldo total negativo. Deseja continuar?',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Continuar'),
                  ),
                ],
              );
            },
          );

          if (confirmar != true) {
            setState(() {
              _isLoading = false;
            });
            return;
          }

          _saldoJaFoiNegativo = true; // Marca que a transição foi confirmada
        }

        // Reseta o estado se o saldo voltar para positivo
        if (novoSaldoTotal >= 0) {
          _saldoJaFoiNegativo = false;
        }
      } else {
        // Retirar saldo: verificar se o saldo guardado da meta ficará negativo
        double saldoGuardado = _selectedMeta!.valor_guardado;
        double novoSaldoGuardado = saldoGuardado - valor;

        if (novoSaldoGuardado < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saldo insuficiente na meta selecionada.')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Criar movimentação
      await MovimentacaoDB().create2(
        data: DateFormat('yyyy-MM-dd').format(_dataLimite),
        valor: valor,
        categoria: "Metas",
        descricao: tipo == 2
            ? 'Guardado para Meta ${_selectedMeta!.titulo}'
            : 'Retirado da Meta ${_selectedMeta!.titulo}',
        tipo: tipo,
        meta_id: metaId,
      );

      // Verifica conexão com a internet e aciona sincronização
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await DatabaseService().syncMoviMetaToFB();
      } else {
        print('Sem conexão com a internet. A sincronização será feita depois.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Movimentação realizada com sucesso!')),
      );

      Navigator.of(context).pop(true);
      widget.onSave();
    } catch (e) {
      print('Erro ao movimentar saldo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao movimentar saldo. Verifique os valores inseridos.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Meta', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Saldo Total do Usuário
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Centraliza na horizontal
                children: [
                  Text(
                    'Saldo Total: ${saldoTotal < 0 ? '-' : ''} R\$${NumberFormat("#,##0.00", "pt_BR").format(saldoTotal.abs())}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.purplelightMain),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Selecionador de Meta
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
            const SizedBox(height: 16),
            // Informações da Meta Selecionada
            if (_selectedMeta != null)
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Centraliza na horizontal
                  children: [
                    Text(
                      'Valor Alvo: R\$${NumberFormat("#,##0.00", "pt_BR").format(_selectedMeta!.valor_total)}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Valor Guardado: R\$${NumberFormat("#,##0.00", "pt_BR").format(_selectedMeta!.valor_guardado)}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            // Botões de Ação (Guardar ou Retirar)
            Center(
              child: ToggleButtons(
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _selectedTypes.length; i++) {
                      _selectedTypes[i] = i == index;
                    }
                    tipo = _selectedTypes[0] ? 2 : 7; // Guardar ou Retirar
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderColor: Colors.grey,
                selectedBorderColor: _selectedTypes[0] ? guardarColor : retirarColor,
                selectedColor: Colors.white,
                fillColor: _selectedTypes[0] ? guardarColor : retirarColor,
                color: Colors.black54,
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 100.0,
                ),
                isSelected: _selectedTypes,
                children: tipos,
              ),
            ),
            // Campo de Entrada de Valor
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Valor'),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // Permite apenas números
                MoedaTextInputFormatter(), // Formata o valor como moeda
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _confirmarMovimentacao,
          child: _isLoading ? CircularProgressIndicator() : Text('Confirmar'),
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
  double saldoTotal = 0.0;
  bool _isLoading = false;
  bool _saldoJaFoiNegativo = false; // Verifica se o saldo já ficou negativo antes

  @override
  void initState() {
    super.initState();
    if (widget.selectedDay != null) {
      _dataLimite = widget.selectedDay!;
    }
    _fetchContas();
    _fetchSaldoAtual();
  }

  Future<void> _fetchContas() async {
    ContaDB contaDB = ContaDB();
    List<Conta> contas = await contaDB.fetchAll();
    setState(() {
      _contas = contas;
      if (_contas.isNotEmpty) {
        _selectedConta = _contas[0]; // Seleciona a primeira conta por padrão
        String valorFormatado = _selectedConta!.valor.toStringAsFixed(2);
        _valorController.text = MoedaTextInputFormatter().formatEditUpdate(
          TextEditingValue(text: ''),
          TextEditingValue(text: valorFormatado),
        ).text;
      }
    });
  }

  Future<void> _fetchSaldoAtual() async {
    final saldo = await SaldoDB().getSaldoAtual();
    setState(() {
      saldoTotal = saldo;
    });
  }

  Future<void> _pagarConta(double valor, int contaId, String descricao) async {
    try {
      // Verifica se a conta já foi paga no mês atual
      bool isPaid = await ContaDB().isPaymentMadeThisMonth(contaId);

      if (isPaid) {
        bool? confirmarPagamento = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Confirmação'),
              content: Text('Você já realizou o pagamento desta conta neste mês. Deseja continuar?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Continuar'),
                ),
              ],
            );
          },
        );

        if (confirmarPagamento != true) {
          // Se o usuário cancelar, interrompe o processo
          return;
        }
      }

      String data = DateFormat('yyyy-MM-dd').format(_dataLimite);
      String categoria = "Contas";

      // Cria a movimentação no banco local
      await MovimentacaoDB().create3(
        data: data,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
        tipo: 3,
        conta_id: contaId,
      );

      // Verifica conexão com a internet e realiza a sincronização
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await DatabaseService().syncMoviContaToFB();
      } else {
        print('Sem conexão com a internet. A sincronização será feita depois.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conta paga com sucesso!')),
      );

      Navigator.of(context).pop(true);
      widget.onSave();
    } catch (e) {
      print('Erro ao pagar a conta: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao pagar a conta. Verifique os valores inseridos.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Conta', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Saldo Total
            Center(
              child: Text(
                'Saldo Total: ${saldoTotal < 0 ? '- R\$${NumberFormat("#,##0.00", "pt_BR").format(-saldoTotal)}' : 'R\$${NumberFormat("#,##0.00", "pt_BR").format(saldoTotal)}'}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.purplelightMain),
              ),
            ),
            // Selecionador de Conta
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
                  if (_selectedConta != null) {
                    String valorFormatado = _selectedConta!.valor.toStringAsFixed(2);
                    _valorController.text = MoedaTextInputFormatter().formatEditUpdate(
                      TextEditingValue(text: ''),
                      TextEditingValue(text: valorFormatado),
                    ).text;
                  } else {
                    _valorController.text = '';
                  }
                });
              },
              decoration: InputDecoration(labelText: 'Selecione uma Conta'),
            ),
            // Campo de Valor
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Valor'),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                MoedaTextInputFormatter(),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
            setState(() {
              _isLoading = true;
            });

            int? contaId = _selectedConta?.id;
            String valorTexto = _valorController.text;

            if (contaId == null || valorTexto.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, selecione uma conta e insira um valor.')),
              );
              setState(() {
                _isLoading = false;
              });
              return;
            }

            try {
              String valorLimpo = valorTexto.replaceAll(RegExp(r'[^\d,]'), '');
              double valor = double.parse(valorLimpo.replaceAll(',', '.'));

              if (valor <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('O valor deve ser maior que zero.')),
                );
                setState(() {
                  _isLoading = false;
                });
                return;
              }

              double novoSaldo = saldoTotal - valor;

              if (saldoTotal >= 0 && novoSaldo < 0 && !_saldoJaFoiNegativo) {
                bool? confirmar = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Atenção'),
                      content: Text(
                        'Você está prestes a ficar com o saldo negativo. Deseja continuar?',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Continuar'),
                        ),
                      ],
                    );
                  },
                );

                if (confirmar != true) {
                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }

                _saldoJaFoiNegativo = true;
              }

              if (novoSaldo >= 0) {
                _saldoJaFoiNegativo = false;
              }

              await _pagarConta(valor, contaId, 'Pago conta ${_selectedConta!.titulo}');
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          },
          child: _isLoading ? CircularProgressIndicator() : Text('Confirmar'),
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
  Divida? _selectedDivida;
  List<Divida> _dividas = [];
  DateTime _dataLimite = DateTime.now();
  double saldoTotal = 0.0;
  bool _isLoading = false;
  bool _saldoJaFoiNegativo = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedDay != null) {
      _dataLimite = widget.selectedDay!;
    }
    _fetchDividas();
    _fetchSaldoAtual();
  }

  Future<void> _fetchDividas() async {
    DividaDB dividaDB = DividaDB();
    List<Divida> dividas = await dividaDB.fetchAll();
    setState(() {
      _dividas = dividas;
      if (_dividas.isNotEmpty) {
        _selectedDivida = _dividas[0];
        _valorController.text = _real.formatValor(_selectedDivida!.valor_parcela);
      }
    });
  }

  Future<void> _fetchSaldoAtual() async {
    final saldo = await SaldoDB().getSaldoAtual();
    setState(() {
      saldoTotal = saldo;
    });
  }

  Future<void> _pagarDivida(double valor, int dividaId, String descricao) async {
    try {
      // Verifica se o pagamento já foi realizado no mês atual
      bool isPaid = await DividaDB().isPaymentMadeThisMonth(dividaId);

      if (isPaid) {
        bool? confirmarPagamento = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Confirmação'),
              content: Text('Você já realizou o pagamento desta dívida neste mês. Deseja continuar?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Continuar'),
                ),
              ],
            );
          },
        );

        if (confirmarPagamento != true) {
          // Se o usuário cancelar, interrompe o processo
          return;
        }
      }

      String data = DateFormat('yyyy-MM-dd').format(_dataLimite);
      String categoria = "Dívidas";

      // Cria a movimentação no banco local
      await MovimentacaoDB().create4(
        data: data,
        valor: valor,
        categoria: categoria,
        descricao: descricao,
        tipo: 4,
        divida_id: dividaId,
      );

      // Sincroniza após adicionar ao banco
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await DatabaseService().syncMoviDividaToFB();
      } else {
        print('Sem conexão com a internet. A sincronização será feita depois.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dívida paga com sucesso!')),
      );

      Navigator.of(context).pop(true);
      widget.onSave();
    } catch (e) {
      print('Erro ao pagar a dívida: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao pagar a dívida. Verifique os valores inseridos.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Dívida', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                'Saldo Total: ${saldoTotal < 0 ? '- R\$${NumberFormat("#,##0.00", "pt_BR").format(-saldoTotal)}' : 'R\$${NumberFormat("#,##0.00", "pt_BR").format(saldoTotal)}'}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.purplelightMain),
              ),
            ),
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
                  _valorController.text = _selectedDivida != null
                      ? _real.formatValor(_selectedDivida!.valor_parcela)
                      : '';
                });
              },
              decoration: InputDecoration(labelText: 'Selecione uma Dívida'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
            setState(() {
              _isLoading = true;
            });

            int? dividaId = _selectedDivida?.id;
            String valorTexto = _valorController.text;

            if (dividaId == null || valorTexto.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Por favor, selecione uma dívida e insira um valor.')),
              );
              setState(() {
                _isLoading = false;
              });
              return;
            }

            try {
              String valorLimpo = valorTexto.replaceAll(RegExp(r'[^\d,]'), '');
              double valor = double.parse(valorLimpo.replaceAll(',', '.'));

              if (valor <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('O valor deve ser maior que zero.')),
                );
                setState(() {
                  _isLoading = false;
                });
                return;
              }

              double novoSaldo = saldoTotal - valor;

              if (saldoTotal >= 0 && novoSaldo < 0 && !_saldoJaFoiNegativo) {
                bool? confirmar = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Atenção'),
                      content: Text(
                        'Você está prestes a ficar com o saldo negativo. Deseja continuar?',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Continuar'),
                        ),
                      ],
                    );
                  },
                );

                if (confirmar != true) {
                  setState(() {
                    _isLoading = false;
                  });
                  return;
                }

                _saldoJaFoiNegativo = true;
              }

              if (novoSaldo >= 0) {
                _saldoJaFoiNegativo = false;
              }

              await _pagarDivida(valor, dividaId, 'Pago dívida ${_selectedDivida!.titulo}');
            } finally {
              setState(() {
                _isLoading = false;
              });
            }
          },
          child: _isLoading ? CircularProgressIndicator() : Text('Confirmar'),
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


class CarteiraMoviPage extends StatefulWidget {
  final DateTime? selectedDay;
  final VoidCallback onSave;

  const CarteiraMoviPage({Key? key, this.selectedDay, required this.onSave}) : super(key: key);

  @override
  _CarteiraMoviPageState createState() => _CarteiraMoviPageState();
}

class _CarteiraMoviPageState extends State<CarteiraMoviPage> {
  TextEditingController _valorController = TextEditingController();
  DateTime _dataLimite = DateTime.now();
  bool _isLoading = false;

  List<Widget> tipos = <Widget>[
    Text('Guardar', style: TextStyle(fontSize: 15)),
    Text('Retirar', style: TextStyle(fontSize: 15)),
  ];

  final List<bool> _selectedTypes = <bool>[true, false];
  final Color retirarColor = Colors.red; // Cor para Retirar
  final Color guardarColor = Colors.green; // Cor para Guardar
  int tipo = 5;

  double saldoTotal = 0.0; // Saldo total do usuário
  double saldoCarteira = 0.0; // Saldo na carteira

  bool _saldoTotalJaFoiNegativo = false; // Controle para saldo total
  bool _saldoCarteiraJaFoiNegativo = false; // Controle para saldo da carteira

  @override
  void initState() {
    super.initState();
    if (widget.selectedDay != null) {
      _dataLimite = widget.selectedDay!;
    }
    _fetchSaldoAtual();
    _fetchSaldoCarteira();
  }

  Future<void> _fetchSaldoAtual() async {
    final saldo = await SaldoDB().getSaldoAtual();
    setState(() {
      saldoTotal = saldo;
    });
  }

  Future<void> _fetchSaldoCarteira() async {
    final saldo = await CarteiraDB().obterSaldo();
    setState(() {
      saldoCarteira = saldo;
    });
  }

  Future<void> _confirmarMovimentacao() async {
    setState(() {
      _isLoading = true;
    });

    String valorTexto = _valorController.text;

    if (valorTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, insira um valor.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      String valorLimpo = valorTexto.replaceAll(RegExp(r'[^\d,]'), '');
      double valor = double.parse(valorLimpo.replaceAll(',', '.'));

      if (valor <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('O valor deve ser maior que zero.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (tipo == 5) {
        // Guardar na carteira: verificar se saldo total ficará negativo
        double novoSaldoTotal = saldoTotal - valor;

        if (saldoTotal >= 0 && novoSaldoTotal < 0 && !_saldoTotalJaFoiNegativo) {
          bool? confirmar = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Atenção'),
                content: Text(
                  'Você está prestes a ficar com o saldo total negativo. Deseja continuar?',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Continuar'),
                  ),
                ],
              );
            },
          );

          if (confirmar != true) {
            setState(() {
              _isLoading = false;
            });
            return;
          }

          _saldoTotalJaFoiNegativo = true; // Marca a transição confirmada
        }

        if (novoSaldoTotal >= 0) {
          _saldoTotalJaFoiNegativo = false; // Reseta quando o saldo volta a ser positivo
        }
      } else {
        // Retirar da carteira: verificar se saldo da carteira ficará negativo
        double novoSaldoCarteira = saldoCarteira - valor;

        if (novoSaldoCarteira < 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saldo insuficiente na carteira.')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Criar movimentação
      MovimentacaoDB().create(
        data: DateFormat('yyyy-MM-dd').format(_dataLimite),
        valor: valor,
        categoria: "Carteira",
        descricao: tipo == 5 ? 'Guardado na Carteira' : 'Retirado da Carteira',
        tipo: tipo,
      );

      // Verifica conexão com a internet e aciona sincronização
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await DatabaseService().syncMoviCarteToFB();
      } else {
        print('Sem conexão com a internet. A sincronização será feita depois.');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Movimentação realizada com sucesso!')),
      );

      Navigator.of(context).pop(true);
      widget.onSave();
    } catch (e) {
      print('Erro ao movimentar saldo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao movimentar saldo. Verifique os valores inseridos.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Carteira'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Saldo Total: ${saldoTotal < 0 ? '- R\$${NumberFormat("#,##0.00", "pt_BR").format(-saldoTotal)}' : 'R\$${NumberFormat("#,##0.00", "pt_BR").format(saldoTotal)}'}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.purplelightMain),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saldo Carteira: ${saldoCarteira < 0 ? '- R\$${NumberFormat("#,##0.00", "pt_BR").format(-saldoCarteira)}' : 'R\$${NumberFormat("#,##0.00", "pt_BR").format(saldoCarteira)}'}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: ToggleButtons(
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _selectedTypes.length; i++) {
                      _selectedTypes[i] = i == index;
                    }
                    tipo = _selectedTypes[0] ? 5 : 6;
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderColor: Colors.grey,
                selectedBorderColor: _selectedTypes[0] ? guardarColor : retirarColor,
                selectedColor: Colors.white,
                fillColor: _selectedTypes[0] ? guardarColor : retirarColor,
                color: Colors.black54,
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 100.0,
                ),
                isSelected: _selectedTypes,
                children: tipos,
              ),
            ),
            TextField(
              controller: _valorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Valor'),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                MoedaTextInputFormatter(),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _confirmarMovimentacao,
          child: _isLoading ? CircularProgressIndicator() : Text('Confirmar'),
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



