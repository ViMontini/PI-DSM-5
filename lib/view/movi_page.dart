import 'dart:async';
import 'dart:developer';
import 'package:despesa_digital/utils/sizes.dart';
import 'package:flutter/material.dart';
import '../controller/movi_controller.dart';
import '../database/movi_db.dart';
import '../database/saldo_db.dart';
import '../model/movimentacao.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class MoviPage extends StatefulWidget {
  final MoviController moviController;

  const MoviPage({Key? key, required this.moviController}) : super(key: key);

  @override
  State<MoviPage> createState() => _MoviPageState();
}

class _MoviPageState extends State<MoviPage> {
  Future<List<Movimentacao>>? futureMovi;
  bool _isVisible = false;

  @override
  void dispose() {
    log('disposed');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    log('init');
    widget.moviController.refreshMovis = _refreshMovis;
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

  void _applyFilters(DateTime startDate, DateTime endDate, String orderBy) {
    setState(() {
      futureMovi = widget.moviController.fetchFilteredMovis(startDate, endDate, orderBy);
    });
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
                    'Movimentações',
                    style: AppTextStyles.mediumText.apply(color: AppColors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: AppColors.white, size: 35),
                    onPressed: () {
                      widget.moviController.openFilterModal(context, (DateTime startDate, DateTime endDate, String orderBy) {
                        _applyFilters(startDate, endDate, orderBy);
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  log(snapshot.error.toString());
                  return Center(child: Text('Erro ao carregar movimentações'));
                } else if (snapshot.hasData) {
                  final List<Movimentacao> movis = snapshot.data!;
                  if (movis.isEmpty) {
                    return Center(child: Text('Nenhuma movimentação encontrada'));
                  }
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: SizedBox(height: 8.h)),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final movi = movis[index];
                            return widget.moviController.construirMoviListTile(context, movi, _refreshMovis);
                          },
                          childCount: movis.length,
                        ),
                      ),
                    ],
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
