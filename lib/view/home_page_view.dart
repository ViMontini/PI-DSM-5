import 'dart:developer';
import 'package:despesa_digital/utils/app_colors.dart';
import 'package:despesa_digital/view/gasto_fixo.dart';
import 'package:despesa_digital/view/home_page.dart';
import 'package:despesa_digital/view/meta_page.dart';
import 'package:despesa_digital/view/movi_page.dart';
import 'package:despesa_digital/view/movimentacoes.dart';
import 'package:despesa_digital/widgets/custom_bottom_app_bar.dart';
import 'package:flutter/material.dart';
import '../controller/divi_controller.dart';
import '../controller/gafi_controller.dart';
import '../controller/meta_controller.dart';
import '../controller/movi_controller.dart';
import '../database/gasto_db.dart';
import '../database/meta_db.dart';
import '../database/movimentacao_db.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({Key? key}) : super(key: key);

  @override
  _HomePageViewState createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  final pageController = PageController();
  late String _selectedPage = 'home'; // Seleção atual da página
  String _metaPageSelectedText = 'Metas'; // Estado de texto selecionado para MetaPage

  DateTime _selectedDay = new DateTime.now();

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      log(pageController.page.toString());
    });
  }

  // Método para definir a ação do botão flutuante
  void _onFloatingActionButtonPressed() {
    switch (_selectedPage) {
      case 'home':
      // Código para Home Page
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AdicionarMoviPage(selectedDay: _selectedDay);
          },
        ).then((value) {});
        break;
      case 'finanças':
      // Código para Finanças Page
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AdicionarGastoPage();
          },
        ).then((value) {});
        break;
      case 'relatorio':
      // Código para Relatório Page
        switch (_metaPageSelectedText) {
          case 'Metas':
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AdicionarMetaPage();
              },
            ).then((value) {});
            break;
          case 'Contas Fixas':
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AdicionarGastoPage();
              },
            ).then((value) {});
            break;
          case 'Dívidas':
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AdicionarDividaPage();
              },
            ).then((value) {});
            break;
        }
        break;
      case 'user':
      // Código para User Page
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AdicionarDividaPage();
          },
        ).then((value) {});
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: [
          HomePage(),
          Movimentacoes(),
          MetaPage(onMenuItemSelected: (text) {
            setState(() {
              _metaPageSelectedText = text;
            });
          }),
          MoviPage(),
        ],
      ),
      floatingActionButton: _selectedPage != 'home'
          ? FloatingActionButton(
        backgroundColor: AppColors.purpledarkTwo,
        onPressed: _onFloatingActionButtonPressed, // Chama o método de acordo com a seleção atual
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomAppBar(
        selectedItemColor: AppColors.purpledarkOne,
        children: [
          CustomBottomAppBarItem(
              label: 'home',
              primaryIcon: Icons.home,
              secondaryIcon: Icons.home_outlined,
              onPressed: () {
                pageController.jumpToPage(0);
                setState(() {
                  _selectedPage = 'home';
                });
              }),
          CustomBottomAppBarItem(
              label: 'finanças',
              primaryIcon: Icons.paid,
              secondaryIcon: Icons.paid_outlined,
              onPressed: () {
                pageController.jumpToPage(1);
                setState(() {
                  _selectedPage = 'finanças';
                });
              }),
          CustomBottomAppBarItem(
              label: 'relatorio',
              primaryIcon: Icons.analytics,
              secondaryIcon: Icons.analytics_outlined,
              onPressed: () {
                pageController.jumpToPage(2);
                setState(() {
                  _selectedPage = 'relatorio';
                });
              }),
          CustomBottomAppBarItem(
              label: 'user',
              primaryIcon: Icons.person,
              secondaryIcon: Icons.person_outlined,
              onPressed: () {
                pageController.jumpToPage(3);
                setState(() {
                  _selectedPage = 'user';
                });
              }),
        ],
      ),
    );
  }
}
