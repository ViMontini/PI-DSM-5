import 'dart:async';
import 'package:despesa_digital/utils/sizes.dart';
import 'package:flutter/material.dart';
import '../controller/conta_controller.dart';
import '../controller/divida_controller.dart';
import '../controller/meta_controller.dart';
import '../database/conta_db.dart';
import '../database/divida_db.dart';
import '../database/meta_db.dart';
import '../model/conta.dart';
import '../model/divida.dart';
import '../model/meta.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class FinancaPage extends StatefulWidget {
  final Function(String) onMenuItemSelected;

  const FinancaPage({Key? key, required this.onMenuItemSelected}) : super(key: key);

  @override
  FinancaPageState createState() => FinancaPageState();
}

class FinancaPageState extends State<FinancaPage> {
  Future<List<Meta>>? futureMetas;
  Future<List<Divida>>? futureDividas;
  Future<List<Conta>>? futureContas;
  String _selectedText = 'Metas';

  final StreamController<void> _refreshController = StreamController<void>.broadcast();

  final MetaController metaController = MetaController();
  final DividaController diviController = DividaController();
  final ContaController contaController = ContaController();

  @override
  void dispose() {
    _refreshController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    futureMetas = MetaDB().fetchAll();
    futureDividas = DividaDB().fetchAll();
    futureContas = ContaDB().fetchAll();
  }

  void refreshData() {
    setState(() {
      futureMetas = MetaDB().fetchAll();
      futureDividas = DividaDB().fetchAll();
      futureContas = ContaDB().fetchAll();
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
              height: 120.h,
            ),
          ),
          Positioned(
            left: 250.w,
            right: 250.w,
            top: 60.h,
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
                    mainAxisAlignment: MainAxisAlignment.start,
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
                            Icons.arrow_drop_down,
                            color: AppColors.white,
                            size: 35,
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              height: 40.0, // Altura personalizada do item
                              child: Container(
                                padding: EdgeInsets.zero, // Remove o padding interno
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  "Metas",
                                  style: TextStyle(fontSize: 16), // Tamanho do texto ajustado
                                ),
                              ),
                              onTap: () => _updateSelectedText("Metas"),
                            ),
                            PopupMenuItem(
                              height: 40.0,
                              child: Container(
                                padding: EdgeInsets.zero, // Remove o padding interno
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  "Dívidas",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              onTap: () => _updateSelectedText("Dívidas"),
                            ),
                            PopupMenuItem(
                              height: 40.0,
                              child: Container(
                                padding: EdgeInsets.zero, // Remove o padding interno
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  "Contas Fixas",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
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
            top: 165.h,
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
        return FutureBuilder<List<Conta>>(
          future: futureContas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Erro ao carregar contas fixas'));
            } else if (snapshot.hasData) {
              final List<Conta> contas = snapshot.data!;
              if (contas.isEmpty) {
                return Center(child: Text('Nenhuma conta fixa encontrada'));
              }
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: 8), // Espaçamento entre o topo e a lista
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final conta = contas[index];
                        return Column(
                          children: [
                            contaController.construirGastoListTile(context, conta, refreshData),
                            SizedBox(height: 5.0),
                          ],
                        );
                      },
                      childCount: contas.length,
                    ),
                  ),
                ],
              );
            }
            return Container(); // Retornar um contêiner vazio como último recurso
          },
        );
      case "Dívidas":
        return FutureBuilder<List<Divida>>(
          future: futureDividas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Erro ao carregar dívidas'));
            } else if (snapshot.hasData) {
              final List<Divida> dividas = snapshot.data!;
              if (dividas.isEmpty) {
                return Center(child: Text('Nenhuma dívida encontrada'));
              }
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: 8), // Espaçamento entre o topo e a lista
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final divida = dividas[index];
                        return Column(
                          children: [
                            diviController.construirDividaListTile(context, divida, refreshData),
                            SizedBox(height: 5.0),
                          ],
                        );
                      },
                      childCount: dividas.length,
                    ),
                  ),
                ],
              );
            }
            return Container(); // Retornar um contêiner vazio como último recurso
          },
        );
      case "Metas":
      default:
        return FutureBuilder<List<Meta>>(
          future: futureMetas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Erro ao carregar metas'));
            } else if (snapshot.hasData) {
              final List<Meta> metas = snapshot.data!;
              if (metas.isEmpty) {
                return Center(child: Text('Nenhuma meta encontrada'));
              }
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: 8), // Espaçamento entre o topo e a lista
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final meta = metas[index];
                        return Column(
                          children: [
                            metaController.construirMetaListTile(context, meta, refreshData),
                            SizedBox(height: 5.0),
                          ],
                        );
                      },
                      childCount: metas.length,
                    ),
                  ),
                ],
              );
            }
            return Container(); // Retornar um contêiner vazio como último recurso
          },
        );
    }
  }
}
