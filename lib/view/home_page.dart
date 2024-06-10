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

import '../model/movimentacao.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Movimentacao>>? futureMovi;
  final MoviController moviController = MoviController();

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
              height: 200.h,
            ),
          ),
          Positioned(
            left: 24.0,
            right: 24.0,
            top: 60.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Afternoon,',
                      style: AppTextStyles.smallText.apply(color: AppColors.white),
                    ),
                    Text(
                      'Leonardo',
                      style: AppTextStyles.smallText.apply(color: AppColors.white),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 8.w,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    color: AppColors.white.withOpacity(0.06),
                  ),
                  child: Stack(
                    alignment: const AlignmentDirectional(0.5, -0.5),
                    children: [
                      const Icon(
                        Icons.notifications_none_outlined,
                        color: AppColors.white,
                      ),
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Positioned(
            left: 250.w,
            right: 250.w,
            top: 135.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 150.w,
                vertical: 32.h,
              ),
              decoration: const BoxDecoration(
                color: AppColors.purpledarkOne,
                borderRadius: BorderRadius.all(
                  Radius.circular(16.0),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saldo Total',
                            style: AppTextStyles.smallText.apply(color: AppColors.white),
                          ),
                          FutureBuilder<double>(
                            future: _fetchSaldo(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text(
                                  '\$ ...',
                                  style: AppTextStyles.smallText.apply(color: AppColors.white),
                                );
                              } else {
                                return Text(
                                  '\$ ${snapshot.data?.toStringAsFixed(2) ?? "0.00"}',
                                  style: AppTextStyles.smallText.apply(color: AppColors.white),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 270.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ultimas Movimentações',
                        style: AppTextStyles.smallText,
                      ),
                      Text(
                        'Veja tudo',
                        style: AppTextStyles.smallText,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Movimentacao>>(
                    future: futureMovi,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final List<Movimentacao> movis = snapshot.data!;
                        if (movis.isEmpty) {
                          return Center(child: Text('Nenhuma movimentação encontrada'));
                        }
                        return ListView.builder(
                          itemCount: movis.length < 6 ? movis.length : 6,
                          itemBuilder: (context, index) {
                            final movi = movis[index];
                            return moviController.construirMoviHomePage(context, movi);
                          },
                        );
                      } else if (snapshot.hasError) {
                        print(snapshot.error);
                        return Center(child: Text('Erro ao carregar movimentações'));
                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
