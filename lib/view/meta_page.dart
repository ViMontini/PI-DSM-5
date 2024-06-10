import 'dart:async';
import 'dart:developer';
import 'package:despesa_digital/controller/divi_controller.dart';
import 'package:despesa_digital/model/divida.dart';
import 'package:despesa_digital/utils/app_colors.dart';
import 'package:despesa_digital/utils/app_text_styles.dart';
import 'package:despesa_digital/utils/sizes.dart';
import 'package:flutter/material.dart';
import '../controller/gafi_controller.dart';
import '../controller/meta_controller.dart';
import '../database/divida_db.dart';
import '../database/gasto_db.dart';
import '../database/meta_db.dart';
import '../model/gasto_fixo.dart';
import '../model/meta.dart';

class MetaPage extends StatefulWidget {
  final Function(String) onMenuItemSelected;

  const MetaPage({Key? key, required this.onMenuItemSelected}) : super(key: key);

  @override
  State<MetaPage> createState() => _MetaPageState();
}

class _MetaPageState extends State<MetaPage> {
  Future<List<Meta>>? futureMetas;
  Future<List<Divida>>? futureDividas;
  Future<List<GastoFixo>>? futureGastos;
  String _selectedText = 'Metas';

  final MetaController metaController = MetaController();
  final DividaController diviController = DividaController();
  final GastoController contaController = GastoController();

  @override
  void dispose() {
    log('disposed');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    futureMetas = MetaDB().fetchAll();
    futureDividas = DividaDB().fetchAll();
    futureGastos = GastoDB().fetchAll();
  }

  void _refreshData() {
    setState(() {
      futureMetas = MetaDB().fetchAll();
      futureDividas = DividaDB().fetchAll();
      futureGastos = GastoDB().fetchAll();
    });
  }

  void _updateSelectedText(String text) {
    setState(() {
      _selectedText = text;
    });
    widget.onMenuItemSelected(text);
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
                            _selectedText,
                            style: AppTextStyles.mediumText.apply(color: AppColors.white),
                          ),
                        ],
                      ),
                      GestureDetector(
                        child: PopupMenuButton(
                          padding: EdgeInsets.zero,
                          child: const Icon(
                            Icons.more_horiz,
                            color: AppColors.white,
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              height: 24.0,
                              child: const Text("Metas"),
                              onTap: () => _updateSelectedText("Metas"),
                            ),
                            PopupMenuItem(
                              height: 24.0,
                              child: const Text("Dívidas"),
                              onTap: () => _updateSelectedText("Dívidas"),
                            ),
                            PopupMenuItem(
                              height: 24.0,
                              child: const Text("Contas Fixas"),
                              onTap: () => _updateSelectedText("Contas Fixas"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 240.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedText) {
      case "Contas Fixas":
        return FutureBuilder<List<GastoFixo>>(
          future: futureGastos,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<GastoFixo> gastos = snapshot.data!;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: 8.h), // Espaçamento entre o topo e a lista
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final gasto = gastos[index];
                        return Column(
                          children: [
                            contaController.construirGastoListTile(context, gasto, _refreshData),
                            SizedBox(height: 5.0),
                          ],
                        );
                      },
                      childCount: gastos.length,
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Erro ao carregar contas fixas'));
            }
            return Center(child: CircularProgressIndicator());
          },
        );
      case "Dívidas":
        return FutureBuilder<List<Divida>>(
          future: futureDividas,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<Divida> dividas = snapshot.data!;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: 8.h), // Espaçamento entre o topo e a lista
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final divida = dividas[index];
                        return Column(
                          children: [
                            diviController.construirDividaListTile(context, divida, _refreshData),
                            SizedBox(height: 5.0),
                          ],
                        );
                      },
                      childCount: dividas.length,
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Erro ao carregar dívidas'));
            }
            return Center(child: CircularProgressIndicator());
          },
        );
      case "Metas":
      default:
        return FutureBuilder<List<Meta>>(
          future: futureMetas,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<Meta> metas = snapshot.data!;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: 8.h), // Espaçamento entre o topo e a lista
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final meta = metas[index];
                        return Column(
                          children: [
                            metaController.construirMetaListTile(context, meta, _refreshData),
                            SizedBox(height: 5.0),
                          ],
                        );
                      },
                      childCount: metas.length,
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Erro ao carregar metas'));
            }
            return Center(child: CircularProgressIndicator());
          },
        );
    }
  }
}
