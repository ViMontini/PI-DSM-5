import 'dart:async';
import 'dart:developer';
import 'package:despesa_digital/utils/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/home_controller.dart';
import '../controller/movi_controller.dart';
import '../database/movi_db.dart';
import '../database/saldo_db.dart';
import '../database/user_db.dart'; // Importe o UserDB
import '../model/movimentacao.dart';
import '../model/user.dart'; // Importe o User
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Movimentacao>>? futureMovi;
  final MoviController moviController = MoviController();
  final HomeController homeController = HomeController();
  bool _isBalanceVisible = false;
  String? _username;

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
    _isBalanceVisible = PageStorage.of(context)?.readState(context, identifier: 'balanceVisibility') ?? false;
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    if (userId != null) {
      UserDB userDB = UserDB();
      User user = await userDB.fetchById(userId);
      setState(() {
        _username = user.username;
      });
    } else {
      setState(() {
        _username = 'Usuário';
      });
    }
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

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
      PageStorage.of(context)?.writeState(context, _isBalanceVisible, identifier: 'balanceVisibility');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: PageStorageKey('HomePage'),
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
                      homeController.getGreeting(),
                      style: AppTextStyles.smallText.apply(color: AppColors.white),
                    ),
                    Text(
                      _username ?? 'Carregando...',
                      style: AppTextStyles.smallText.apply(color: AppColors.white),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.white,
                  ),
                  onPressed: _toggleBalanceVisibility,
                ),
              ],
            ),
          ),
          Positioned(
            left: 250.w,
            right: 250.w,
            top: 130.h,
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
                                  _isBalanceVisible
                                      ? '\$${NumberFormat("#,##0.00", "pt_BR").format(snapshot.data) ?? "0.00"}'
                                      : '****',
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
            top: 290.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ultimas Movimentações',
                      style: AppTextStyles.mediumText,
                    ),
                  ],
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
                          itemCount: movis.length < 5 ? movis.length : 5,
                          itemBuilder: (context, index) {
                            final movi = movis[index];
                            return moviController.construirMoviHomePage(
                              context,
                              movi,
                              _refreshMovis,
                              _isBalanceVisible,
                            );
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
