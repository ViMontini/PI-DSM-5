import 'dart:async';
import 'dart:developer';
import 'package:despesa_digital/utils/sizes.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../controller/movi_controller.dart';
import '../controller/real.dart';
import '../database/movi_db.dart';
import '../database/saldo_db.dart';
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

  @override
  void dispose() {
    log('disposed');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    log('init');
    futureMovi = MovimentacaoDB().fetchAllDesc();
  }

  Future<double> _fetchSaldo() async {
    final saldoDB = SaldoDB();
    final saldos = await saldoDB.fetchAll();
    if (saldos.isNotEmpty) {
      return saldos.first.saldo;
    } else {
      return 0.0;
    }
  }

  void _refreshMovis() {
    setState(() {
      futureMovi = MovimentacaoDB().fetchAllDesc();
    });
  }

  List<Movimentacao> _getMovimentacoesDoMesAtual(List<Movimentacao> movimentacoes) {
    DateTime now = DateTime.now();
    return movimentacoes.where((mov) {
      DateTime data = DateTime.parse(mov.data);
      return data.month == now.month && data.year == now.year;
    }).toList();
  }

  List<Movimentacao> _getMovimentacoesDosUltimosTresMeses(List<Movimentacao> movimentacoes) {
    DateTime now = DateTime.now();
    return movimentacoes.where((mov) {
      DateTime data = DateTime.parse(mov.data);
      return data.isAfter(now.subtract(Duration(days: 90))) && data.isBefore(now);
    }).toList();
  }

  Map<String, double> _getCategoriaTotais(List<Movimentacao> movimentacoes) {
    Map<String, double> categorias = {};
    for (var mov in movimentacoes) {
      if (categorias.containsKey(mov.categoria)) {
        categorias[mov.categoria] = categorias[mov.categoria]! + mov.valor;
      } else {
        categorias[mov.categoria] = mov.valor;
      }
    }
    return categorias;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
              height: 150.h,
            ),
          ),
          Positioned(
            left: 250.w,
            right: 250.w,
            top: 80.h,
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
          Positioned(
            top: 180.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: FutureBuilder<List<Movimentacao>>(
              future: futureMovi,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(child: Text('Erro ao carregar movimentações'));
                } else if (snapshot.hasData) {
                  final List<Movimentacao> movimentacoes = snapshot.data!;
                  final List<Movimentacao> movimentacoesDoMesAtual = _getMovimentacoesDoMesAtual(movimentacoes);
                  final List<Movimentacao> movimentacoesDosUltimosTresMeses = _getMovimentacoesDosUltimosTresMeses(movimentacoes);

                  final Map<String, double> categoriasTotais = _getCategoriaTotais(movimentacoesDoMesAtual);

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Título e Gráfico de barras (movimentações que tiraram e que entraram saldo no mês atual)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Diferença de Movimentações (Mês Atual)',
                                style: AppTextStyles.mediumText,
                              ),
                              SizedBox(height: 8.0),
                              AspectRatio(
                                aspectRatio: 1.7,
                                child: BarChart(
                                  BarChartData(
                                    barGroups: [
                                      BarChartGroupData(
                                        x: 0,
                                        barRods: [
                                          BarChartRodData(
                                            toY: movimentacoesDoMesAtual
                                                .where((mov) => mov.tipo == 0)
                                                .fold(0.0, (sum, mov) => sum + mov.valor),
                                            color: Colors.red,
                                          ),
                                        ],
                                      ),
                                      BarChartGroupData(
                                        x: 1,
                                        barRods: [
                                          BarChartRodData(
                                            toY: movimentacoesDoMesAtual
                                                .where((mov) => mov.tipo == 1)
                                                .fold(0.0, (sum, mov) => sum + mov.valor),
                                            color: Colors.green,
                                          ),
                                        ],
                                      ),
                                    ],
                                    titlesData: FlTitlesData(
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            switch (value.toInt()) {
                                              case 0:
                                                return Text('Saídas');
                                              case 1:
                                                return Text('Entradas');
                                              default:
                                                return Text('');
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    barTouchData: BarTouchData(
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          String tipo = group.x == 0 ? 'Saídas' : 'Entradas';
                                          String valor = real.formatValor(rod.toY);
                                          Color valorColor = group.x == 0 ? Colors.red : Colors.green;
                                          return BarTooltipItem(
                                            '$tipo\n',
                                            TextStyle(
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
                        // Título e Gráfico de pizza (movimentações do mês atual divididas em categorias)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Movimentações por Categoria (Mês Atual)',
                                style: AppTextStyles.mediumText,
                              ),
                              SizedBox(height: 8.0),
                              AspectRatio(
                                aspectRatio: 1.3,
                                child: PieChart(
                                  PieChartData(
                                    sections: categoriasTotais.entries.map((entry) {
                                      return PieChartSectionData(
                                        color: Colors.primaries[categoriasTotais.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                                        value: entry.value,
                                        title: '',
                                        radius: 50,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              // Legenda
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: categoriasTotais.entries.map((entry) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        color: Colors.primaries[categoriasTotais.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                                      ),
                                      SizedBox(width: 4),
                                      Text(entry.key),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        // Título e Gráfico de barras (movimentações que tiraram e que entraram saldo nos últimos 3 meses)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Diferença de Movimentações (Últimos 3 Meses)',
                                style: AppTextStyles.mediumText,
                              ),
                              SizedBox(height: 8.0),
                              AspectRatio(
                                aspectRatio: 1.7,
                                child: BarChart(
                                  BarChartData(
                                    barGroups: [
                                      BarChartGroupData(
                                        x: 0,
                                        barRods: [
                                          BarChartRodData(
                                            toY: movimentacoesDosUltimosTresMeses
                                                .where((mov) => mov.tipo == 0)
                                                .fold(0.0, (sum, mov) => sum + mov.valor),
                                            color: Colors.red,
                                          ),
                                        ],
                                      ),
                                      BarChartGroupData(
                                        x: 1,
                                        barRods: [
                                          BarChartRodData(
                                            toY: movimentacoesDosUltimosTresMeses
                                                .where((mov) => mov.tipo == 1)
                                                .fold(0.0, (sum, mov) => sum + mov.valor),
                                            color: Colors.green,
                                          ),
                                        ],
                                      ),
                                    ],
                                    titlesData: FlTitlesData(
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            switch (value.toInt()) {
                                              case 0:
                                                return Text('Saídas');
                                              case 1:
                                                return Text('Entradas');
                                              default:
                                                return Text('');
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    barTouchData: BarTouchData(
                                      touchTooltipData: BarTouchTooltipData(
                                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                          String tipo = group.x == 0 ? 'Saídas' : 'Entradas';
                                          String valor = real.formatValor(rod.toY);
                                          Color valorColor = group.x == 0 ? Colors.red : Colors.green;
                                          return BarTooltipItem(
                                            '$tipo\n',
                                            TextStyle(
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
                    ),
                  );
                }
                return Container(); // Retornar um contêiner vazio como último recurso
              },
            ),
          ),
        ],
      ),
    );
  }
}
