import 'dart:async';
import 'package:despesa_digital/utils/sizes.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../controller/movi_controller.dart';
import '../controller/real.dart';
import '../database/movi_db.dart';
import '../model/movimentacao.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'package:intl/intl.dart';

class RelatorioPage extends StatefulWidget {
  const RelatorioPage({super.key});

  @override
  State<RelatorioPage> createState() => _RelatorioPageState();
}

class _RelatorioPageState extends State<RelatorioPage> {
  Future<List<Movimentacao>>? futureMovi;
  final MoviController moviController = MoviController();
  final Real real = Real();

  int? selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  int selectedYearForAnual = DateTime.now().year;

  int touchedIndexMes = -1;
  int touchedIndexAno = -1;
  int touchedIndexReceitasDespesasMes = -1;
  int touchedIndexReceitasDespesasAno = -1;

  late TooltipBehavior _tooltip;

  @override
  void initState() {
    super.initState();
    futureMovi = MovimentacaoDB().fetchAllDesc();
    _tooltip = TooltipBehavior(enable: true);
  }

  // Função genérica para obter movimentações filtradas
  List<Movimentacao> _getMovimentacoesFiltradas({
    required List<Movimentacao> movimentacoes,
    int? mes,
    int? ano,
  }) {
    return movimentacoes.where((mov) {
      DateTime data = DateTime.parse(mov.data);
      bool mesMatch = mes != null ? data.month == mes : true;
      bool anoMatch = ano != null ? data.year == ano : true;
      return mesMatch && anoMatch && mov.estornado == 0;
    }).toList();
  }

  // Função genérica para calcular total de despesas ou receitas
  double _calcularTotal({
    required List<Movimentacao> movimentacoes,
    required List<int> tipos,
  }) {
    return movimentacoes
        .where((mov) => tipos.contains(mov.tipo) && mov.estornado == 0) // Ignorar estornados
        .fold(0.0, (sum, mov) => sum + mov.valor);
  }


  double _calcularSaldoCarteiraOuMeta(
      Iterable<Movimentacao> movimentacoes, {
        required int tipoGuardar,
        required int tipoRetirar,
      }) {
    double guardar = movimentacoes
        .where((mov) => mov.tipo == tipoGuardar)
        .fold(0.0, (sum, mov) => sum + mov.valor);

    double retirar = movimentacoes
        .where((mov) => mov.tipo == tipoRetirar)
        .fold(0.0, (sum, mov) => sum + mov.valor);

    return guardar - retirar;
  }

  // Função para obter totais por categoria, desconsiderando tipos 2, 5, 6 e 7
  Map<String, double> _getCategoriaTotais(List<Movimentacao> movimentacoes) {
    Map<String, double> categorias = {};

    // Filtrar movimentações válidas (sem estorno)
    var movimentacoesValidas = movimentacoes.where((mov) => mov.estornado == 0);

    double metaTotal = _calcularSaldoCarteiraOuMeta(
      movimentacoesValidas,
      tipoGuardar: 2, // Guardar na Meta
      tipoRetirar: 7, // Retirar da Meta
    );

    double carteiraTotal = _calcularSaldoCarteiraOuMeta(
      movimentacoesValidas,
      tipoGuardar: 5, // Guardar na Carteira
      tipoRetirar: 6, // Retirar da Carteira
    );

    // Adicionar "Meta" e "Carteira" ao mapa de categorias
    if (metaTotal != 0) {
      categorias['Meta'] = metaTotal;
    }
    if (carteiraTotal != 0) {
      categorias['Carteira'] = carteiraTotal;
    }

    // Processar outras categorias, excluindo os tipos de "Guardar" e "Retirar"
    for (var mov in movimentacoesValidas) {
      if (![2, 5, 6, 7].contains(mov.tipo)) {
        if (categorias.containsKey(mov.categoria)) {
          categorias[mov.categoria] = categorias[mov.categoria]! + mov.valor;
        } else {
          categorias[mov.categoria] = mov.valor;
        }
      }
    }

    return categorias;
  }

  // Função para obter totais de receitas e despesas
  Map<String, double> _getReceitasDespesasTotais(List<Movimentacao> movimentacoes) {
    double totalDespesas = _calcularTotal(
      movimentacoes: movimentacoes,
      tipos: [0, 3, 4], // Considera despesas
    );

    double totalReceitas = _calcularTotal(
      movimentacoes: movimentacoes,
      tipos: [1], // Considera receitas
    );

    return {
      'Receitas': totalReceitas,
      'Despesas': totalDespesas,
    };
  }


  // Função para criar o gráfico de pizza para categorias com as alterações solicitadas
  Widget _buildPieChart({
    required Map<String, double> dataMap,
    required int touchedIndex,
    required Function(int) onTouch,
    required String emptyMessage,
  }) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                  onTouch(pieTouchResponse?.touchedSection?.touchedSectionIndex ?? -1);
                },
              ),
              sections: dataMap.isNotEmpty
                  ? dataMap.entries.map((entry) {
                final index = dataMap.keys.toList().indexOf(entry.key);
                final isTouched = index == touchedIndex;
                final total = dataMap.values.fold(0.0, (a, b) => a + b);
                final percentage = '${((entry.value / total) * 100).toStringAsFixed(1)}%';

                return PieChartSectionData(
                  color: Colors.primaries[index % Colors.primaries.length],
                  value: entry.value,
                  title: isTouched ? percentage : '',
                  radius: isTouched ? 60 : 50,
                  titleStyle: TextStyle(
                    fontSize: isTouched ? 16.0 : 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList()
                  : [
                // Quando não houver dados, exibir uma fatia única cinza
                PieChartSectionData(
                  color: Colors.grey[300],
                  value: 1,
                  title: '',
                  radius: 50,
                ),
              ],
            ),
          ),
          // Exibir a mensagem ou o valor no centro do gráfico
          Positioned.fill(
            child: Center(
              child: dataMap.isNotEmpty
                  ? touchedIndex != -1
                  ? Text(
                    () {
                  String key = dataMap.keys.toList()[touchedIndex];
                  double value = dataMap[key]!;
                  return '${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value)}';
                }(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.primaries[touchedIndex % Colors.primaries.length],
                ),
              )
                  : SizedBox.shrink()
                  : Text(
                emptyMessage,
                style: AppTextStyles.mediumText.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Função para criar o gráfico de pizza de Receitas e Despesas
  Widget _buildPieChartReceitasDespesas({
    required Map<String, double> dataMap,
    required int touchedIndex,
    required Function(int) onTouch,
    required String emptyMessage,
  }) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                  onTouch(pieTouchResponse?.touchedSection?.touchedSectionIndex ?? -1);
                },
              ),
              sections: dataMap.values.any((value) => value > 0)
                  ? dataMap.entries.map((entry) {
                final index = dataMap.keys.toList().indexOf(entry.key);
                final isTouched = index == touchedIndex;

                // Definir cores específicas para Receitas e Despesas
                final color = entry.key == 'Receitas' ? Colors.green : Colors.red;

                final total = dataMap.values.fold(0.0, (a, b) => a + b);
                final percentage = '${((entry.value / total) * 100).toStringAsFixed(1)}%';

                return PieChartSectionData(
                  color: color,
                  value: entry.value,
                  title: isTouched ? percentage : '',
                  radius: isTouched ? 60 : 50,
                  titleStyle: TextStyle(
                    fontSize: isTouched ? 16.0 : 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList()
                  : [
                // Quando não houver dados, exibir uma fatia única cinza
                PieChartSectionData(
                  color: Colors.grey[300],
                  value: 1,
                  title: '',
                  radius: 50,
                ),
              ],
            ),
          ),
          // Exibir a mensagem ou o valor no centro do gráfico
          Positioned.fill(
            child: Center(
              child: dataMap.values.any((value) => value > 0)
                  ? touchedIndex != -1
                  ? Text(
                    () {
                  String key = dataMap.keys.toList()[touchedIndex];
                  double value = dataMap[key]!;
                  String prefix = key == 'Receitas' ? '+' : '-';
                  Color color = key == 'Receitas' ? Colors.green : Colors.red;
                  return '$prefix${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value)}';
                }(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: dataMap.keys.toList()[touchedIndex] == 'Receitas' ? Colors.green : Colors.red,
                ),
              )
                  : SizedBox.shrink()
                  : Text(
                emptyMessage,
                style: AppTextStyles.mediumText.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Função para criar o gráfico de barras
  Widget _buildBarChart({
    required List<_ChartData> despesasData,
    required List<_ChartData> receitasData,
    required String emptyMessage,
  }) {
    final double maxValue = [
      ...despesasData.map((data) => data.y),
      ...receitasData.map((data) => data.y),
    ].fold(0.0, (prev, element) => element > prev ? element : prev);

    return AspectRatio(
      aspectRatio: 1.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: maxValue > 0 ? maxValue + 1000 : 1,
              interval: maxValue > 0 ? (maxValue + 1000) / 2 : 1,
            ),
            tooltipBehavior: _tooltip,
            series: <CartesianSeries<_ChartData, String>>[
              BarSeries<_ChartData, String>(
                dataSource: despesasData,
                xValueMapper: (_ChartData data, _) => data.x,
                yValueMapper: (_ChartData data, _) => data.y,
                name: 'Despesas',
                color: Colors.red,
                borderRadius: BorderRadius.circular(0),
              ),
              BarSeries<_ChartData, String>(
                dataSource: receitasData,
                xValueMapper: (_ChartData data, _) => data.x,
                yValueMapper: (_ChartData data, _) => data.y,
                name: 'Receitas',
                color: Colors.green,
                borderRadius: BorderRadius.circular(0),
              ),
            ],
          ),
          if (maxValue == 0)
            Container(
              alignment: Alignment.center,
              child: Text(
                emptyMessage,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  // Widget para exibir o relatório (mensal ou anual)
  Widget _buildRelatorio({
    required List<Movimentacao> movimentacoes,
    required int? mes,
    required int ano,
    required int touchedIndex,
    required Function(int) onTouch,
    required String tituloCategorias,
    required String tituloComparacao,
    required String emptyMessageCategorias,
    required String emptyMessageComparacao,
    required int touchedIndexReceitasDespesas,
    required Function(int) onTouchReceitasDespesas,
    required String emptyMessageReceitasDespesas,
  }) {
    final movimentacoesFiltradas = _getMovimentacoesFiltradas(
      movimentacoes: movimentacoes,
      mes: mes,
      ano: ano,
    );

    final categoriasTotais = _getCategoriaTotais(movimentacoesFiltradas);

    final totalDespesas = _calcularTotal(
      movimentacoes: movimentacoesFiltradas,
      tipos: [0, 3, 4], // Considera os tipos 0, 3 e 4 como despesas
    );

    final totalReceitas = _calcularTotal(
      movimentacoes: movimentacoesFiltradas,
      tipos: [1], // Considera o tipo 1 como receitas
    );

    final despesasData = [
      _ChartData('Despesas', totalDespesas),
    ];
    final receitasData = [
      _ChartData('Receitas', totalReceitas),
    ];

    return Column(
      children: [
        // Gráfico de Categorias
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                tituloCategorias,
                style: AppTextStyles.mediumText.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              _buildPieChart(
                dataMap: categoriasTotais,
                touchedIndex: touchedIndex,
                onTouch: onTouch,
                emptyMessage: emptyMessageCategorias,
              ),
              // Verificar se há dados antes de exibir a legenda
              if (categoriasTotais.isNotEmpty)
              // Lista de Categorias
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  alignment: WrapAlignment.center,
                  children: categoriasTotais.entries.map((entry) {
                    final index = categoriasTotais.keys.toList().indexOf(entry.key);
                    final isTouched = touchedIndex == -1 || touchedIndex == index;

                    return isTouched
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: Colors.primaries[index % Colors.primaries.length],
                        ),
                        const SizedBox(width: 4),
                        Text(entry.key),
                      ],
                    )
                        : Container();
                  }).toList(),
                ),
            ],
          ),
        ),

        // Novo Gráfico de Receitas vs Despesas (Gráfico de Pizza)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Proporção de Receitas e Despesas',
                style: AppTextStyles.mediumText.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              _buildPieChartReceitasDespesas(
                dataMap: _getReceitasDespesasTotais(movimentacoesFiltradas),
                touchedIndex: touchedIndexReceitasDespesas,
                onTouch: onTouchReceitasDespesas,
                emptyMessage: emptyMessageReceitasDespesas,
              ),
              // Verificar se há dados antes de exibir a legenda
              if (_getReceitasDespesasTotais(movimentacoesFiltradas).values.any((value) => value > 0))
              // Legenda
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  alignment: WrapAlignment.center,
                  children: ['Receitas', 'Despesas'].map((entry) {
                    final index = ['Receitas', 'Despesas'].indexOf(entry);
                    final isTouched = touchedIndexReceitasDespesas == -1 || touchedIndexReceitasDespesas == index;

                    // Usar cores específicas
                    final color = entry == 'Receitas' ? Colors.green : Colors.red;

                    return isTouched
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          color: color,
                        ),
                        const SizedBox(width: 4),
                        Text(entry),
                      ],
                    )
                        : Container();
                  }).toList(),
                ),
            ],
          ),
        ),

        // Gráfico Comparativo de Receitas vs Despesas
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                tituloComparacao,
                style: AppTextStyles.mediumText.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              _buildBarChart(
                despesasData: despesasData,
                receitasData: receitasData,
                emptyMessage: emptyMessageComparacao,
              ),
              // Descrições
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Total de Despesas:',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      Text(
                        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(totalDespesas),
                        style: const TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Total de Receitas:',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                      Text(
                        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(totalReceitas),
                        style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget para o relatório anual com gráfico mensal
  Widget _buildRelatorioAnual({
    required List<Movimentacao> movimentacoes,
    required int ano,
  }) {
    return Column(
      children: [
        // Gráfico Comparativo Mensal de Receitas vs Despesas
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Comparação de Receitas vs Despesas Anual',
                style: AppTextStyles.mediumText.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              AspectRatio(
                aspectRatio: 1.8,
                child: BarChart(
                  BarChartData(
                    barGroups: List.generate(12, (index) {
                      double receitasMes = _calcularTotal(
                        movimentacoes: _getMovimentacoesFiltradas(
                          movimentacoes: movimentacoes,
                          mes: index + 1,
                          ano: ano,
                        ),
                        tipos: [1], // Tipo 1 para receitas
                      );
                      double despesasMes = _calcularTotal(
                        movimentacoes: _getMovimentacoesFiltradas(
                          movimentacoes: movimentacoes,
                          mes: index + 1,
                          ano: ano,
                        ),
                        tipos: [0, 3, 4], // Tipos 0, 3 e 4 para despesas
                      );
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(toY: despesasMes, color: Colors.red, width: 10),
                          BarChartRodData(toY: receitasMes, color: Colors.green, width: 10),
                        ],
                      );
                    }),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          getTitlesWidget: (value, meta) {
                            final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                months[value.toInt()],
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}K' : value.toStringAsFixed(0),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String tipo = rodIndex == 0 ? 'Despesas' : 'Receitas';
                          String valor = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(rod.toY);
                          Color valorColor = rodIndex == 0 ? Colors.red : Colors.green;
                          return BarTooltipItem(
                            '$tipo\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: valor,
                                style: TextStyle(
                                  color: valorColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Método build principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo gradiente
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: AppColors.purpleGradient,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.elliptical(500, 30),
                  bottomRight: Radius.elliptical(500, 30),
                ),
              ),
              height: 120.h,
            ),
          ),
          // Título original
          Positioned(
            left: 250.w,
            right: 250.w,
            top: 60.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 150.w, vertical: 32.h),
              decoration: const BoxDecoration(
                color: AppColors.purpledarkOne,
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Relatórios',
                    style: AppTextStyles.mediumText.apply(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
          // Conteúdo principal
          Positioned(
            top: 160.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Mensal'),
                      Tab(text: 'Anual'),
                    ],
                    labelColor: AppColors.purpledarkOne,
                    unselectedLabelColor: Colors.black,
                    indicatorColor: AppColors.purpledarkOne,
                  ),
                  // Conteúdo das abas
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Relatório Mensal
                        SingleChildScrollView(
                          child: FutureBuilder<List<Movimentacao>>(
                            future: futureMovi,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                if (kDebugMode) {
                                  print(snapshot.error);
                                }
                                return const Center(child: Text('Erro ao carregar movimentações'));
                              } else if (snapshot.hasData) {
                                final movimentacoes = snapshot.data!;

                                return Column(
                                  children: [
                                    // Filtros de Mês e Ano
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        DropdownButton<int>(
                                          value: selectedMonth,
                                          underline: Container(),
                                          items: List.generate(12, (index) {
                                            return DropdownMenuItem(
                                              value: index + 1,
                                              child: Text(
                                                DateFormat.MMMM('pt_BR').format(DateTime(0, index + 1)),
                                                style: const TextStyle(fontSize: 16),
                                              ),
                                            );
                                          }),
                                          onChanged: (newMonth) {
                                            setState(() {
                                              selectedMonth = newMonth!;
                                            });
                                          },
                                        ),
                                        const SizedBox(width: 10),
                                        DropdownButton<int>(
                                          value: selectedYear,
                                          underline: Container(),
                                          items: List.generate(10, (index) {
                                            int year = DateTime.now().year - index;
                                            return DropdownMenuItem(
                                              value: year,
                                              child: Text(
                                                '$year',
                                                style: const TextStyle(fontSize: 16),
                                              ),
                                            );
                                          }),
                                          onChanged: (newYear) {
                                            setState(() {
                                              selectedYear = newYear!;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    // Conteúdo do Relatório Mensal
                                    _buildRelatorio(
                                      movimentacoes: movimentacoes,
                                      mes: selectedMonth,
                                      ano: selectedYear,
                                      touchedIndex: touchedIndexMes,
                                      onTouch: (index) {
                                        setState(() {
                                          touchedIndexMes = index;
                                        });
                                      },
                                      tituloCategorias: 'Movimentações por Categoria Mensal',
                                      tituloComparacao: 'Comparação de Receitas vs Despesas Mensal',
                                      emptyMessageCategorias: 'Sem dados para este mês',
                                      emptyMessageComparacao: 'Sem dados para este mês',
                                      touchedIndexReceitasDespesas: touchedIndexReceitasDespesasMes,
                                      onTouchReceitasDespesas: (index) {
                                        setState(() {
                                          touchedIndexReceitasDespesasMes = index;
                                        });
                                      },
                                      emptyMessageReceitasDespesas: 'Sem dados para este mês',
                                    ),
                                  ],
                                );
                              }
                              return Container();
                            },
                          ),
                        ),
                        // Relatório Anual
                        SingleChildScrollView(
                          child: FutureBuilder<List<Movimentacao>>(
                            future: futureMovi,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                if (kDebugMode) {
                                  print(snapshot.error);
                                }
                                return const Center(child: Text('Erro ao carregar movimentações'));
                              } else if (snapshot.hasData) {
                                final movimentacoes = snapshot.data!;

                                return Column(
                                  children: [
                                    // Filtro de Ano
                                    Center(
                                      child: DropdownButton<int>(
                                        value: selectedYearForAnual,
                                        underline: Container(),
                                        items: List.generate(10, (index) {
                                          int year = DateTime.now().year - index;
                                          return DropdownMenuItem(
                                            value: year,
                                            child: Text(
                                              '$year',
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          );
                                        }),
                                        onChanged: (newYear) {
                                          setState(() {
                                            selectedYearForAnual = newYear!;
                                          });
                                        },
                                      ),
                                    ),
                                    // Conteúdo do Relatório Anual
                                    _buildRelatorio(
                                      movimentacoes: movimentacoes,
                                      mes: null,
                                      ano: selectedYearForAnual,
                                      touchedIndex: touchedIndexAno,
                                      onTouch: (index) {
                                        setState(() {
                                          touchedIndexAno = index;
                                        });
                                      },
                                      tituloCategorias: 'Movimentações por Categoria Anual',
                                      tituloComparacao: 'Comparação de Receitas vs Despesas Anual',
                                      emptyMessageCategorias: 'Sem dados para este ano',
                                      emptyMessageComparacao: 'Sem dados para este ano',
                                      touchedIndexReceitasDespesas: touchedIndexReceitasDespesasAno,
                                      onTouchReceitasDespesas: (index) {
                                        setState(() {
                                          touchedIndexReceitasDespesasAno = index;
                                        });
                                      },
                                      emptyMessageReceitasDespesas: 'Sem dados para este ano',
                                    ),
                                    // Gráfico Comparativo Mensal no Relatório Anual
                                    _buildRelatorioAnual(
                                      movimentacoes: movimentacoes,
                                      ano: selectedYearForAnual,
                                    ),
                                  ],
                                );
                              }
                              return Container();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Classe para dados do gráfico
class _ChartData {
  _ChartData(this.x, this.y);
  final String x;
  final double y;
}