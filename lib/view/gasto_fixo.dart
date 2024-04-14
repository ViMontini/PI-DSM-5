import 'package:flutter/material.dart';
import 'package:despesa_digital/view/navbar.dart';
import 'package:despesa_digital/view/drawer.dart';

class GastoFixo extends StatefulWidget {
  @override
  _GastoFixo createState() => _GastoFixo();
}

class _GastoFixo extends State<GastoFixo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomNavbar(scaffoldKey: _scaffoldKey, title: "Gastos Fixos"),
      drawer: CustomDrawer(),
      backgroundColor: Colors.tealAccent.withOpacity(0.4),
      body: Stack(
        children: [
          // Conteúdo da página
          Column(
            children: [
              SizedBox(height: 20.0),
            ],
          ),
          Positioned(
            right: 20.0,
            bottom: 20.0,
            child: FloatingActionButton(
              onPressed: () {
                // Função para abrir o modal de adicionar gasto fixo (implemente a lógica)
                // ...
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}