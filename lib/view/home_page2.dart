import 'package:flutter/material.dart';
import 'package:despesa_digital/controller/utils.dart';
import 'package:despesa_digital/view/saldo.dart';
import 'package:despesa_digital/view/movimentacoes.dart';
import 'package:despesa_digital/view/dividas.dart';
import 'package:despesa_digital/view/metas.dart';
import 'package:despesa_digital/view/navbar.dart';
import 'package:despesa_digital/view/drawer.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = '${now.day} de ${getMonthName(now.month)}';
    String greeting = getGreeting(now.hour);

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomNavbar(scaffoldKey: _scaffoldKey, title: formattedDate),
      drawer: CustomDrawer(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá Pedro, $greeting!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: <Widget>[
                  _buildSquare(context, Colors.red, 'Saldo', Icons.account_balance_wallet, Saldo()),
                  _buildSquare(context, Colors.blue, 'Movimentações', Icons.swap_horiz, Movimentacoes()),
                  _buildSquare(context, Colors.green, 'Dívidas', Icons.money_off, Dividas()),
                  _buildSquare(context, Colors.yellow, 'Metas', Icons.trending_up, Metas()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquare(BuildContext context, Color color, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
