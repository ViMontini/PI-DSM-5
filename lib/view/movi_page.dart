import 'dart:async';
import 'dart:developer';
import 'package:despesa_digital/utils/app_colors.dart';
import 'package:despesa_digital/utils/app_text_styles.dart';
import 'package:despesa_digital/utils/sizes.dart';
import 'package:flutter/material.dart';
import 'package:despesa_digital/database/saldo_db.dart';
import 'package:despesa_digital/controller/movi_controller.dart';
import 'package:despesa_digital/database/movimentacao_db.dart';
import 'package:despesa_digital/model/movimentacao.dart';

class MoviPage extends StatefulWidget {
  const MoviPage({Key? key}) : super(key: key);

  @override
  State<MoviPage> createState() => _MoviPageState();
}

class _MoviPageState extends State<MoviPage> {
  Future<List<Movimentacao>>? futureMovi;
  final MoviController moviController = MoviController();
  String _order = 'desc';
  String _tipoMovimentacao = 'Todos';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

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
    return saldos.isNotEmpty ? saldos.first.saldo : 0.0;
  }

  void _refreshMovis() {
    setState(() {
      futureMovi = MovimentacaoDB().fetchAllDesc();
    });
  }

  Widget _buildDateSelector(BuildContext context,
      {required String label,
        required DateTime? selectedDate,
        required Function(DateTime?) onDateSelected}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            onDateSelected(picked);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              selectedDate != null
                  ? selectedDate.toLocal().toString().split(' ')[0]
                  : 'Selecionar',
            ),
          ),
        ),
      ],
    );
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
            left: 50.w,
            right: 50.w,
            top: 80.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 32.h),
              decoration: const BoxDecoration(
                color: AppColors.purpledarkOne,
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Movimentações',
                    style: AppTextStyles.mediumText.apply(color: AppColors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: AppColors.white, size: 35),
                    onPressed: () {
                      moviController.openFilterModal(context, (DateTime startDate, DateTime endDate) {
                        // Aqui você pode usar startDate e endDate
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 195.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: FutureBuilder<List<Movimentacao>>(
              future: futureMovi,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<Movimentacao> movis = snapshot.data!;
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: SizedBox(height: 8.h)),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final movi = movis[index];
                            return moviController.construirMoviListTile(context, movi, _refreshMovis);
                          },
                          childCount: movis.length,
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  log(snapshot.error.toString());
                  return Center(child: Text('Erro ao carregar movimentações'));
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
