import 'package:flutter/material.dart';
import 'package:despesa_digital/view/navbar.dart';
import 'package:despesa_digital/view/drawer.dart';
import 'package:despesa_digital/database/saldo_db.dart';
import 'package:despesa_digital/model/saldo.dart';

class Saldo extends StatefulWidget {
  @override
  _Saldo createState() => _Saldo();
}

class _Saldo extends State<Saldo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<double> _fetchSaldo() async {
    final saldoDB = SaldoDB();
    final saldos = await saldoDB.fetchAll();
    if (saldos.isNotEmpty) {
      return saldos.first.saldo;
    } else {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomNavbar(scaffoldKey: _scaffoldKey, title: "Saldo"),
      drawer: CustomDrawer(),
      backgroundColor: Colors.tealAccent.withOpacity(0.4),
      body: Center(
        child: FutureBuilder<double>(
          future: _fetchSaldo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Mostrar um indicador de carregamento enquanto o saldo está sendo recuperado
            } else if (snapshot.hasError) {
              return Text('Erro ao carregar saldo: ${snapshot.error}');
            } else {
              return Text(
                'Saldo: R\$${snapshot.data?.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 24),
              );
            }
          },
        ),
      ),
    );
  }
}
