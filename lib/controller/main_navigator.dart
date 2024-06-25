import 'package:despesa_digital/view/user_page.dart';
import 'package:flutter/material.dart';
import '../view/financa_page.dart';
import '../view/home_page.dart';
import '../view/movi_page.dart';
import '../view/relatorio_page.dart';
import '../widget/custom_bottom_app_bar.dart';
import '../controller/meta_controller.dart';
import '../controller/movi_controller.dart';
import '../controller/divida_controller.dart';
import '../controller/conta_controller.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  String _metaPageSelectedText = 'Metas';
  final GlobalKey<FinancaPageState> _financaPageKey = GlobalKey<FinancaPageState>();
  final MoviController _moviController = MoviController();

  @override
  void initState() {
    super.initState();
    _moviController.refreshMovis = () {
      setState(() {});
    };
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onBottomNavTapped(int index) {
    if (index < 5) {
      _pageController.jumpToPage(index);
    }
  }

  void _showMoviOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Adicionar Movimentação'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AdicionarMoviPage(
                      onSave: () {
                        _moviController.refreshMovis!();
                        _financaPageKey.currentState?.refreshData();
                      },
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.savings),
              title: Text('Guardar saldo'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return GuardarSaldo(
                      onSave: () {
                        _moviController.refreshMovis!();
                        _financaPageKey.currentState?.refreshData();
                      },
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Pagar Conta'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PagarConta(
                      onSave: () {
                        _moviController.refreshMovis!();
                        _financaPageKey.currentState?.refreshData();
                      },
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.money_off),
              title: Text('Pagar Dívida'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PagarDivida(
                      onSave: () {
                        _moviController.refreshMovis!();
                        _financaPageKey.currentState?.refreshData();
                      },
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _onFloatingActionButtonPressed() {
    if (_currentIndex == 1) {
      _showMoviOptions(context);
    } else if (_currentIndex == 2) {
      switch (_metaPageSelectedText) {
        case 'Metas':
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AdicionarMetaPage(onAdd: _financaPageKey.currentState!.refreshData);
            },
          );
          break;
        case 'Dívidas':
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AdicionarDividaPage(onAdd: _financaPageKey.currentState!.refreshData);
            },
          );
          break;
        case 'Contas Fixas':
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AdicionarContaPage(onAdd: _financaPageKey.currentState!.refreshData);
            },
          );
          break;
      }
    } else {
      print('Floating Action Button Pressed for other page');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          const HomePage(),
          MoviPage(moviController: _moviController),
          FinancaPage(
            key: _financaPageKey,
            onMenuItemSelected: (String text) {
              setState(() {
                _metaPageSelectedText = text;
              });
              print('Item selecionado: $text');
            },
          ),
          const RelatorioPage(),
          UserPage(), // Adicionando UserPage aqui
        ],
      ),
      floatingActionButton: (_currentIndex == 1 || _currentIndex == 2)
          ? FloatingActionButton(
        onPressed: _onFloatingActionButtonPressed,
        child: Image.asset('assets/images/logo3.png', width: 50, height: 40),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomAppBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        children: [
          CustomBottomAppBarItem(
            label: 'home',
            primaryIcon: Icons.home,
            secondaryIcon: Icons.home_outlined,
          ),
          CustomBottomAppBarItem(
            label: 'movimentacao',
            primaryIcon: Icons.list,
            secondaryIcon: Icons.list_outlined,
          ),
          CustomBottomAppBarItem(
            label: 'finanças',
            primaryIcon: Icons.paid,
            secondaryIcon: Icons.paid_outlined,
          ),
          CustomBottomAppBarItem(
            label: 'relatorio',
            primaryIcon: Icons.analytics,
            secondaryIcon: Icons.analytics_outlined,
          ),
          CustomBottomAppBarItem(
            label: 'user',
            primaryIcon: Icons.person,
            secondaryIcon: Icons.person_outlined,
          ),
        ],
      ),
    );
  }
}
