import 'package:despesa_digital/database/gasto_db.dart';
import 'package:flutter/material.dart';
import 'package:despesa_digital/view/navbar.dart';
import 'package:despesa_digital/view/drawer.dart';
import 'package:despesa_digital/controller/gafi_controller.dart';
import 'package:despesa_digital/model/gasto_fixo.dart';

class GastoFixos extends StatefulWidget {
  @override
  _GastoFixo createState() => _GastoFixo();
}

class _GastoFixo extends State<GastoFixos> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<GastoFixo>>? futureGastos;
  final GastoController gastoController = GastoController();

  @override
  void initState() {
    super.initState();
    futureGastos = GastoDB().fetchAll();
  }

  void _refreshGastos() {
    setState(() {
      futureGastos = GastoDB().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomNavbar(scaffoldKey: _scaffoldKey, title: "Gastos Fixos"),
      drawer: CustomDrawer(),
      backgroundColor: Colors.tealAccent.withOpacity(0.4),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20.0),
              SizedBox(height: 10.0),
              Expanded(
                child: FutureBuilder<List<GastoFixo>>(
                  future: futureGastos,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final List<GastoFixo> gastos = snapshot.data!;
                      return ListView.builder(
                        itemCount: gastos.length,
                        itemBuilder: (context, index) {
                          final gasto = gastos[index];
                          return Column(
                            children: [
                              gastoController.construirGastoListTile(context, gasto, _refreshGastos),
                              SizedBox(height: 5.0),
                            ],
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return Center(child: Text('Erro ao carregar gastos'));
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
          Positioned(
            right: 20.0,
            bottom: 20.0,
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AdicionarGastoPage();
                  },
                ).then((value) {
                  if (value == true) {
                    setState(() {
                      futureGastos = GastoDB().fetchAll();
                    });
                  }
                });
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}



