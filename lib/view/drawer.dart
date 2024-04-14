import 'package:despesa_digital/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:despesa_digital/view/saldo.dart';
import 'package:despesa_digital/view/movimentacoes.dart';
import 'package:despesa_digital/view/dividas.dart';
import 'package:despesa_digital/view/metas.dart';
import 'package:despesa_digital/view/gasto_fixo.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Opções',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Início'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
            },
          ),
          ListTile(
            title: Text('Saldo'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Saldo()));
            },
          ),
          ListTile(
            title: Text('Movimentações'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Movimentacoes()));
            },
          ),
          ListTile(
            title: Text('Dívidas'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Dividas()));
            },
          ),
          ListTile(
            title: Text('Gastos Fixos'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => GastoFixo()));
            },
          ),
          ListTile(
            title: Text('Metas'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Metas()));
            },
          ),
        ],
      ),
    );
  }
}
